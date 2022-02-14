# Copyright (c) 2020, 2021 Nuno Fachada, Diogo de Andrade, and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

"""
    CluGen

A Julia package for generating multidimensional clusters. Provides the
[`clugen`](@ref) function for this purpose, as well as a number of auxiliary
functions, used internally and modularly by [`clugen`](@ref). Users can swap
these auxiliary functions by their own customized versions, fine-tuning their
cluster generation strategies, or even use them as the basis for their own
generation algorithms.
"""
module CluGen

using LinearAlgebra
using Random

export clugen
export points_on_line
export rand_unit_vector
export rand_ortho_vector
export rand_vector_at_angle

# ############################################################################ #
# ########################### Main function ################################## #
# ############################################################################ #

"""
    clugen(
        num_dims::Integer,
        num_clusters::Integer,
        num_points::Integer,
        direction::AbstractArray{<:Real, 1},
        angle_disp::Real,
        cluster_sep::AbstractArray{<:Real, 1},
        llength::Real,
        llength_disp::Real,
        lateral_disp::Real;
        # Keyword arguments
        allow_empty::Bool = false,
        cluster_offset::Union{AbstractArray{<:Real, 1}, Nothing} = nothing,
        proj_dist_fn::Union{String, <:Function} = "norm",
        point_dist_fn::Union{String, <:Function} = "n-1",
        clusizes_fn::Function = GluGen.clusizes,
        clucenters_fn::Function = GluGen.clucenters,
        llengths_fn::Function = GluGen.llengths,
        angle_deltas_fn::Function = GluGen.angle_deltas,
        rng::AbstractRNG = Random.GLOBAL_RNG
    ) -> NamedTuple{(
            :points,              # Array{<:Real,2}
            :point_clusters,      # Array{<:Integer,1}
            :point_projections,   # Array{<:Real,2}
            :cluster_sizes,       # Array{<:Integer,1}
            :cluster_centers,     # Array{<:Real,2}
            :cluster_directions,  # Array{<:Real,2}
            :cluster_lengths      # Array{<:Real,1}
         )}

Generate multidimensional clusters.

This is the main function of the CluGen package, and possibly the only function
most users will need.

# Arguments (mandatory)
- `num_dims`: Number of dimensions.
- `num_clusters`: Number of clusters to generate.
- `num_points`: Total number of points to generate.
- `direction`: Average direction of the cluster-supporting lines (`num_dims` x 1).
- `angle_disp`: Angle dispersion of cluster-supporting lines (radians).
- `cluster_sep`: Average cluster separation in each dimension (`num_dims` x 1).
- `llength`: Average length of cluster-supporting lines.
- `llength_disp`: Length dispersion of cluster-supporting lines.
- `lateral_disp`: Cluster lateral dispersion, i.e., dispersion of points from their
  projection on the cluster-supporting line.

Note that the terms "average" and "dispersion" refer to measures of central tendency
and statistical dispersion, respectively. Their exact meaning depends on the optional
arguments, described next.

# Arguments (optional)
- `allow_empty`: Allow empty clusters? `false` by default.
- `cluster_offset`: Offset to add to all cluster centers. If set to `nothing` (the
  default), the offset will be equal to `zeros(num_dims)`.
- `proj_dist_fn`: Distribution of point projections along cluster-supporting lines,
  with three possible values:
  - `"norm"` (default): Distribute point projections along lines using a normal
    distribution (μ=_line center_, σ=`llength/6`).
  - `"unif"`: Distribute points uniformly along the line.
  - User-defined function, which accepts two parameters, line length (float),
    number of points (integer) and a random number generator, and returns an array
    containing the distance of each point projection to the center of the line. For
    example, the `"norm"` option roughly corresponds to
    `(len, n, rng) -> (1.0 / 6.0) * len .* randn(rng, n)`.
- `point_dist_fn`: Controls how the final points are created from their projections
  on the cluster-supporting lines, with three possible values:
  - `"n-1"` (default): Final points are placed on a hyperplane orthogonal to
    the cluster-supporting line, centered at each point's projection, using the
    normal distribution (μ=0, σ=`lateral_disp`). This is done by the
    [`CluGen.clupoints_n_1()`](@ref) function.
  - `"n"`: Final points are placed around their projection on the cluster-supporting
    line using the normal distribution (μ=0, σ=`lateral_disp`). This is done by the
    [`CluGen.clupoints_n()`](@ref) function.
  - User-defined function: The user can specify a custom point placement strategy
    by passing a function with the same signature as [`CluGen.clupoints_n_1()`](@ref)
    and [`CluGen.clupoints_n()`](@ref).
- `clusizes_fn`: Distribution of cluster sizes. By default, cluster sizes are
  determined by the [`CluGen.clusizes()`](@ref) function, which uses the normal
  distribution (μ=`num_points`/`num_clusters`, σ=μ/3), and assures that the final
  cluster sizes add up to `num_points`. This parameter allows the user to specify a
  custom function for this purpose, which must follow [`CluGen.clusizes()`](@ref)'s
  signature. Note that custom functions are not required to strictly obey the
  `num_points` parameter.
- `clucenters_fn`: Distribution of cluster centers. By default, cluster centers
  are determined by the [`CluGen.clucenters()`](@ref) function, which uses the
  uniform distribution, and takes into account the `num_clusters` and `cluster_sep`
  parameters for generating well-distributed cluster centers. This parameter allows
  the user to specify a custom function for this purpose, which must follow
  [`CluGen.clucenters()`](@ref)'s signature.
- `llengths_fn`: Distribution of line lengths. By default, the lengths of
  cluster-supporting lines are determined by the [`CluGen.llengths()`](@ref) function,
  which uses the folded normal distribution (μ=`llength`, σ=`llength_disp`). This
  parameter allows the user to specify a custom function for this purpose, which
  must follow [`CluGen.llengths()`](@ref)'s signature.
- `angle_deltas_fn`: Distribution of line angle differences with respect to `direction`.
  By default, the angles between `direction` and the direction of cluster-supporting
  lines are determined by the [`CluGen.angle_deltas()`](@ref) function, which uses
  the wrapped normal distribution (μ=0, σ=`angle_disp`) with support in the interval
  ``\\left[-\\pi/2,\\pi/2\\right]``. This parameter allows the user to specify a
  custom function for this purpose, which must follow [`CluGen.angle_deltas()`](@ref)'s
  signature.
- `rng`: A concrete instance of
  [`AbstractRNG`](https://docs.julialang.org/en/v1/stdlib/Random/#Random.AbstractRNG)
  for reproducible runs. Alternatively, the user can set the global RNG seed with
  [`Random.seed!()`](https://docs.julialang.org/en/v1/stdlib/Random/#Random.seed!)
  before invoking `clugen()`.

# Return values
The function returns a `NamedTuple` with the following fields:

- `points`: A `num_points` x `num_dims` matrix with the generated points for
   all clusters.
- `point_clusters`: A `num_points` x 1 vector indicating which cluster
  each point in `points` belongs to.
- `point_projections`: A `num_points` x `num_dims` matrix with the point
  projections on the cluster-supporting lines.
- `cluster_sizes`: A `num_clusters` x 1 vector with the number of
  points in each cluster.
- `cluster_centers`: A `num_clusters` x `num_dims` matrix with the coordinates
  of the cluster centers.
- `cluster_directions`: A `num_clusters` x `num_dims` matrix with the direction
  of each cluster-supporting line.
- `cluster_angles`: A `num_clusters` x 1 vector with the angles between the
  cluster-supporting lines and the main direction.
- `cluster_lengths`: A `num_clusters` x 1 vector with the lengths of the
  cluster-supporting lines.

Note that if a custom function was given in the `clusizes_fn` parameter, it is
possible that `num_points` may have a different value than what was specified in
`clugen`'s `num_points` parameter.

# Examples
```jldoctest; setup = :(Random.seed!(123))
julia> # Create 5 clusters in 3D space with a total of 10000 points...

julia> out = clugen(3, 5, 10000, [0.5, 0.5, 0.5], pi/16, [10, 10, 10], 10, 1, 2);

julia> out.cluster_centers # What are the cluster centers?
5×3 Matrix{Float64}:
   8.12774  -16.8167    -1.80764
   4.30111   -1.34916  -11.209
 -22.3933    18.2706    -2.6716
 -11.568      5.87459    4.11589
 -19.5565   -10.7151   -12.2009
```

The following instruction displays a scatter plot of the clusters in 3D space:

```julia-repl
julia> plot(out.points[:,1], out.points[:,2], out.points[:,3], seriestype = :scatter, group=out.point_clusters)
```

Check the [Practice](@ref) section for a number of illustrative examples on how to
use the `clugen()` function. The [Theory](@ref) section provides more information
on how the function works and the impact each parameter has on the final result.
"""
function clugen(
    num_dims::Integer,
    num_clusters::Integer,
    num_points::Integer,
    direction::AbstractArray{<:Real, 1},
    angle_disp::Real,
    cluster_sep::AbstractArray{<:Real, 1},
    llength::Real,
    llength_disp::Real,
    lateral_disp::Real;
    allow_empty::Bool = false,
    cluster_offset::Union{AbstractArray{<:Real, 1}, Nothing} = nothing,
    proj_dist_fn::Union{String, <:Function} = "norm",
    point_dist_fn::Union{String, <:Function} = "n-1",
    clusizes_fn::Function = clusizes,
    clucenters_fn::Function = clucenters,
    llengths_fn::Function = llengths,
    angle_deltas_fn::Function = angle_deltas,
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
    if !allow_empty && num_points < num_clusters
        throw(ArgumentError(
            "A total of $num_points points is not enough for " *
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

    # Check that proj_dist_fn specifies a valid way for projecting points along
    # cluster-supporting lines i.e., either "norm" (default), "unif" or a
    # user-defined function
    if typeof(proj_dist_fn) <: Function
        # Use user-defined distribution; assume function accepts length of line,
        # number of points and RNG, and returns a number of points x 1 vector
        pointproj_fn = proj_dist_fn
    elseif proj_dist_fn == "unif"
        # Point projections will be uniformly placed along cluster-supporting lines
        pointproj_fn = (len, n, rng) -> len .* rand(rng, n) .- len / 2
    elseif proj_dist_fn == "norm"
        # Use normal distribution for placing point projections along cluster-supporting
        # lines, mean equal to line center, standard deviation equal to 1/6 of line length
        # such that the line length contains ≈99.73% of the points
        pointproj_fn = (len, n, rng) -> (1.0 / 6.0) * len .* randn(rng, n)
    else
        throw(ArgumentError(
            "`proj_dist_fn` has to be either \"norm\", \"unif\" or user-defined function"))
    end

    # Check that point_dist_fn specifies a valid way for generating points given
    # their projections along cluster-supporting lines, i.e., either "n-1"
    # (default), "n" or a user-defined function
    if num_dims == 1
        # If 1D was specified, point projections are the points themselves
        pt_from_proj_fn = (projs, lat_disp, len, clu_dir, clu_ctr; rng=rng) -> projs
    elseif typeof(point_dist_fn) <: Function
        # Use user-defined distribution; assume function accepts point projections
        # on the line, lateral disp., cluster direction and cluster center, and
        # returns a num_points x num_dims matrix containing the final points
        # for the current cluster
        pt_from_proj_fn = point_dist_fn
    elseif point_dist_fn == "n-1"
        # Points will be placed on a hyperplane orthogonal to the cluster-supporting
        # line using a normal distribution centered at their intersection
        pt_from_proj_fn = clupoints_n_1
    elseif point_dist_fn == "n"
        # Points will be placed using a multivariate normal distribution
        # centered at the point projection
        pt_from_proj_fn = clupoints_n
    else
        throw(ArgumentError(
            "point_dist_fn has to be either \"n-1\", \"n\" or a user-defined function"))
    end

    # ############################ #
    # Determine cluster properties #
    # ############################ #

    # Normalize main direction
    direction = normalize(direction)

    # Determine cluster sizes
    cluster_sizes = clusizes_fn(num_clusters, num_points, allow_empty; rng=rng)

    # Custom clusizes_fn's are not required to obey num_points, so we update
    # it here just in case it's different from what the user specified
    num_points = sum(cluster_sizes)

    # Determine cluster centers
    cluster_centers = clucenters_fn(num_clusters, cluster_sep, cluster_offset; rng=rng)

    # Determine length of lines supporting clusters
    cluster_lengths = llengths_fn(num_clusters, llength, llength_disp; rng=rng)

    # Obtain angles between main direction and cluster-supporting lines
    cluster_angles = angle_deltas_fn(num_clusters, angle_disp; rng=rng)

    # Determine normalized cluster directions
    cluster_directions = hcat([rand_vector_at_angle(direction, a; rng=rng) for a in cluster_angles]...)'

    # ################################# #
    # Determine points for each cluster #
    # ################################# #

    # Aux. vector with cumulative sum of number of points in each cluster
    cumsum_points = [0; cumsum(cluster_sizes)]

    # Pre-allocate data structures for holding cluster info and points
    point_clusters = zeros(Int, num_points)         # Cluster indices of each point
    point_projections = zeros(num_points, num_dims) # Point projections on cluster-supporting lines
    points = zeros(num_points, num_dims)            # Final points to be generated

    # Loop through clusters and create points for each one
    for i in 1:num_clusters

        # Start and end indexes for points in current cluster
        idx_start = cumsum_points[i] + 1
        idx_end = cumsum_points[i + 1]

        # Update cluster indices of each point
        point_clusters[idx_start:idx_end] .= i

        # Determine distance of point projections from the center of the line
        ptproj_dist_fn_center = pointproj_fn(cluster_lengths[i], cluster_sizes[i], rng)

        # Determine coordinates of point projections on the line using the
        # parametric line equation (this works since cluster direction is normalized)
        point_projections[idx_start:idx_end, :] = points_on_line(
            cluster_centers[i, :], cluster_directions[i, :], ptproj_dist_fn_center)

        # Determine points from their projections on the line
        points[idx_start:idx_end, :] = pt_from_proj_fn(
            point_projections[idx_start:idx_end, :],
            lateral_disp,
            cluster_lengths[i],
            cluster_directions[i, :],
            cluster_centers[i, :];
            rng=rng)

    end

    return (
        points = points,
        point_clusters = point_clusters,
        point_projections = point_projections,
        cluster_sizes = cluster_sizes,
        cluster_centers = cluster_centers,
        cluster_directions = cluster_directions,
        cluster_angles = cluster_angles,
        cluster_lengths = cluster_lengths)

end

# ############################################################################ #
# ########################### Core functions ################################# #
# ############################################################################ #

"""
    points_on_line(
        center::AbstractArray{<:Real, 1},
        direction::AbstractArray{<:Real, 1},
        dist_center::AbstractArray{<:Real, 1}
    ) -> AbstractArray{<:Real, 2}

Determine coordinates of points on a line with `center` and `direction`, based
on the distances from the center given in `dist_center`.

This works by using the vector formulation of the line equation assuming
`direction` is a ``n``-dimensional unit vector. In other words, considering
``\\mathbf{d}=`` `direction` (``n \\times 1``), ``\\mathbf{c}=`` `center` (``
n \\times 1``), and ``\\mathbf{w}=`` `dist_center` (``p \\times 1``), the
coordinates of points on the line are given by:

```math
\\mathbf{P}=\\mathbf{1}\\,\\mathbf{c}^T + \\mathbf{w}\\mathbf{d}^T
```

where ``\\mathbf{P}`` is the ``p \\times n`` matrix of point coordinates on the
line, and ``\\mathbf{1}`` is a ``p \\times 1`` vector with all entries equal to 1.

# Examples
```jldoctest
julia> points_on_line([5.0,5.0], [1.0,0.0], -4:2:4) # 2D, 5 points
5×2 Matrix{Float64}:
 1.0  5.0
 3.0  5.0
 5.0  5.0
 7.0  5.0
 9.0  5.0

julia> points_on_line([-2.0,0,0,2.0], [0,0,-1.0,0], [10,-10]) # 4D, 2 points
2×4 Matrix{Float64}:
 -2.0  0.0  -10.0  2.0
 -2.0  0.0   10.0  2.0
```
"""
function points_on_line(
    center::AbstractArray{<:Real, 1},
    direction::AbstractArray{<:Real, 1},
    dist_center::AbstractArray{<:Real, 1}
)::AbstractArray{<:Real, 2}

    return center' .+ dist_center * direction'

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
3-element Vector{Float64}:
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
    rand_unit_vector(
        num_dims::Integer;
        rng::AbstractRNG = Random.GLOBAL_RNG
    ) ->  AbstractArray{<:Real, 1}

Get a random unit vector with `num_dims` dimensions.

# Examples
```jldoctest; setup = :(Random.seed!(111))
julia> v = rand_unit_vector(4) # 4D
4-element Vector{Float64}:
 -0.24033021128704707
 -0.032103799230189585
  0.04223910709972599
 -0.9692402145232775

julia> norm(v) # Check vector magnitude is 1 (needs LinearAlgebra package)
1.0

julia> rand_unit_vector(2; rng=MersenneTwister(33)) # 2D, reproducible
2-element Vector{Float64}:
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
2-element Vector{Float64}:
 -0.4999999999999999
  0.8660254037844387
```
"""
function rand_vector_at_angle(
    u::AbstractArray{<:Real, 1},
    angle::Real;
    rng::AbstractRNG = Random.GLOBAL_RNG
)::AbstractArray{<:Real, 1}

    if abs(angle) ≈ pi/2 && length(u) > 1
        return rand_ortho_vector(u; rng=rng)
    elseif -pi/2 < angle < pi/2 && length(u) > 1
        return normalize(u + rand_ortho_vector(u; rng=rng) * tan(angle))
    else
        # For |θ| > π/2 or the 1D case, simply return a random vector
        return rand_unit_vector(length(u); rng=rng)
    end

end

# ############################################################################ #
# ##################### Algorithm module functions ########################### #
# ############################################################################ #

"""
    angle_deltas(
        num_clusters::Integer,
        angle_disp::Real;
        rng::AbstractRNG = Random.GLOBAL_RNG
    ) -> AbstractArray{<:Real, 1}

Determine the angles between the average cluster direction and the
cluster-supporting lines. These angles are obtained from a wrapped normal
distribution (μ=0, σ=`angle_disp`) with support in the interval
``\\left[-\\pi/2,\\pi/2\\right]``. Note this is different from the standard
wrapped normal distribution, the support of which is given by the interval
``\\left[-\\pi,\\pi\\right]``.

The `angle_disp` parameter must be specified in radians and results are given in
radians in the interval ``\\left[-\\pi/2,\\pi/2\\right]``.

This function is not exported by the package and must be prefixed with `CluGen`
if invoked by user code.

# Examples
```jldoctest; setup = :(Random.seed!(111))
julia> CluGen.angle_deltas(4, pi/128)
4-element Vector{Float64}:
  0.01888791855096079
 -0.027851298321307266
  0.03274154825228485
 -0.004475798744567242

julia> CluGen.angle_deltas(3, pi/32; rng=MersenneTwister(987)) # Reproducible
3-element Vector{Float64}:
  0.08834204306583336
  0.014678748091943444
 -0.15202559427536264
```
"""
function angle_deltas(
    num_clusters::Integer,
    angle_disp::Real;
    rng::AbstractRNG = Random.GLOBAL_RNG
)::AbstractArray{<:Real, 1}

    # Helper function to return the minimum valid angle
    function minangle(a)
        a = atan(sin(a), cos(a))
        if a > π/2
            a -= π
        elseif a < -π/2
            a += π
        end
        return a
    end

    # Get random angle differences using the normal distribution
    angles = angle_disp .* randn(rng, num_clusters)

    # Make sure angle differences are within interval [-π/2, π/2]
    map!(minangle, angles, angles)

    return angles

end

"""
    clucenters(
        num_clusters::Integer,
        clu_sep::AbstractArray{<:Real, 1},
        clu_offset::AbstractArray{<:Real, 1};
        rng::AbstractRNG = Random.GLOBAL_RNG
    ) ->  AbstractArray{<:Real}

Determine cluster centers using the uniform distribution, taking into account the
number of clusters (`num_clusters`) and the average cluster separation (`clu_sep`).

More specifically, let ``c=`` `num_clusters`, ``\\mathbf{s}=`` `clu_sep`,
``\\mathbf{o}=`` `clu_offset`, ``n=`` `length(clu_sep)` (i.e., number of dimensions).
Cluster centers are obtained according to the following equation:

```math
\\mathbf{C}=c\\mathbf{U} \\cdot \\operatorname{diag}(\\mathbf{s}) + \\mathbf{1}\\,\\mathbf{o}^T
```

where ``\\mathbf{C}`` is the ``c \\times n`` matrix of cluster centers,
``\\mathbf{U}`` is an ``c \\times n`` matrix of random values drawn from the
uniform distribution between -0.5 and 0.5, and ``\\mathbf{1}`` is an ``c \\times
1`` vector with all entries equal to 1.

This function is not exported by the package and must be prefixed with `CluGen`
if invoked by user code.

# Examples
```jldoctest; setup = :(Random.seed!(123))
julia> CluGen.clucenters(4, [10, 50], [0, 0]) # 2D
4×2 Matrix{Float64}:
 10.7379   -37.3512
 17.6206    32.511
  6.95835   17.2044
 -4.18188  -89.5734

julia> CluGen.clucenters(5, [20, 10, 30], [10, 10, -10]) # 3D
5×3 Matrix{Float64}:
 -13.136    15.8746      2.34767
 -29.1129   -0.715105  -46.6028
 -23.6334    8.19236    20.879
   7.30168  -1.20904   -41.2033
  46.5412    7.3284    -42.8401

julia> CluGen.clucenters(3, [100], [0]; rng=MersenneTwister(121)) # 1D, reproducible
3×1 Matrix{Float64}:
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
    CluGen.clupoints_n_1(
        projs::AbstractArray{<:Real, 2},
        lat_disp::Real,
        line_len::Real,
        clu_dir::AbstractArray{<:Real, 1},
        clu_ctr::AbstractArray{<:Real, 1};
        rng::AbstractRNG = Random.GLOBAL_RNG
    ) -> AbstractArray{<:Real}

Generate points from their ``n``-dimensional projections on a cluster-supporting
line, placing each point on a hyperplane orthogonal to that line and centered at
the point's projection, using the normal distribution (μ=0, σ=`lat_disp`).

This function's main intended use is by the [`clugen()`](@ref) function,
generating the final points when the `point_dist_fn` parameter is set to `"n-1"`.

This function is not exported by the package and must be prefixed with `CluGen`
if invoked by user code.

# Arguments
- `projs`: Point projections on the cluster-supporting line.
- `lat_disp`: Standard deviation for the normal distribution, i.e., cluster lateral
  dispersion.
- `line_len`: Length of cluster-supporting line (ignored).
- `clu_dir`: Direction of the cluster-supporting line (unit vector).
- `clu_ctr`: Center position of the cluster-supporting line (ignored).
- `rng`: An optional pseudo-random number generator for reproducible executions.

# Examples
```jldoctest
julia> projs = points_on_line([5.0,5.0], [1.0,0.0], -4:2:4) # Get 5 point projections on a 2D line
5×2 Matrix{Float64}:
 1.0  5.0
 3.0  5.0
 5.0  5.0
 7.0  5.0
 9.0  5.0

julia> CluGen.clupoints_n_1(projs, 0.5, 1.0, [1,0], [0,0]; rng=MersenneTwister(123))
5×2 Matrix{Float64}:
 1.0  5.59513
 3.0  3.97591
 5.0  4.42867
 7.0  5.22971
 9.0  4.80166
```
"""
function clupoints_n_1(
    projs::AbstractArray{<:Real, 2},
    lat_disp::Real,
    line_len::Real,
    clu_dir::AbstractArray{<:Real, 1},
    clu_ctr::AbstractArray{<:Real, 1};
    rng::AbstractRNG = Random.GLOBAL_RNG
)::AbstractArray{<:Real}

    # Define function to get distances from points to their projections on the
    # line (i.e., using the normal distribution)
    dist_fn = (clu_num_points, ldisp, rg) -> ldisp .* randn(rg, clu_num_points, 1)

    # Use clupoints_n_1_template() to do the heavy lifting
    return clupoints_n_1_template(projs, lat_disp, clu_dir, dist_fn; rng=rng)

end

"""
    GluGen.clupoints_n(
        projs::AbstractArray{<:Real, 2},
        lat_disp::Real,
        line_len::Real,
        clu_dir::AbstractArray{<:Real, 1},
        clu_ctr::AbstractArray{<:Real, 1};
        rng::AbstractRNG = Random.GLOBAL_RNG
    ) -> AbstractArray{<:Real}

Generate points from their ``n``-dimensional projections on a cluster-supporting
line, placing each point around its projection using the normal distribution
(μ=0, σ=`lat_disp`).

This function's main intended use is by the [`clugen()`](@ref) function,
generating the final points when the `point_dist_fn` parameter is set to `"n"`.

This function is not exported by the package and must be prefixed with `CluGen`
if invoked by user code.

# Arguments
- `projs`: Point projections on the cluster-supporting line.
- `lat_disp`: Standard deviation for the normal distribution, i.e., cluster lateral
  dispersion.
- `line_len`: Length of cluster-supporting line (ignored).
- `clu_dir`: Direction of the cluster-supporting line.
- `clu_ctr`: Center position of the cluster-supporting line (ignored).
- `rng`: An optional pseudo-random number generator for reproducible executions.

# Examples
```jldoctest
julia> projs = points_on_line([5.0,5.0], [1.0,0.0], -4:2:4) # Get 5 point projections on a 2D line
5×2 Matrix{Float64}:
 1.0  5.0
 3.0  5.0
 5.0  5.0
 7.0  5.0
 9.0  5.0

julia> CluGen.clupoints_n(projs, 0.5, 1.0, [1,0], [0,0]; rng=MersenneTwister(123))
5×2 Matrix{Float64}:
 1.59513  4.66764
 4.02409  5.49048
 5.57133  4.96226
 7.22971  5.13691
 8.80166  4.90289
```
"""
function clupoints_n(
    projs::AbstractArray{<:Real, 2},
    lat_disp::Real,
    line_len::Real,
    clu_dir::AbstractArray{<:Real, 1},
    clu_ctr::AbstractArray{<:Real, 1};
    rng::AbstractRNG = Random.GLOBAL_RNG
)::AbstractArray{<:Real}

    # Number of dimensions
    num_dims = length(clu_dir)

    # Number of points in this cluster
    clu_num_points = size(projs, 1)

    # Get random displacement vectors for each point projection
    displ = lat_disp .* randn(rng, clu_num_points, num_dims)

    # Add displacement vectors to each point projection
    points = projs + displ

    return points
end

"""
    clusizes(
        num_clusters::Integer,
        num_points::Integer,
        allow_empty::Bool;
        rng::AbstractRNG = Random.GLOBAL_RNG
    ) -> AbstractArray{<:Integer, 1}

Determine cluster sizes, i.e., the number of points in each cluster, using the
normal distribution (μ=`num_points`/`num_clusters`, σ=μ/3), and then assuring
that the final cluster sizes add up to `num_points` via the
[`CluGen.fix_num_points!()`](@ref) function.

This function is not exported by the package and must be prefixed with `CluGen`
if invoked by user code.

# Examples
```jldoctest; setup = :(Random.seed!(90))
julia> CluGen.clusizes(4, 6, true)
4-element Vector{Int64}:
 1
 0
 3
 2

julia> CluGen.clusizes(4, 100, false)
4-element Vector{Int64}:
 29
 26
 24
 21

julia> CluGen.clusizes(5, 500, true; rng=MersenneTwister(123)) # Reproducible
5-element Vector{Int64}:
 108
 129
 107
  89
  67
```
"""
function clusizes(
    num_clusters::Integer,
    num_points::Integer,
    allow_empty::Bool;
    rng::AbstractRNG = Random.GLOBAL_RNG
)::AbstractArray{<:Integer, 1}

    # Determine number of points in each cluster using the normal distribution

    # Consider the mean an equal division of points between clusters
    mean = num_points / num_clusters
    # The standard deviation is such that the interval [0, 2 * mean] will contain
    # ≈99.7% of cluster sizes
    std = mean / 3

    # Determine points with the normal distribution
    clu_num_points = std .* randn(rng, num_clusters) .+ mean

    # Set negative values to zero
    map!((x) -> x > 0 ? x : 0, clu_num_points, clu_num_points)

    # Fix imbalances, so that num_points is respected
    if sum(clu_num_points) > 0 # Be careful not to divide by zero
        clu_num_points .*=  num_points / sum(clu_num_points)
    end

    # Round the real values to integers since a cluster sizes is represented by an integer
    clu_num_points = round.(Integer, clu_num_points)

    # Make sure total points is respected, which may not be the case at this time due
    # to rounding
    fix_num_points!(clu_num_points, num_points)

    # If empty clusters are not allowed, make sure there aren't any
    if !allow_empty
        fix_empty!(clu_num_points)
    end

    return clu_num_points

end

"""
    llengths(
        num_clusters::Integer,
        llength::Real,
        llength_disp::Real;
        rng::AbstractRNG = Random.GLOBAL_RNG
    ) -> AbstractArray{<:Real, 1}

Determine length of cluster-supporting lines using the folded normal distribution
(μ=`llength`, σ=`llength_disp`).

This function is not exported by the package and must be prefixed with `CluGen`
if invoked by user code.

# Examples
```jldoctest; setup = :(Random.seed!(123))
julia> CluGen.llengths(5, 10, 3)
5-element Vector{Float64}:
 13.57080364295883
 16.14453912336772
 13.427952708601596
 11.37824686122124
  8.809962762114331

julia> CluGen.llengths(3, 100, 60; rng=MersenneTwister(111)) # Reproducible
3-element Vector{Float64}:
 146.1737820482947
  31.914161161783426
 180.04064126207396
```
"""
function llengths(
    num_clusters::Integer,
    llength::Real,
    llength_disp::Real;
    rng::AbstractRNG = Random.GLOBAL_RNG
)::AbstractArray{<:Real, 1}

    return abs.(llength .+ llength_disp .* randn(rng, num_clusters))

end

# ############################################################################ #
# #################### Algorithm module helper functions ##################### #
# ############################################################################ #

"""
    CluGen.clupoints_n_1_template(
        projs::AbstractArray{<:Real, 2},
        lat_disp::Real,
        clu_dir::AbstractArray{<:Real, 1},
        dist_fn::Function;
        rng::AbstractRNG = Random.GLOBAL_RNG
    ) -> AbstractArray{<:Real}

Generate points from their ``n``-dimensional projections on a cluster-supporting
line, placing each point on a hyperplane orthogonal to that line and centered at
the point's projection. The function specified in `dist_fn` is used to perform
the actual placement.

This function is used internally by [`CluGen.clupoints_n_1()`](@ref) and may be
useful for constructing user-defined final point placement strategies for the
`point_dist_fn` parameter of the main [`clugen()`](@ref) function.

This function is not exported by the package and must be prefixed with `CluGen`
if invoked by user code.

# Arguments
- `projs`: Point projections on the cluster-supporting line.
- `lat_disp`: Dispersion of points from their projection.
- `clu_dir`: Direction of the cluster-supporting line (unit vector).
- `dist_fn`: Function to place points on a second line, orthogonal to the first.
  The functions accepts as parameters the number of points in the current
  cluster, the `lateral_disp` parameter (the same passed to the
  [`clugen()`](@ref) function), and a random number generator, returning a
  vector containing the distance of each point to its projection on the
  cluster-supporting line.
- `rng`: An optional pseudo-random number generator for reproducible executions.
"""
function clupoints_n_1_template(
    projs::AbstractArray{<:Real, 2},
    lat_disp::Real,
    clu_dir::AbstractArray{<:Real, 1},
    dist_fn::Function;
    rng::AbstractRNG = Random.GLOBAL_RNG
)::AbstractArray{<:Real}

    # Number of dimensions
    num_dims = length(clu_dir)

    # Number of points in this cluster
    clu_num_points = size(projs, 1)

    # Get distances from points to their projections on the line
    points_dist = dist_fn(clu_num_points, lat_disp, rng)

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
    fix_empty!(
        clu_num_points::AbstractArray{<:Integer, 1},
        allow_empty::Bool = false
    ) -> AbstractArray{<:Integer, 1}

Certifies that, given enough points, no clusters are left empty. This is done by
removing a point from the largest cluster and adding it to an empty cluster while
there are empty clusters. If the total number of points is smaller than the number
of clusters (or if the `allow_empty` parameter is set to `true`), this function
does nothing.

This function is used internally by [`CluGen.clusizes()`](@ref) and might be
useful for custom cluster sizing implementations given as the `clusizes_fn`
parameter of the main [`clugen()`](@ref) function.

This function is not exported by the package and must be prefixed with `CluGen`
if invoked by user code.
"""
function fix_empty!(
    clu_num_points::AbstractArray{<:Integer, 1},
    allow_empty::Bool = false
)::AbstractArray{<:Integer, 1}

    # If the allow_empty parameter is set to true, don't do anything and return
    # immediately; this is useful for quick `clusizes_fn` one-liners
    allow_empty && return clu_num_points

    # Find empty clusters
    empty_clusts = findall(x -> x == 0, clu_num_points)

    # If there are empty clusters and enough points for all clusters...
    if length(empty_clusts) > 0 && sum(clu_num_points) >= length(clu_num_points)

        # Go through the empty clusters...
        for i0 in empty_clusts

            # ...get a point from the largest cluster and assign it to the
            # current empty cluster
            imax = argmax(clu_num_points)
            clu_num_points[imax] -= 1
            clu_num_points[i0] += 1

        end
    end

    return clu_num_points

end

"""
    fix_num_points!(
        clu_num_points::AbstractArray{<:Integer, 1},
        num_points::Integer
    ) -> AbstractArray{<:Integer, 1}

Certifies that the values in the `clu_num_points` array, i.e. the number of
points in each cluster, add up to `num_points`. If this is not the case, the
`clu_num_points` array is modified in-place, incrementing the value corresponding
to the smallest cluster while `sum(clu_num_points) < num_points`, or decrementing
the value corresponding to the largest cluster while
`sum(clu_num_points) > num_points`.

This function is used internally by [`CluGen.clusizes()`](@ref) and might be
useful for custom cluster sizing implementations given as the `clusizes_fn`
parameter of the main [`clugen()`](@ref) function.

This function is not exported by the package and must be prefixed with `CluGen`
if invoked by user code.
"""
function fix_num_points!(
    clu_num_points::AbstractArray{<:Integer, 1},
    num_points::Integer
)::AbstractArray{<:Integer, 1}

    while sum(clu_num_points) < num_points
        imin = argmin(clu_num_points)
        clu_num_points[imin] += 1
    end
    while sum(clu_num_points) > num_points
        imax = argmax(clu_num_points)
        clu_num_points[imax] -= 1
    end

    return clu_num_points

end

end # Module
