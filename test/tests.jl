using CluGen
using Plots

function runTest(numDims, nClusters=5, pointDist="norm", pointOffset="nd")
    if (numDims == 2)
        @time points, clusters, clusterDefs, retPointCountPerCluster = clugen(
            numDims, nClusters, 1500, [1, 0], pi/16, [2, 2], 4, 1, 0.1, [0, 0], pointDist, pointOffset)
    elseif (numDims == 3)
        @time points, clusters, clusterDefs, retPointCountPerCluster = clugen(
            numDims, nClusters, 1500, [0, 0, 1], pi/8, [2, 2, 2], 8, 1, 0.8, [0, 0, 0], pointDist, pointOffset)
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

runTest(2, 4, "norm", "(n-1)d")
runTest(3, 5, "norm")
#runTest(4, 5, "norm")