# Copyright (c) 2020, 2021 Nuno Fachada, Diogo de Andrade, and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

"""
Julia implementation of clugen.
"""
module CluGen

using Distributions # TODO Remove this dependency
using LinearAlgebra
using Random

export clugen

struct Cluster
    center
    direction
    length
end

function getRandomNormalizedVector(numDims::Integer)
    return normalize(rand(Float64, numDims) .- 0.5)
end

function getPerpendicularVector(u)
    # Find a perpendicular vector to u
    numDims = size(u)[1]

    # - Choose a random, non-parallel vector to cluster direction
    v = zeros(numDims)
    while true
        v = getRandomNormalizedVector(numDims)
        if (abs(dot(v,u)) < (1 - eps()))
            break
        end
    end
    # Obtain normalized vector orthogonal to u using Gram-Schmidt process
    p = normalize(v - dot(v, u) / dot(u, u) * u)

    return p
end

function generatePoint(numDims::Integer,
                       cluster::Cluster,
                       lenghtDistribution::Distribution,
                       lateralStd::Number,
                       pointOffset::String)

    # Get the random shifts coeficients
    ld = rand(lenghtDistribution)
    ll = lateralStd * randn()

    # Compute point
    pt = cluster.center
    pt += cluster.direction * ld * cluster.length

    if (pointOffset == "nd")
        p = getRandomNormalizedVector(numDims) * ll
    elseif (pointOffset == "(n-1)d")
        p = getPerpendicularVector(cluster.direction)
    end

    pt += p * ll

    return pt
end

"""
    clusizes()

Determine cluster sizes.

Note that dist_fun should return a n x 1 array of non-negative numbers where
n is the desired number of clusters.
"""
function clusizes(
    total_points::Integer,
    allow_empty::Bool,
    dist_fun::Function)

    # Determine number of points in each cluster
    clu_num_points = dist_fun()
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

Determine cluster centers.

Note that dist_fun should return a num_clusters * num_dims matrix.
"""
function clucenters(
    num_clusters::Integer,
    cluster_sep::AbstractArray{<:Number, 1},
    offset::AbstractArray{<:Number, 1},
    dist_fun::Function)

    return num_clusters .* dist_fun() * Diagonal(cluster_sep) .+ offset'
end

"""
Function which returns a random unit vector with `num_dims` dimensions.
"""
function rand_unit_vector(
    num_dims::Integer;
    rng::AbstractRNG = Random.GLOBAL_RNG)

    r = rand(rng, num_dims) .- 0.5
    normalize!(r)
    return r

end

"""
Function which returns a random normalized vector orthogonal to `u`

`u` is expected to be a unit vector
"""
function rand_ortho_vector(
    u::AbstractArray{<:Number};
    rng::AbstractRNG = Random.GLOBAL_RNG)

    # Variable for placing random non-parallel vector
    r = nothing

    # Find a random, non-parallel vector to u
    while true

        # Find normalized random vector
        r = rand_unit_vector(length(u); rng=rng)

        # If not parallel to u we can keep it and break the loop
        if abs(dot(u, r)) < (1 - eps())
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
    u::AbstractArray{<:Number},
    angle::Number;
    rng::AbstractRNG = Random.GLOBAL_RNG)

    if -pi/2 < angle < pi/2 && length(u) > 1
        return normalize(u + rand_ortho_vector(u; rng=rng) * tan(angle))
    else
        return rand_unit_vector(length(u); rng=rng)
    end

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
"""
function clupoints_d_1(
    projs::AbstractArray{<:Number, 2},
    lat_std::Number,
    clu_dir::AbstractArray{<:Number, 1},
    clu_ctr::AbstractArray{<:Number, 1})

    projs
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
"""
function clupoints_d(
    projs::AbstractArray{<:Number, 2},
    lat_std::Number,
    clu_dir::AbstractArray{<:Number, 1},
    clu_ctr::AbstractArray{<:Number, 1})

    projs
end

"""
    clugen()

Create clusters.
"""
function clugenTNG(
    num_dims::Integer,
    num_clusters::Integer,
    total_points::Integer,
    direction::AbstractArray{<:Number, 1},
    angle_std::Number,
    cluster_sep::AbstractArray{<:Number, 1},
    line_length::Number,
    line_length_std::Number,
    lateral_std::Number;
    cluster_offset::Union{AbstractArray{<:Number, 1}, Nothing} = nothing,
    point_dist::Union{String, <:Function} = "norm",
    point_offset::String = "d-1",
    allow_empty::Bool = false,
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
        pointproj_fun =  point_dist
    elseif point_dist == "unif"
        # Point projections will be uniformly placed along cluster-supporting lines
        pointproj_fun =  (len, n) -> len .* rand(rng, n) .- len / 2
    elseif point_dist == "norm"
        # Use normal distribution for placing point projections along cluster-supporting
        # lines, mean equal to line center, standard deviation equal to 1/6 of line length
        pointproj_fun =  (len, n) -> (1.0/6.0) * len .* randn(rng, n)
    else
        throw(ArgumentError(
            "`point_dist` has to be either \"norm\", \"unif\" or user-defined function"))
    end

    # Check that point_offset specifies a valid way for generating points given
    # their projections along cluster-supporting lines, i.e., either 'd-1'
    # (default), 'd' or a user-defined function
    if num_dims == 1
        # If 1D was specified, point projections are the points themselves
        pt_from_proj_fun = (projs, lat_std, clu_dir, clu_ctr) -> projs
    elseif typeof(point_offset) <: Function
        # Use user-defined distribution; assume function accepts point projections
        # on the line, lateral std., cluster direction and cluster center, and
        # returns a num_points x num_dims matrix containing the final points
        # for the current cluster
        pt_from_proj_fun = point_offset
    elseif point_offset == "d-1"
        # Points will be placed on a second line perpendicular to the cluster
        # line using a normal distribution centered at their intersection
        pt_from_proj_fun = clupoints_d_1
    elseif point_offset == "d"
        # Points will be placed using a multivariate normal distribution
        # centered at the point projection
        pt_from_proj_fun = clupoints_d
    else
        throw(ArgumentError(
            "point_offset has to be either \"d-1\", \"d\" or a user-defined function"))
    end

    # If allow_empty is false, make sure there are enough points to distribute
    # by the clusters
    if !allow_empty && total_points < num_clusters
        throw(ArgumentError(
            "A total of $total_points points is not enough for " *
            "$num_clusters non-empty clusters"))
    end

    # ############################ #
    # Determine cluster properties #
    # ############################ #

    # Normalize base direction
    dir_unit = normalize(direction)

    # Determine cluster sizes using the half-normal distribution (with std=1)
    clu_num_points = clusizes(
        total_points,
        allow_empty,
        () -> abs.(randn(rng, num_clusters)));

    # Determine cluster centers using the uniform distribution between -0.5 and 0.5
    clu_centers = clucenters(
        num_clusters,
        cluster_sep,
        cluster_offset,
        () -> rand(rng, num_clusters, num_dims) .- 0.5)

    # Determine length of lines supporting clusters
    # Line lengths are drawn from the folded normal distribution
    lengths = abs.(line_length .+ line_length_std .* randn(rng, num_clusters));

    # Obtain angles between main direction and cluster-supporting lines
    # using the normal distribution (mean=0, std=angle_std)
    angles = angle_std .* randn(rng, num_clusters)

    # Determine normalized cluster direction
    clu_dirs = hcat([rand_vector_at_angle(direction, a; rng=rng) for a in angles]...)';

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
        ptproj_dist_center = pointproj_fun(lengths[i], clu_num_points[i])

        # Determine coordinates of point projections on the line using the
        # parametric line equation (this works since cluster direction is normalized)
        points_proj[idx_start:idx_end, :] =
            clu_centers[i, :]' .+ ptproj_dist_center * clu_dirs[i, :]'

        # Determine points from their projections on the line
        points[idx_start:idx_end, :] = pt_from_proj_fun(
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

"""
    clugen()

Create clusters.
"""
function clugen(numDims::Integer,
                numCusts::Integer,
                totalPoints::Integer,
                base_direction::AbstractArray{<:Number, 1},
                angleStd::Number,
                clustSepMean::AbstractArray{<:Number, 1},
                lengthMean::Number,
                lengthStd::Number,
                lateralStd::Number;
                cluster_offset::Union{AbstractArray{<:Number, 1}, Nothing} = nothing,
                point_dist::String = "unif",
                point_offset::String = "nd",
                allow_empty::Bool = false)

    # Validate inputs
    if (numDims < 2)
        # TODO: Why not support 1D?
        error("CluGen only supports more than 2 dimensions")
    end
    if (cluster_offset === nothing)
        cluster_offset = zeros(Float64, numDims)
    end
    sizeClustOffset = size(cluster_offset)[1]
    if (sizeClustOffset != numDims)
        error("cluster_offset has to have as many dimensions as the requested ($sizeClustOffset != $numDims)")
    end
    sizeClustAvgSep = size(clustSepMean)[1]
    if (sizeClustAvgSep != numDims)
        error("clustAvgSep has to have as many dimensions as the requested ($sizeClustAvgSep != $numDims)")
    end
    sizeDirMain = size(base_direction)[1]
    if (sizeDirMain != numDims)
        error("dirMain has to have as many dimensions as the requested ($sizeDirMain != $numDims)")
    end
    if ((point_dist != "unif") && (point_dist != "norm"))
        error("point_dist has to be either \"unif\" or \"norm\"")
    end
    if ((point_offset != "nd") && (point_offset != "(n-1)d"))
        error("point_offset has to be either \"nd\" or \"(n-1)d)\"")
    end

    # Convert ints to float if needed
    lengthMean = convert(Float64, lengthMean)
    lengthStd = convert(Float64, lengthStd)
    lateralStd = convert(Float64, lateralStd)

    # Define points per cluster
    retPointCountPerCluster = abs.(randn((numCusts,1)))
    retPointCountPerCluster = retPointCountPerCluster / sum(retPointCountPerCluster)

    # Rounding is done using RoundNeareastTiesAway to be the same behaviour as Matlab
    retPointCountPerCluster = round.(totalPoints * retPointCountPerCluster, RoundNearestTiesAway)

    if (!allow_empty)
        # If we don't want empty clusters, transfer one point from the cluster with more
        # points to the cluster with zero points
        for i = 1:numCusts
            if (retPointCountPerCluster[i] == 0)
                to_remove = argmax(retPointCountPerCluster)[1]
                retPointCountPerCluster[i] = 1
                retPointCountPerCluster[to_remove] -= 1
            end
        end
    end

    # Make sure the number of points is not more than the totalPoints
    while (sum(retPointCountPerCluster) < totalPoints)
        to_add = argmin(retPointCountPerCluster)[1]
        retPointCountPerCluster[to_add] += 1
    end
    # Make sure the number of points is not more than the totalPoints
    while (sum(retPointCountPerCluster) > totalPoints)
        to_add = argmax(retPointCountPerCluster)[1]
        retPointCountPerCluster[to_add] -= 1
    end

    # TODO: Should we create only one loop, or separate cluster generation from point generations?
    # TODO: Should we vectorize the code?

    # Create clusters
    clusters = []
    limDiag = Diagonal(numCusts * clustSepMean)
    for i = 1:numCusts

        # Determine cluster (line) center
        center = limDiag * (rand(Float64, (1, numDims)) .- 0.5)' .+ cluster_offset

        # Determine cluster (line) angle w.r.t. main direction
        angle = angleStd * randn()

        #println("Cluster $i => Angle=$angle (std=$angleStd)")

        # Determine normalized cluster direction
        if (-pi/2 < angle < pi/2)
            direction = normalize(base_direction + getPerpendicularVector(base_direction) * tan(angle))
        else
            direction = getRandomNormalizedVector(numDims)
        end

        # Line length, obtained from the folded normal distribution
        length = abs(rand(Normal(lengthMean, lengthStd)))

        # Push cluster configuration to clusters vector
        push!(clusters, Cluster(center, direction, length))
    end

    # Length distribution
    if (point_dist == "norm")
        lenghtDistribution = Normal(0, 1)
    else
        lenghtDistribution = Uniform(-1, 1)
    end

    # Create points
    retPoints = zeros((totalPoints, numDims))
    retCluster = zeros(Int32, totalPoints)

    index = 1

    for i = 1:numCusts
        cluster = clusters[i]

        pCount = retPointCountPerCluster[i]

        for j = 1:pCount
            pt = generatePoint(numDims, cluster, lenghtDistribution, lateralStd, point_offset)

            # Add it to the output
            retPoints[index,:] = pt
            retCluster[index] = i
            index += 1
        end
    end

    return retPoints, retCluster, clusters, retPointCountPerCluster
end

end # Module
