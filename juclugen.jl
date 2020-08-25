# Copyright (c) 2020 Diogo de Andrade, Nuno Fachada
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

using LinearAlgebra
using Distributions, Random
using Plots

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
    # - Compute (u'u)v' - (v'u)u', and normalize it
    p = normalize(((u'u)v' - (v'u)u')')

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

function cluGen(numDims::Int, numCusts::Int, totalPoints::Int,
                dirMain, angleStd::Number,
                clustOffset, clustAvgSep,
                lengthMean::Number, lengthStd::Number,
                lateralStd::Number,
                pointDist::String="unif", pointOffset::String="nd", allowEmpty::Bool=false)
    # Validate inputs
    if (numDims < 2)
        # TODO: Why not support 1D?
        error("juCluGen only supports more than 2 dimensions")
    end
    sizeClustOffset = size(clustOffset)[1]
    if (sizeClustOffset != numDims)
        error("clustOffset has to have as many dimensions as the requested ($sizeClustOffset != $numDims)")
    end
    sizeClustAvgSep = size(clustAvgSep)[1]
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
    retPointCountPerCluster = round.(totalPoints * retPointCountPerCluster)

    if (!allowEmpty)
        for i = 1:numCusts
            if (retPointCountPerCluster[i] == 0)
                to_remove = argmax(retPointCountPerCluster)[1]
                retPointCountPerCluster[i] = 1
                retPointCountPerCluster[to_remove] -= 1
            end
        end
    end

    while (sum(retPointCountPerCluster) < totalPoints)
        to_add = argmin(retPointCountPerCluster)[1]
        retPointCountPerCluster[to_add] += 1
    end
    while (sum(retPointCountPerCluster) > totalPoints)
        to_add = argmax(retPointCountPerCluster)[1]
        retPointCountPerCluster[to_add] -= 1
    end

    # Create clusters
    clusters = []
    limDiag = Diagonal(numCusts * clustAvgSep)
    for i = 1:numCusts
        # Define center
        center = limDiag * (rand(Float64, (1, numDims)) .- 0.5)' .+ clustOffset

        angle = angleStd * randn()

        println("Cluster $i => Angle=$angle (std=$angleStd)")

        if (-pi/2 < angle < pi/2)
            direction = normalize(dirMain + getPerpendicularVector(dirMain) * tan(angle))
        else
            direction = getRandomNormalizedVector(numDims)
        end

        # Length
        if (pointDist == "norm")
            length = rand(Normal(lengthMean, lengthStd)) / 6
        else
            length = rand(Normal(lengthMean, lengthStd)) * 0.5
        end

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

function runTest(numDims, nClusters=5, pointDist="norm", pointOffset="nd")
    if (numDims == 2)
        @time points, clusters, clusterDefs, retPointCountPerCluster = cluGen(
            numDims, nClusters, 1500, [1, 0], 0, [0, 0], [2, 2], 4, 1, 0.1, pointDist, pointOffset)
    elseif (numDims == 3)
        @time points, clusters, clusterDefs, retPointCountPerCluster = cluGen(
            numDims, nClusters, 1500, [0, 0, 1], pi/2, [0, 0, 0], [2, 2, 2], 8, 1, 0.1, pointDist, pointOffset)
    end

    dims = size(points)[2]
    if (dims == 2)
        display(scatter(points[:,1],points[:,2], group = clusters, markersize=3, markerstrokewidth=0.5))
    elseif (dims == 3)
        display(scatter(points[:,1], points[:,2], points[:,3], group = clusters, markersize=3, markerstrokewidth=0.5))
    else
        println("Can't display $dims-D data")
    end

    return points, clusters, clusterDefs, retPointCountPerCluster
end

#runTest(2, 4, "norm", "(n-1)d")
#runTest(3, 5, "norm")
#runTest(4, 5, "norm")

nothing
