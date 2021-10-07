# Tutorial

```@contents
Pages = ["tutorial.md"]
```

## What is CluGen?

CluGen is an algorithm for generating multidimensional clusters. Each cluster is
supported by a line, the position, orientation and length of which guide where
the respective points are placed.

## Algorithm Overview

Given the main `direction` ``$n$``-dimensional vector, the number of clusters
(`num_clusters`), the total number of points (`total_points`), and a number of
additional parameters which will be discussed shortly, the _clugen_ algorithm
works as follows (``^*`` means the algorithm step is stochastic):

1. Normalize `direction`
2. ``^*``Determine cluster sizes
3. ``^*``Determine cluster centers
4. ``^*``Determine lengths of cluster-supporting lines
5. ``^*``Determine angles between `direction` and cluster-supporting lines
6. Determine direction of cluster-supporting lines
7. For each cluster:
   1. Determine distance of point projections from the center of the cluster-supporting
      line
   2. Determine coordinates of point projections on the line
   3. ``^*``Determine points from their projections on the line

The following image provides a stylized overview of the algorithm steps when the
main `direction` is set to ``\mathbf{v}=\begin{bmatrix}1 & 1\end{bmatrix}^T``
(thus in 2D space), 4 clusters, and a total of 500 points.

```@eval
ENV["GKSwstype"] = "100"
Base.include(Main, "extras/CluGenExtras.jl")
using CluGen, LinearAlgebra, Plots, Printf, Random
Random.seed!(111)

# Create clusters
d = [1, 1]
nclu = 4
r = clugen(2, nclu, 500, d, pi/16, [10, 10], 10, 1.5, 1)
plt = Main.CluGenExtras.plot2d(d, r)

savefig(plt, "algorithm.png")

nothing
```

![](algorithm.png)

Additional parameters
include a mean cluster separation (`cluster_sep`) of 10 in both dimensions, an
angle standard deviation of ``\pi/32`` radians (``\approx{}5.6^{\circ}``)—the
angle of the main `direction` is considered the mean, line length mean of 10,
line length standard deviation of 1.5, and lateral dispersion of 1.

Other parameters not specified used defaults which
will be discussed next, although each image hints on how these control the output.

## Parameters and algorithm details

| Math             | Code           | Description           |
|:---------------- |:-------------- |:--------------------- |
| ``d``            | `num_dims`     | Number of dimensions. |
| ``n``            | `num_clusters` | Number of clusters.   |
| ``p_\text{tot}`` | `total_points` | Total points.         |
| ``\mathbf{v}``   | `direction`    | Main direction.       |


TODO Describe steps

## Parameter influences on final results

TODO