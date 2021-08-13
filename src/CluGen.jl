# Copyright (c) 2020, 2021 Nuno Fachada, Diogo de Andrade and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

"""
Julia implementation of clugen.
"""
module CluGen

using LinearAlgebra
using Distributions

export clugen

struct Cluster
    center
    direction
    length
end

function getRandomNormalizedVector(numDims::Int)
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

function generatePoint(numDims::Int, cluster::Cluster, lenghtDistribution::Distribution, lateralStd::Number, pointOffset::String)
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
    clugen()

Create clusters.
"""
function clugen(numDims::Int, numCusts::Int, totalPoints::Int,
                dirMain, angleStd::Number,
                clustSepMean,
                lengthMean::Number, lengthStd::Number,
                lateralStd::Number;
                clustOffset = nothing, pointDist::String = "unif",
                pointOffset::String = "nd", allowEmpty::Bool = false)
    # Validate inputs
    if (numDims < 2)
        # TODO: Why not support 1D?
        error("CluGen only supports more than 2 dimensions")
    end
    if (clustOffset === nothing)
        clustOffset = zeros(Float64, numDims)
    end
    sizeClustOffset = size(clustOffset)[1]
    if (sizeClustOffset != numDims)
        error("clustOffset has to have as many dimensions as the requested ($sizeClustOffset != $numDims)")
    end
    sizeClustAvgSep = size(clustSepMean)[1]
    if (sizeClustAvgSep != numDims)
        error("clustAvgSep has to have as many dimensions as the requested ($sizeClustAvgSep != $numDims)")
    end
    sizeDirMain = size(dirMain)[1]
    if (sizeDirMain != numDims)
        error("dirMain has to have as many dimensions as the requested ($sizeDirMain != $numDims)")
    end
    if ((pointDist != "unif") && (pointDist != "norm"))
        error("pointDist has to be either \"unif\" or \"norm\"")
    end
    if ((pointOffset != "nd") && (pointOffset != "(n-1)d"))
        error("pointOffset has to be either \"nd\" or \"(n-1)d)\"")
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

    if (!allowEmpty)
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
    # Make sure the number of points is not moe than the totalPoints
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
        center = limDiag * (rand(Float64, (1, numDims)) .- 0.5)' .+ clustOffset

        # Determine cluster (line) angle w.r.t. main direction
        angle = angleStd * randn()

        #println("Cluster $i => Angle=$angle (std=$angleStd)")

        # Determine normalized cluster direction
        if (-pi/2 < angle < pi/2)
            direction = normalize(dirMain + getPerpendicularVector(dirMain) * tan(angle))
        else
            direction = getRandomNormalizedVector(numDims)
        end

        # Line length, obtained from the folded normal distribution
        length = abs(rand(Normal(lengthMean, lengthStd)))

        # Push cluster configuration to clusters vector
        push!(clusters, Cluster(center, direction, length))
    end

    # Length distribution
    if (pointDist == "norm")
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
            pt = generatePoint(numDims, cluster, lenghtDistribution, lateralStd, pointOffset)

            # Add it to the output
            retPoints[index,:] = pt
            retCluster[index] = i
            index += 1
        end
    end

    return retPoints, retCluster, clusters, retPointCountPerCluster
end

end # Module
