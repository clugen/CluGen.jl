# Copyright (c) 2020, 2021 Nuno Fachada, Diogo de Andrade, and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

"""
    CluGen

A Julia module for generating multidimensional clusters. Provides the
[`clugen`](@ref) function for this purpose, as well as a number of auxiliary
functions (used internally by [`clugen`](@ref)), which allow users to build their
own cluster generation algorithms.
"""
module CluGen

using LinearAlgebra
using Random

export clugen
export clusizes
export clucenters
export line_angles
export line_lengths
export points_on_line
export rand_unit_vector
export rand_ortho_vector
export rand_vector_at_angle

"""
    clusizes(
        num_clusters::Integer,
        total_points::Integer,
        allow_empty::Bool;
        rng::AbstractRNG = Random.GLOBAL_RNG
    ) -> AbstractArray{<:Integer, 1}

Determine cluster sizes, i.e., number of points in each cluster.

The function uses the normal distribution (`μ=total_points/num_clusters`,
`σ=μ/3`) for obtaining cluster sizes, and then assures that the final,
absolute cluster sizes add up to `total_points`.

# Examples
```jldoctest; setup = :(Random.seed!(90))
julia> clusizes(4, 6, true)
4-element Array{Int64,1}:
 1
 0
 3
 2

julia> clusizes(4, 100, false)
4-element Array{Int64,1}:
 29
 26
 24
 21

julia> clusizes(5, 500, true; rng=MersenneTwister(123)) # Reproducible
5-element Array{Int64,1}:
 108
 129
 107
  89
  67
```
"""
function clusizes(
    num_clusters::Integer,
    total_points::Integer,
    allow_empty::Bool;
    rng::AbstractRNG = Random.GLOBAL_RNG
)::AbstractArray{<:Integer, 1}

    # Determine number of points in each cluster using the normal distribution

    # Consider the mean an equal division of points between clusters
    mean = total_points / num_clusters
    # The standard deviation is such that the interval [0, 2 * mean] will contain
    # ≈99.7% of cluster sizes
    std = mean / 3

    # Determine points with the normal distribution
    clu_num_points = std .* randn(rng, num_clusters) .+ mean

    # Set negative values to zero
    map!((x) -> x > 0 ? x : 0, clu_num_points, clu_num_points)

    # Fix imbalances, so that total_points is respected
    if sum(clu_num_points) > 0 # Be careful not to divide by zero
        clu_num_points .*=  total_points / sum(clu_num_points)
    end

    # Round the real values to integers since a cluster sizes is represented by an integer
    # For consistency with other clugen implementations, rounding ties move away from zero
    clu_num_points = round.(Integer, clu_num_points, RoundNearestTiesAway)

    # Make sure total points is respected, which may not be the case at this time due
    # to rounding
    while sum(clu_num_points) < total_points
        imin = argmin(clu_num_points)
        clu_num_points[imin] += 1
    end
    while sum(clu_num_points) > total_points
        imax = argmax(clu_num_points)
        clu_num_points[imax] -= 1
    end

    # If empty clusters are not allowed, make sure there aren't any
    if !allow_empty

        # Find empty clusters
        empty_clusts = findall(x -> x == 0, clu_num_points)

        # If there are empty clusters...
        if length(empty_clusts) > 0

            # Go through the empty clusters...
            for i0 in empty_clusts

                # ...get a point from the largest cluster and assign it to the
                # current empty cluster
                imax = argmax(clu_num_points)
                clu_num_points[imax] -= 1
                clu_num_points[i0] += 1

            end
        end
    end

    return clu_num_points

end

"""
    clucenters(
        num_clusters::Integer,
        clu_sep::AbstractArray{<:Real, 1},
        clu_offset::AbstractArray{<:Real, 1};
        rng::AbstractRNG = Random.GLOBAL_RNG
    ) ->  AbstractArray{<:Real}

Determine cluster centers.

Considering ``n=`` `num_clusters`, ``\\mathbf{s}=`` `clu_sep`, ``\\mathbf{o}=``
`clu_offset`, ``d=`` `length(clu_sep)` (i.e., number of dimensions), cluster
centers are obtained according to the following formula:

```math
\\mathbf{C}=n\\mathbf{U} \\cdot \\operatorname{diag}(\\mathbf{s}) + \\mathbf{1}\\,\\mathbf{o}^T
```

where ``\\mathbf{C}`` is the ``n \\times d`` matrix of cluster centers,
``\\mathbf{U}`` is an ``n \\times d`` matrix of random values drawn from the
uniform distribution between -0.5 and 0.5, and ``\\mathbf{1}`` is an ``n \\times
1`` vector with all entries equal to 1.

# Examples
```jldoctest; setup = :(Random.seed!(123))
julia> clucenters(4, [10, 50], [0, 0]) # 2D
4×2 Array{Float64,2}:
 10.7379   -37.3512
 17.6206    32.511
  6.95835   17.2044
 -4.18188  -89.5734

julia> clucenters(5, [20, 10, 30], [10, 10, -10]) # 3D
5×3 Array{Float64,2}:
 -13.136    15.8746      2.34767
 -29.1129   -0.715105  -46.6028
 -23.6334    8.19236    20.879
   7.30168  -1.20904   -41.2033
  46.5412    7.3284    -42.8401

julia> clucenters(3, [100], [0]; rng=MersenneTwister(121)) # 1D, reproducible
3×1 Array{Float64,2}:
  -91.3675026663759
  140.98964768714384
 -124.90981996579862
```
"""
function clucenters(
    num_clusters::Integer,
    clu_sep::AbstractArray{<:Real, 1},
    clu_offset::AbstractArray{<:Real, 1};
    rng::AbstractRNG = Random.GLOBAL_RNG
)::AbstractArray{<:Real}

    # Obtain a num_clusters x num_dims matrix of uniformly distributed values
    # between -0.5 and 0.5 representing the relative cluster centers
    ctr_rel = rand(rng, num_clusters, length(clu_sep)) .- 0.5

    return num_clusters .* ctr_rel * Diagonal(clu_sep) .+ clu_offset'
end

"""
    line_lengths(
        num_clusters::Integer,
        line_length::Real,
        line_length_std::Real;
        rng::AbstractRNG = Random.GLOBAL_RNG
    ) -> AbstractArray{<:Real, 1}

Determine length of cluster-supporting lines.

These lengths are obtained using the folded normal distribution (μ=`line_length`,
σ=`line_length_std`).

# Examples
```jldoctest; setup = :(Random.seed!(123))
julia> line_lengths(5, 10, 3)
5-element Array{Float64,1}:
 13.57080364295883
 16.14453912336772
 13.427952708601596
 11.37824686122124
  8.809962762114331

julia> line_lengths(3, 100, 60; rng=MersenneTwister(111)) # Reproducible
3-element Array{Float64,1}:
 146.1737820482947
  31.914161161783426
 180.04064126207396
```
"""
function line_lengths(
    num_clusters::Integer,
    line_length::Real,
    line_length_std::Real;
    rng::AbstractRNG = Random.GLOBAL_RNG
)::AbstractArray{<:Real, 1}

    return abs.(line_length .+ line_length_std .* randn(rng, num_clusters))

end

"""
    line_angles(
        num_clusters::Integer,
        angle_std::Real;
        rng::AbstractRNG = Random.GLOBAL_RNG
    ) -> AbstractArray{<:Real, 1}

Determine angles between base direction and cluster-supporting lines.

These angles are obtained with the normal distribution (μ=0, σ=`angle_std`).
Note that `angle_std` should be in radians and results are given in radians.

# Examples
```jldoctest; setup = :(Random.seed!(111))
julia> line_angles(4, pi/128)
4-element Array{Float64,1}:
  0.01888791855096079
 -0.027851298321307266
  0.03274154825228484
 -0.004475798744567242

julia> line_angles(3, pi/32; rng=MersenneTwister(987)) # Reproducible
3-element Array{Float64,1}:
  0.08834204306583336
  0.014678748091943443
 -0.15202559427536264
```
"""
function line_angles(
    num_clusters::Integer,
    angle_std::Real;
    rng::AbstractRNG = Random.GLOBAL_RNG
)::AbstractArray{<:Real, 1}

    return angle_std .* randn(rng, num_clusters)

end

"""
    rand_unit_vector(
        num_dims::Integer;
        rng::AbstractRNG = Random.GLOBAL_RNG
    ) ->  AbstractArray{<:Real, 1}

Get a random unit vector with `num_dims` dimensions.

# Examples
```jldoctest; setup = :(Random.seed!(111))
julia> v = rand_unit_vector(4) # 4D
4-element Array{Float64,1}:
 -0.24033021128704707
 -0.032103799230189585
  0.04223910709972599
 -0.9692402145232775

julia> norm(v) # Check vector magnitude is 1 (needs LinearAlgebra package)
1.0

julia> rand_unit_vector(2; rng=MersenneTwister(33)) # 2D, reproducible
2-element Array{Float64,1}:
  0.8429232717309576
 -0.5380337888779647
```
"""
function rand_unit_vector(
    num_dims::Integer;
    rng::AbstractRNG = Random.GLOBAL_RNG
)::AbstractArray{<:Real, 1}

    r = rand(rng, num_dims) .- 0.5
    normalize!(r)
    return r

end

"""
    rand_ortho_vector(
        u::AbstractArray{<:Real, 1};
        rng::AbstractRNG = Random.GLOBAL_RNG
    ) -> AbstractArray{<:Real, 1}

Get a random unit vector orthogonal to `u`.

Note that `u` is expected to be a unit vector itself.

# Examples
```jldoctest; setup = :(Random.seed!(111))
julia> u = normalize([1,2,5.0,-3,-0.2]); # Define a 5D unit vector

julia> v = rand_ortho_vector(u);

julia> dot(u, v) # Check that vectors are orthogonal (needs LinearAlgebra package)
0.0

julia> rand_ortho_vector([1,0,0]; rng=MersenneTwister(567)) # 3D, reproducible
3-element Array{Float64,1}:
  0.0
 -0.717797705156548
  0.6962517177515569
```
"""
function rand_ortho_vector(
    u::AbstractArray{<:Real, 1};
    rng::AbstractRNG = Random.GLOBAL_RNG
)::AbstractArray{<:Real, 1}

    # If 1D, just return a random unit vector
    length(u) == 1 && return rand_unit_vector(1; rng=rng)

    # Variable for placing random non-parallel vector
    r = nothing

    # Find a random, non-parallel vector to u
    while true

        # Find normalized random vector
        r = rand_unit_vector(length(u); rng=rng)

        # If not parallel to u we can keep it and break the loop
        if abs(dot(u, r)) ≉ 1
            break
        end

    end

    # Get vector orthogonal to u using 1st iteration of Gram-Schmidt process
    v = r - dot(u, r) / dot(u, u) .* u

    # Normalize it
    normalize!(v)

    # And return it
    return v

end

"""
    rand_vector_at_angle(
        u::AbstractArray{<:Real, 1},
        angle::Real;
        rng::AbstractRNG = Random.GLOBAL_RNG
    ) ->  AbstractArray{<:Real, 1}

Get a random unit vector which is at `angle` radians of vector `u`.

Note that `u` is expected to be a unit vector itself.

# Examples
```jldoctest; setup = :(Random.seed!(111))
julia> u = normalize([1,0.5,0.3,-0.1]); # Define a 4D unit vector

julia> v = rand_vector_at_angle(u, pi/4); # pi/4 = 0.7853981... radians = 45 degrees

julia> a = acos(dot(u, v) / (norm(u) * norm(v))) # Angle (radians) between u and v?
0.7853981633974483

julia> rand_vector_at_angle([0, 1], pi/6; rng=MersenneTwister(456)) # 2D, reproducible
2-element Array{Float64,1}:
 -0.4999999999999999
  0.8660254037844387
```
"""
function rand_vector_at_angle(
    u::AbstractArray{<:Real, 1},
    angle::Real;
    rng::AbstractRNG = Random.GLOBAL_RNG
)::AbstractArray{<:Real, 1}

    if -pi/2 < angle < pi/2 && length(u) > 1
        return normalize(u + rand_ortho_vector(u; rng=rng) * tan(angle))
    else
        return rand_unit_vector(length(u); rng=rng)
    end

end

"""
    points_on_line(
        center::AbstractArray{<:Real, 1},
        direction::AbstractArray{<:Real, 1},
        dist_center::AbstractArray{<:Real, 1},
    ) -> AbstractArray{<:Real, 2}

Determine coordinates of points on a line with `center` and `direction`, based
on the distances from the center given in `dist_center`.

This works by using the vector formulation of the line equation assuming
`direction` is a ``d``-dimensional unit vector. In other words, considering
``\\mathbf{v}=`` `direction` (``d \\times 1``), ``\\mathbf{c}=`` `center` (``
d \\times 1``), and ``\\mathbf{w}=`` `dist_center` (``p_\\text{tot} \\times
1``), the coordinates of points on the line are given by:

```math
\\mathbf{P}=\\mathbf{1}\\,\\mathbf{c}^T + \\mathbf{w}\\mathbf{v}^T
```

where ``\\mathbf{P}`` is the ``p_\\text{tot} \\times d`` matrix of point
coordinates on the line, and ``\\mathbf{1}`` is an ``d \\times 1`` vector with
all entries equal to 1.

# Examples
```jldoctest
julia> points_on_line([5.0,5.0], [1.0,0.0], -4:2:4) # 2D, 5 points
5×2 Array{Float64,2}:
 1.0  5.0
 3.0  5.0
 5.0  5.0
 7.0  5.0
 9.0  5.0

julia> points_on_line([-2.0,0,0,2.0], [0,0,-1.0,0], [10,-10]) # 4D, 2 points
2×4 Array{Float64,2}:
 -2.0  0.0  -10.0  2.0
 -2.0  0.0   10.0  2.0
```
"""
function points_on_line(
    center::AbstractArray{<:Real, 1},
    direction::AbstractArray{<:Real, 1},
    dist_center::AbstractArray{<:Real, 1},
)::AbstractArray{<:Real, 2}

    return center' .+ dist_center * direction'

end

"""
    CluGen.clupoints_d_1(
        projs::AbstractArray{<:Real, 2},
        lat_std::Real,
        clu_dir::AbstractArray{<:Real, 1},
        clu_ctr::AbstractArray{<:Real, 1},
        rng::AbstractRNG = Random.GLOBAL_RNG
    ) -> AbstractArray{<:Real}

Generate points from their ``d``-dimensional projections on a cluster-supporting
line, placing each point `i` on a second line, orthogonal to the first and
centered at the point's projection, using the normal distribution (μ=0, σ=`lat_std`).

!!! note "Internal package function"
    This function's main intended use is by the [`clugen()`](@ref) function,
    generating points when its `point_offset` parameter is set to `"d-1"`. Thus,
    it's not exported by the package and must be prefixed by the package name,
    e.g. `CluGen.clupoints_d_1(...)`.

# Arguments
- `projs`: point projections on the cluster-supporting line.
- `lat_std`: standard deviation for the normal distribution, i.e., cluster lateral
  dispersion.
- `clu_dir`: direction of the cluster-supporting line.
- `clu_ctr` center position of the cluster-supporting line center position (ignored).
- `rng`: an optional pseudo-random number generator for reproducible executions.

# Examples
```jldoctest
julia> projs = points_on_line([5.0,5.0], [1.0,0.0], -4:2:4) # Get 5 point projections on a 2D line
5×2 Array{Float64,2}:
 1.0  5.0
 3.0  5.0
 5.0  5.0
 7.0  5.0
 9.0  5.0

julia> CluGen.clupoints_d_1(projs, 0.5, [1,0], [0,0], MersenneTwister(123))
5×2 Array{Float64,2}:
 1.0  5.59513
 3.0  3.97591
 5.0  4.42867
 7.0  5.22971
 9.0  4.80166
```
"""
function clupoints_d_1(
    projs::AbstractArray{<:Real, 2},
    lat_std::Real,
    clu_dir::AbstractArray{<:Real, 1},
    clu_ctr::AbstractArray{<:Real, 1},
    rng::AbstractRNG = Random.GLOBAL_RNG
)::AbstractArray{<:Real}

    # Number of dimensions
    num_dims = length(clu_dir)

    # Number of points in this cluster
    clu_num_points = size(projs, 1)

    # Get distances from points to their projections on the line
    points_dist = lat_std .* randn(rng, clu_num_points, 1)

    # Get normalized vectors, orthogonal to the current line, for each point
    orth_vecs = zeros(clu_num_points, num_dims)
    for j = 1:clu_num_points
        orth_vecs[j, :] = rand_ortho_vector(clu_dir, rng=rng)
    end

    # Set vector magnitudes
    orth_vecs = abs.(points_dist) .* orth_vecs

    # Add perpendicular vectors to point projections on the line,
    # yielding final cluster points
    points = projs + orth_vecs

    return points

end

"""
    GluGen.clupoints_d(
        projs::AbstractArray{<:Real, 2},
        lat_std::Real,
        clu_dir::AbstractArray{<:Real, 1},
        clu_ctr::AbstractArray{<:Real, 1},
        rng::AbstractRNG = Random.GLOBAL_RNG
    ) -> AbstractArray{<:Real}

Generate points from their ``d``-dimensional projections on a cluster-supporting
line, placing each point `i` around its projection using the normal distribution
(μ=`projs[i]`, σ=`lat_std`).

!!! note "Internal package function"
    This function's main intended use is by the [`clugen()`](@ref) function,
    generating points when its `point_offset` parameter is set to `"d"`. Thus,
    it's not exported by the package and must be prefixed by the package name,
    e.g. `CluGen.clupoints_d(...)`.

# Arguments
- `projs`: point projections on the cluster-supporting line.
- `lat_std`: standard deviation for the normal distribution, i.e., cluster lateral
  dispersion.
- `clu_dir`: direction of the cluster-supporting line.
- `clu_ctr` center position of the cluster-supporting line center position (ignored).
- `rng`: an optional pseudo-random number generator for reproducible executions.

# Examples
```jldoctest
julia> projs = points_on_line([5.0,5.0], [1.0,0.0], -4:2:4) # Get 5 point projections on a 2D line
5×2 Array{Float64,2}:
 1.0  5.0
 3.0  5.0
 5.0  5.0
 7.0  5.0
 9.0  5.0

julia> CluGen.clupoints_d(projs, 0.5, [1,0], [0,0], MersenneTwister(123))
5×2 Array{Float64,2}:
 1.59513  4.66764
 4.02409  5.49048
 5.57133  4.96226
 7.22971  5.13691
 8.80166  4.90289
```
"""
function clupoints_d(
    projs::AbstractArray{<:Real, 2},
    lat_std::Real,
    clu_dir::AbstractArray{<:Real, 1},
    clu_ctr::AbstractArray{<:Real, 1},
    rng::AbstractRNG = Random.GLOBAL_RNG
)::AbstractArray{<:Real}

    # Number of dimensions
    num_dims = length(clu_dir)

    # Number of points in this cluster
    clu_num_points = size(projs, 1)

    # Get random displacement vectors for each point projection
    displ = lat_std .* randn(rng, clu_num_points, num_dims)

    # Add displacement vectors to each point projection
    points = projs + displ

    return points
end

"""
    clugen(
        num_dims::Integer,
        num_clusters::Integer,
        total_points::Integer,
        direction::AbstractArray{<:Real, 1},
        angle_std::Real,
        cluster_sep::AbstractArray{<:Real, 1},
        line_length::Real,
        line_length_std::Real,
        lateral_std::Real;
        # Keyword arguments
        allow_empty::Bool = false,
        cluster_offset::Union{AbstractArray{<:Real, 1}, Nothing} = nothing,
        point_dist::Union{String, <:Function} = "norm",
        point_offset::Union{String, <:Function} = "d-1",
        clusizes_fn::Function = clusizes,
        clucenters_fn::Function = clucenters,
        line_lengths_fn::Function = line_lengths,
        line_angles_fn::Function = line_angles,
        rng::AbstractRNG = Random.GLOBAL_RNG
    ) -> NamedTuple{(
            :points,              # Array{<:Real,2}
            :points_cluster,      # Array{<:Integer,1}
            :points_projection,   # Array{<:Real,2}
            :clusters_size,       # Array{<:Integer,1}
            :clusters_center,     # Array{<:Real,2}
            :clusters_direction,  # Array{<:Real,2}
            :clusters_length      # Array{<:Real,1}
         )}

Generate multidimensional clusters.

This is the main function of the CluGen package, and most likely is the only function
users will need to use.

# Arguments (mandatory)
- `num_dims`: number of dimensions.
- `num_clusters`: number of clusters to generate.
- `total_points`: total points to generate.
- `direction`: mean direction of the clusters (`num_dims` x 1).
- `angle_std`: considering the angle of `direction` as the mean of the cluster-supporting
  line angles, this parameter represents the respective standard deviation, in radians.
- `cluster_sep`: mean cluster separation in each dimension (`num_dims` x 1).
- `line_length`: mean length of cluster-supporting lines.
- `line_length_std`: standard deviation of the length of cluster-supporting lines.
- `lateral_std`: point dispersion from line, i.e., cluster lateral dispersion.

# Arguments (optional)
- `allow_empty`: allow empty clusters? `false` by default.
- `cluster_offset`: offset to add to all cluster centers; if set to `nothing` (the
  default), the offset will be equal to `zeros(num_dims)`.
- `point_dist`: defines the distribution of points along lines, with three possible
  values:
  - `"norm"` (default): distribute point projections along lines using a normal
    distribution (μ=_line center_, σ=`line_length/6`).
  - `"unif"`: distribute points uniformly along the line.
  - User-defined function, which accepts two parameters, line length (float) and
    number of points (integer), and returns an array containing the distance of
    each point to the center of the line. For example, the `"norm"` option
    roughly corresponds to `(len, n) -> (1.0 / 6.0) * len .* randn(n)`.
- `point_offset`: controls how points are created from their projections on the lines,
  with three possible values:
  - `"d-1"` (default): generate points from their ``d``-dimensional projections on a
    cluster-supporting line, placing each point `i` on a second line, orthogonal to
    the first and centered at the point's projection, using the normal distribution
    (μ=0, σ=`lat_std`). This is done by the [`CluGen.clupoints_d_1()`](@ref) function.
  - `"d"`: generate points from their ``d``-dimensional projections on a
    cluster-supporting line, placing each point `i` around its projection using the
    normal distribution (μ=`0`, σ=`lateral_std`). This is done by the
    [`CluGen.clupoints_d()`](@ref) function.
  - User-defined function: the user can specify a custom point placement strategy
    by passing a function with the same signature as [`CluGen.clupoints_d_1()`](@ref)
    and [`CluGen.clupoints_d()`](@ref).
- `clusizes_fn`: by default, cluster sizes are determined by the [`clusizes()`](@ref)
  function; this parameter allows the user to specify a custom function for this
  purpose, which must follow [`clusizes()`](@ref)'s signature.
- `clucenters_fn`: by default, cluster centers are determined by the [`clucenters()`](@ref)
  function; this parameter allows the user to specify a custom function for this purpose,
  which must follow [`clucenters()`](@ref)'s signature.
- `line_lengths_fn`: by default, the lengths of cluster-supporting lines are determined
  by the [`line_lengths()`](@ref) function; this parameter allows the user to specify a
  custom function for this purpose, which must follow [`line_lengths()`](@ref)'s
  signature.
- `line_angles_fn`: by default, the angles between the main direction and the direction
  of cluster-supporting lines are determined by the [`line_angles()`](@ref) function;
  this parameter allows the user to specify a custom function for this purpose, which
  must follow [`line_angles()`](@ref)'s signature.
- `rng`: a concrete instance of
  [`AbstractRNG`](https://docs.julialang.org/en/v1/stdlib/Random/#Random.AbstractRNG)
  for reproducible runs. Alternatively, the user can set the global RNG seed with
  [`Random.seed!()`](https://docs.julialang.org/en/v1/stdlib/Random/#Random.seed!)
  before invoking `clugen()`.

# Return values
The function returns a `NamedTuple` with the following fields:

- `points`: a `total_points` x `num_dims` matrix with the generated points for
   all clusters.
- `points_cluster`: a `total_points` x 1` vector indicating which cluster
  each point in `points` belongs to.
- `points_projection`: a `total_points` x `num_dims` matrix with the point
  projections on the cluster-supporting lines.
- `clusters_size`: a `num_clusters` x 1 vector with the number of
  points in each cluster.
- `clusters_center`: a `num_clusters` x `num_dims` matrix with the coordinates
  of the cluster centers.
- `clusters_direction`: a `num_clusters` x `num_dims` matrix with the direction
  of each cluster-supporting line.
- `clusters_length`: a `num_clusters` x 1 vector with the lengths of the
  cluster-supporting lines.

# Examples
```jldoctest; setup = :(Random.seed!(123))
julia> # Create 5 clusters in 3D space with a total of 10000 points...

julia> out = clugen(3, 5, 10000, [0.5, 0.5, 0.5], pi/16, [10, 10, 10], 10, 1, 2);

julia> out.clusters_center # What are the cluster centers?
5×3 Array{Float64,2}:
   8.12774  -16.8167    -1.80764
   4.30111   -1.34916  -11.209
 -22.3933    18.2706    -2.6716
 -11.568      5.87459    4.11589
 -19.5565   -10.7151   -12.2009
```

The following instruction displays a scatter plot of the clusters in 3D space:

```julia-repl
julia> plot(out.points[:,1], out.points[:,2], out.points[:,3], seriestype = :scatter, group=out.points_cluster)
```

Check the [Tutorial](@ref) section for more information on how to use the `clugen()`
function, and the [Gallery](@ref) section for a number of illustrative examples.
"""
function clugen(
    num_dims::Integer,
    num_clusters::Integer,
    total_points::Integer,
    direction::AbstractArray{<:Real, 1},
    angle_std::Real,
    cluster_sep::AbstractArray{<:Real, 1},
    line_length::Real,
    line_length_std::Real,
    lateral_std::Real;
    allow_empty::Bool = false,
    cluster_offset::Union{AbstractArray{<:Real, 1}, Nothing} = nothing,
    point_dist::Union{String, <:Function} = "norm",
    point_offset::Union{String, <:Function} = "d-1",
    clusizes_fn::Function = clusizes,
    clucenters_fn::Function = clucenters,
    line_lengths_fn::Function = line_lengths,
    line_angles_fn::Function = line_angles,
    rng::AbstractRNG = Random.GLOBAL_RNG
)::NamedTuple

    # ############### #
    # Validate inputs #
    # ############### #

    # Check that number of dimensions is > 0
    if num_dims < 1
        throw(ArgumentError("Number of dimensions, `num_dims`, must be > 0"))
    end

    # Check that number of clusters is > 0
    if num_clusters < 1
        throw(ArgumentError("Number of clusters, `num_clust`, must be > 0"))
    end

    # Check that direction vector has magnitude > 0
    if norm(direction) < eps()
        throw(ArgumentError("`direction` must have magnitude > 0"))
    end

    # Check that direction has num_dims dimensions
    dir_len = length(direction)
    if dir_len != num_dims
        throw(ArgumentError(
            "Length of `direction` must be equal to `num_dims` " *
            "($dir_len != $num_dims)"))
    end

    # If allow_empty is false, make sure there are enough points to distribute
    # by the clusters
    if !allow_empty && total_points < num_clusters
        throw(ArgumentError(
            "A total of $total_points points is not enough for " *
            "$num_clusters non-empty clusters"))
    end

    # Check that cluster_sep has num_dims dimensions
    clusep_len = length(cluster_sep)
    if clusep_len != num_dims
        throw(ArgumentError(
            "Length of `cluster_sep` must be equal to `num_dims` " *
            "($clusep_len != $num_dims)"))
    end

    # If given, cluster_offset must have the correct number of dimensions,
    # if not given then it will be a num_dims x 1 vector of zeros
    if cluster_offset === nothing
        cluster_offset = zeros(num_dims)
    elseif length(cluster_offset) != num_dims
        throw(ArgumentError(
            "Length of `cluster_offset` must be equal to `num_dims` " *
            "($(length(cluster_offset)) != $num_dims)"))
    end

    # Check that point_dist specifies a valid way for projecting points along
    # cluster-supporting lines i.e., either 'norm' (default), 'unif' or a
    # user-defined function
    if typeof(point_dist) <: Function
        # Use user-defined distribution; assume function accepts length of line
        # and number of points, and returns a num_dims x 1 vector
        pointproj_fn = point_dist
    elseif point_dist == "unif"
        # Point projections will be uniformly placed along cluster-supporting lines
        pointproj_fn = (len, n) -> len .* rand(rng, n) .- len / 2
    elseif point_dist == "norm"
        # Use normal distribution for placing point projections along cluster-supporting
        # lines, mean equal to line center, standard deviation equal to 1/6 of line length
        # such that the line length contains ≈99.73% of the points
        pointproj_fn = (len, n) -> (1.0 / 6.0) * len .* randn(rng, n)
    else
        throw(ArgumentError(
            "`point_dist` has to be either \"norm\", \"unif\" or user-defined function"))
    end

    # Check that point_offset specifies a valid way for generating points given
    # their projections along cluster-supporting lines, i.e., either 'd-1'
    # (default), 'd' or a user-defined function
    if num_dims == 1
        # If 1D was specified, point projections are the points themselves
        pt_from_proj_fn = (projs, lat_std, clu_dir, clu_ctr) -> projs
    elseif typeof(point_offset) <: Function
        # Use user-defined distribution; assume function accepts point projections
        # on the line, lateral std., cluster direction and cluster center, and
        # returns a num_points x num_dims matrix containing the final points
        # for the current cluster
        pt_from_proj_fn = point_offset
    elseif point_offset == "d-1"
        # Points will be placed on a second line perpendicular to the cluster
        # line using a normal distribution centered at their intersection
        pt_from_proj_fn = clupoints_d_1
    elseif point_offset == "d"
        # Points will be placed using a multivariate normal distribution
        # centered at the point projection
        pt_from_proj_fn = clupoints_d
    else
        throw(ArgumentError(
            "point_offset has to be either \"d-1\", \"d\" or a user-defined function"))
    end

    # ############################ #
    # Determine cluster properties #
    # ############################ #

    # Normalize base direction
    dir_unit = normalize(direction)

    # Determine cluster sizes
    clu_num_points = clusizes_fn(num_clusters, total_points, allow_empty; rng=rng)

    # Determine cluster centers
    clu_centers = clucenters_fn(num_clusters, cluster_sep, cluster_offset; rng=rng)

    # Determine length of lines supporting clusters
    lengths = line_lengths_fn(num_clusters, line_length, line_length_std; rng=rng)

    # Obtain angles between main direction and cluster-supporting lines
    angles = line_angles_fn(num_clusters, angle_std; rng=rng)

    # Determine normalized cluster direction
    clu_dirs = hcat([rand_vector_at_angle(direction, a; rng=rng) for a in angles]...)'

    # ################################# #
    # Determine points for each cluster #
    # ################################# #

    # Aux. vector with cumulative sum of number of points in each cluster
    cumsum_points = [0; cumsum(clu_num_points)]

    # Pre-allocate data structures for holding cluster info and points
    clu_pts_idx = zeros(Int, total_points)      # Cluster indices of each point
    points_proj = zeros(total_points, num_dims) # Point projections on cluster-supporting lines
    points = zeros(total_points, num_dims)      # Final points to be generated

    # Loop through cluster and create points for each one
    for i in 1:num_clusters

        # Start and end indexes for points in current cluster
        idx_start = cumsum_points[i] + 1
        idx_end = cumsum_points[i + 1]

        # Update cluster indices of each point
        clu_pts_idx[idx_start:idx_end] .= i;

        # Determine distance of point projections from the center of the line
        ptproj_dist_center = pointproj_fn(lengths[i], clu_num_points[i])

        # Determine coordinates of point projections on the line using the
        # parametric line equation (this works since cluster direction is normalized)
        points_proj[idx_start:idx_end, :] = points_on_line(
            clu_centers[i, :], clu_dirs[i, :], ptproj_dist_center)

        # Determine points from their projections on the line
        points[idx_start:idx_end, :] = pt_from_proj_fn(
            points_proj[idx_start:idx_end, :],
            lateral_std,
            clu_dirs[i, :],
            clu_centers[i, :])

    end

    return (
        points = points,
        points_cluster = clu_pts_idx,
        points_projection = points_proj,
        clusters_size = clu_num_points,
        clusters_center = clu_centers,
        clusters_direction = clu_dirs,
        clusters_length = lengths)

end

end # Module
