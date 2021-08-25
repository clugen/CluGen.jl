# Copyright (c) 2020, 2021 Nuno Fachada, Diogo de Andrade, and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

"""
Julia implementation of clugen.
"""
module CluGen

using LinearAlgebra
using Random

export clusizes
export clucenters
export get_points_from_line
export rand_unit_vector
export rand_ortho_vector
export rand_vector_at_angle
export clugen

"""
    clusizes()

Determine cluster sizes using the folded normal distribution, by default with
μ=1, σ=0.3.

Note that dist_fun should return a n x 1 array of non-negative numbers where
n is the desired number of clusters.
"""
function clusizes(
    num_clusters::Integer,
    total_points::Integer,
    allow_empty::Bool;
    mean = 1::Number,
    sigma = 0.3::Number,
    rng::AbstractRNG = Random.GLOBAL_RNG
)::AbstractArray{<:Number, 1}

    # Determine number of points in each cluster using the folded-normal
    # distribution (μ=1, σ=0.3)
    clu_num_points = abs.(sigma .* randn(rng, num_clusters) .+ mean)
    clu_num_points = clu_num_points / sum(clu_num_points)

    # For consistency with other clugen implementations, rounding ties move away from zero
    clu_num_points = round.(Int, total_points * clu_num_points, RoundNearestTiesAway)

    # Make sure total points is respected
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
    clucenters()

Determine cluster centers using the uniform distribution between -0.5 and 0.5.
"""
function clucenters(
    num_clusters::Integer,
    clu_sep::AbstractArray{<:Number, 1},
    clu_offset::AbstractArray{<:Number, 1};
    rng::AbstractRNG = Random._GLOBAL_RNG
)::AbstractArray{<:Number}

    # Obtain a num_clusters x num_dims matrix of uniformly distributed values
    # between -0.5 and 0.5
    x = rand(rng, num_clusters, length(clu_sep)) .- 0.5

    return num_clusters .* x * Diagonal(clu_sep) .+ clu_offset'
end

"""
Function which returns a random unit vector with `num_dims` dimensions.
"""
function rand_unit_vector(
    num_dims::Integer;
    rng::AbstractRNG = Random.GLOBAL_RNG
)::AbstractArray{<:Number, 1}

    r = rand(rng, num_dims) .- 0.5
    normalize!(r)
    return r

end

"""
Function which returns a random normalized vector orthogonal to `u`

`u` is expected to be a unit vector
"""
function rand_ortho_vector(
    u::AbstractArray{<:Number, 1};
    rng::AbstractRNG = Random.GLOBAL_RNG
)::AbstractArray{<:Number, 1}

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
Function which returns a random vector that is at an angle of `angle` radians
from vector `u`.

`u` is expected to be a unit vector
`angle` should be in radians
"""
function rand_vector_at_angle(
    u::AbstractArray{<:Number, 1},
    angle::Number;
    rng::AbstractRNG = Random.GLOBAL_RNG
)::AbstractArray{<:Number, 1}

    if -pi/2 < angle < pi/2 && length(u) > 1
        return normalize(u + rand_ortho_vector(u; rng=rng) * tan(angle))
    else
        return rand_unit_vector(length(u); rng=rng)
    end

end

"""
    get_points_from_line()

Determine coordinates of points on a line with `center` and `direction`, based
on the distances from the center given in `dist_center`.

This works by using the parametric line equation assuming `direction` is normalized.
"""
function get_points_from_line(
    center::AbstractArray{<:Number, 1},
    direction::AbstractArray{<:Number, 1},
    dist_center::AbstractArray{<:Number, 1},
)::AbstractArray{<:Number, 2}

    return center' .+ dist_center * direction'

end

"""
    clupoints_d_1()

Function which generates points for a cluster from their projections in n-D,
placing points on a second line perpendicular to the cluster-supporting line
using a normal distribution centered at their intersection.

- `projs` are the point projections.
- `lat_std` is the lateral standard deviation or cluster "fatness".
- `clu_dir` is the cluster direction.
- `clu_ctr` is the cluster-supporting line center position (ignored).
- `rng` is an optional pseudo-random number generator.
"""
function clupoints_d_1(
    projs::AbstractArray{<:Number, 2},
    lat_std::Number,
    clu_dir::AbstractArray{<:Number, 1},
    clu_ctr::AbstractArray{<:Number, 1},
    rng::AbstractRNG = Random.GLOBAL_RNG
)::AbstractArray{<:Number}

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
    clupoints_d()

Function which generates points for a cluster from their projections in n-D,
placing points using a multivariate normal distribution centered at the point
projection.

- `projs` are the point projections.
- `lat_std` is the lateral standard deviation or cluster "fatness".
- `clu_dir` is the cluster direction.
- `clu_ctr` is the cluster-supporting line center position (ignored).
- `rng` is an optional pseudo-random number generator.
"""
function clupoints_d(
    projs::AbstractArray{<:Number, 2},
    lat_std::Number,
    clu_dir::AbstractArray{<:Number, 1},
    clu_ctr::AbstractArray{<:Number, 1},
    rng::AbstractRNG = Random.GLOBAL_RNG
)::AbstractArray{<:Number}

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
    clugen()

Create clusters.

Example using clusizes_fn parameter for specifying all equal cluster sizes (note
this does not verify if clusters are empty nor if total points is actually respected)

    clusizes_fn=(nclu,tp,ae;rng=Random.GLOBAL_RNG)-> tp ÷ nclu .* ones(Integer, nclu)

"""
function clugen(
    num_dims::Integer,
    num_clusters::Integer,
    total_points::Integer,
    direction::AbstractArray{<:Number, 1},
    angle_std::Number,
    cluster_sep::AbstractArray{<:Number, 1},
    line_length::Number,
    line_length_std::Number,
    lateral_std::Number;
    allow_empty::Bool = false,
    cluster_offset::Union{AbstractArray{<:Number, 1}, Nothing} = nothing,
    point_dist::Union{String, <:Function} = "norm",
    point_offset::Union{String, <:Function} = "d-1",
    clusizes_fn::Union{Function, Nothing} = nothing,
    clucenters_fn::Union{Function, Nothing} = nothing,
    rng::AbstractRNG = Random.GLOBAL_RNG)

    # ############### #
    # Validate inputs #
    # ############### #

    # Check that number of dimensions is > 0
    if num_dims < 1
        throw(ArgumentError("Number of dimensions, `num_dims`, must be > 0"))
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

    # If given, cluster_offset must have the correct number of dimensions,
    # if not given then it will be a num_dims x 1 vector of zeros
    if cluster_offset === nothing
        cluster_offset = zeros(num_dims)
    elseif length(cluster_offset) != num_dims
        throw(ArgumentError(
            "Length of `cluster_offset` must be equal to `num_dims` " *
            "($(length(cluster_offset)) != $num_dims)"))
    end

    # Check that cluster_sep has num_dims dimensions
    clusep_len = length(cluster_sep)
    if clusep_len != num_dims
        throw(ArgumentError(
            "Length of `cluster_sep` must be equal to `num_dims` " *
            "($clusep_len != $num_dims)"))
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

    # If no clusizes_fn function was specified, use the default provided with
    # the module
    if clusizes_fn === nothing
        clusizes_fn = clusizes
    end

    # If no clucenters_fn function was specified, use the default provided with
    # the module
    if clucenters_fn === nothing
        clucenters_fn = clucenters
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
    # Line lengths are drawn from the folded normal distribution
    lengths = abs.(line_length .+ line_length_std .* randn(rng, num_clusters))

    # Obtain angles between main direction and cluster-supporting lines
    # using the normal distribution (mean=0, std=angle_std)
    angles = angle_std .* randn(rng, num_clusters)

    # Determine normalized cluster direction
    clu_dirs = hcat([rand_vector_at_angle(direction, a; rng=rng) for a in angles]...)'

    # ################################# #
    # Determine points for each cluster #
    # ################################# #

    # Aux. vector with cumulative sum of number of points in each cluster
    cumsum_points = [0; cumsum(clu_num_points)]

    # Pre-allocate data structures for holding cluster info and points
    clu_pts_idx = zeros(total_points)           # Cluster indices of each point
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
        points_proj[idx_start:idx_end, :] = get_points_from_line(
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
        points_per_cluster = clu_num_points,
        total_points = sum(clu_num_points),
        centers = clu_centers,
        line_lengths = lengths,
        angles = angles,
        dirs = clu_dirs,
        clu_pts_idx = clu_pts_idx,
        projs = points_proj)

end

end # Module
