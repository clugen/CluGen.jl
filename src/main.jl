# Copyright (c) 2020-2023 Nuno Fachada, Diogo de Andrade, and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

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
            :points,      # Array{<:Real,2}
            :clusters,    # Array{<:Integer,1}
            :projections, # Array{<:Real,2}
            :sizes,       # Array{<:Integer,1}
            :centers,     # Array{<:Real,2}
            :directions,  # Array{<:Real,2}
            :lengths      # Array{<:Real,1}
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
- `clusters`: A `num_points` x 1 vector indicating which cluster
  each point in `points` belongs to.
- `projections`: A `num_points` x `num_dims` matrix with the point
  projections on the cluster-supporting lines.
- `sizes`: A `num_clusters` x 1 vector with the number of
  points in each cluster.
- `centers`: A `num_clusters` x `num_dims` matrix with the coordinates
  of the cluster centers.
- `directions`: A `num_clusters` x `num_dims` matrix with the direction
  of each cluster-supporting line.
- `angles`: A `num_clusters` x 1 vector with the angles between the
  cluster-supporting lines and the main direction.
- `lengths`: A `num_clusters` x 1 vector with the lengths of the
  cluster-supporting lines.

Note that if a custom function was given in the `clusizes_fn` parameter, it is
possible that `num_points` may have a different value than what was specified in
`clugen`'s `num_points` parameter.

# Examples
```jldoctest; setup = :(using Random; Random.seed!(123))
julia> # Create 5 clusters in 3D space with a total of 10000 points...

julia> out = clugen(3, 5, 10000, [0.5, 0.5, 0.5], pi/16, [10, 10, 10], 10, 1, 2);

julia> out.centers # What are the cluster centers?
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

Check the [Examples](@ref) section for a number of illustrative examples on how to
use the `clugen()` function. The [Theory](@ref) section provides more information
on how the function works and the impact each parameter has on the final result.
"""
function clugen(
    num_dims::Integer,
    num_clusters::Integer,
    num_points::Integer,
    direction::AbstractArray{<:Real,1},
    angle_disp::Real,
    cluster_sep::AbstractArray{<:Real,1},
    llength::Real,
    llength_disp::Real,
    lateral_disp::Real;
    allow_empty::Bool=false,
    cluster_offset::Union{AbstractArray{<:Real,1},Nothing}=nothing,
    proj_dist_fn::Union{String,<:Function}="norm",
    point_dist_fn::Union{String,<:Function}="n-1",
    clusizes_fn::Function=clusizes,
    clucenters_fn::Function=clucenters,
    llengths_fn::Function=llengths,
    angle_deltas_fn::Function=angle_deltas,
    rng::AbstractRNG=Random.GLOBAL_RNG,
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
        throw(
            ArgumentError(
                "Length of `direction` must be equal to `num_dims` " *
                "($dir_len != $num_dims)",
            ),
        )
    end

    # If allow_empty is false, make sure there are enough points to distribute
    # by the clusters
    if !allow_empty && num_points < num_clusters
        throw(
            ArgumentError(
                "A total of $num_points points is not enough for " *
                "$num_clusters non-empty clusters",
            ),
        )
    end

    # Check that cluster_sep has num_dims dimensions
    clusep_len = length(cluster_sep)
    if clusep_len != num_dims
        throw(
            ArgumentError(
                "Length of `cluster_sep` must be equal to `num_dims` " *
                "($clusep_len != $num_dims)",
            ),
        )
    end

    # If given, cluster_offset must have the correct number of dimensions,
    # if not given then it will be a num_dims x 1 vector of zeros
    if cluster_offset === nothing
        cluster_offset = zeros(num_dims)
    elseif length(cluster_offset) != num_dims
        throw(
            ArgumentError(
                "Length of `cluster_offset` must be equal to `num_dims` " *
                "($(length(cluster_offset)) != $num_dims)",
            ),
        )
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
        throw(
            ArgumentError(
                "`proj_dist_fn` has to be either \"norm\", \"unif\" or user-defined function",
            ),
        )
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
        throw(
            ArgumentError(
                "point_dist_fn has to be either \"n-1\", \"n\" or a user-defined function"
            ),
        )
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
    cluster_directions =
        hcat([rand_vector_at_angle(direction, a; rng=rng) for a in cluster_angles]...)'

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
            cluster_centers[i, :], cluster_directions[i, :], ptproj_dist_fn_center
        )

        # Determine points from their projections on the line
        points[idx_start:idx_end, :] = pt_from_proj_fn(
            point_projections[idx_start:idx_end, :],
            lateral_disp,
            cluster_lengths[i],
            cluster_directions[i, :],
            cluster_centers[i, :];
            rng=rng,
        )
    end

    return (
        points=points,
        clusters=point_clusters,
        projections=point_projections,
        sizes=cluster_sizes,
        centers=cluster_centers,
        directions=cluster_directions,
        angles=cluster_angles,
        lengths=cluster_lengths,
    )
end