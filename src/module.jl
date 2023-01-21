# Copyright (c) 2020-2023 Nuno Fachada, Diogo de Andrade, and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

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
```jldoctest; setup = :(using Random; Random.seed!(111))
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
    num_clusters::Integer, angle_disp::Real; rng::AbstractRNG=Random.GLOBAL_RNG
)::AbstractArray{<:Real,1}

    # Helper function to return the minimum valid angle
    function minangle(a)
        a = atan(sin(a), cos(a))
        if a > π / 2
            a -= π
        elseif a < -π / 2
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
```jldoctest; setup = :(using Random; Random.seed!(123))
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
    clu_sep::AbstractArray{<:Real,1},
    clu_offset::AbstractArray{<:Real,1};
    rng::AbstractRNG=Random.GLOBAL_RNG,
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
```jldoctest; setup = :(using Random)
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
    projs::AbstractArray{<:Real,2},
    lat_disp::Real,
    line_len::Real,
    clu_dir::AbstractArray{<:Real,1},
    clu_ctr::AbstractArray{<:Real,1};
    rng::AbstractRNG=Random.GLOBAL_RNG,
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
```jldoctest; setup = :(using Random)
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
    projs::AbstractArray{<:Real,2},
    lat_disp::Real,
    line_len::Real,
    clu_dir::AbstractArray{<:Real,1},
    clu_ctr::AbstractArray{<:Real,1};
    rng::AbstractRNG=Random.GLOBAL_RNG,
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
```jldoctest; setup = :(using Random; Random.seed!(90))
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
    rng::AbstractRNG=Random.GLOBAL_RNG,
)::AbstractArray{<:Integer,1}

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
        clu_num_points .*= num_points / sum(clu_num_points)
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
```jldoctest; setup = :(using Random; Random.seed!(123))
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
    rng::AbstractRNG=Random.GLOBAL_RNG,
)::AbstractArray{<:Real,1}
    return abs.(llength .+ llength_disp .* randn(rng, num_clusters))
end
