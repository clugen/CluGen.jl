# Theory

This section presents a general overview of the _clugen_ algorithm. A complete
description of the algorithm's theoretical framework is available in the article
"[Generating multidimensional clusters with support
lines](https://doi.org/10.1016/j.knosys.2023.110836)" (an open version is
[available on arXiv](https://arxiv.org/abs/2301.10327)).

_Clugen_ is an algorithm for generating multidimensional clusters. Each cluster
is supported by a line segment, the position, orientation and length of which
guide where the respective points are placed. For brevity, *line segments* will
be referred to as *lines*.

Given an ``n``-dimensional direction vector ``\mathbf{d}`` (and a number of
additional parameters, which will be discussed shortly), the _clugen_ algorithm
works as follows (``^*`` means the algorithm step is stochastic):

1. Normalize ``\mathbf{d}``.
2. ``^*``Determine cluster sizes.
3. ``^*``Determine cluster centers.
4. ``^*``Determine lengths of cluster-supporting lines.
5. ``^*``Determine angles between ``\mathbf{d}`` and cluster-supporting lines.
6. For each cluster:
   1. ``^*``Determine direction of the cluster-supporting line.
   2. ``^*``Determine distance of point projections from the center of the
      cluster-supporting line.
   3. Determine coordinates of point projections on the cluster-supporting line.
   4. ``^*``Determine points from their projections on the cluster-supporting
      line.

Figure 1 provides a stylized overview of the algorithm's steps.

```@eval
ENV["GKSwstype"] = "100"
using CluGen, LinearAlgebra, Plots, Main.CluGenExtras

# Create clusters
d = [1, 1]
nclu = 4
r = clugen(2, nclu, 200, d, pi/16, [10, 10], 10, 1.5, 1; rng=1234)
plt, _ = plot_story_2d(d, r)

savefig(plt, "algorithm.svg")

nothing
```

![](algorithm.svg)
**Figure 1** - Stylized overview of the *clugen* algorithm. Background tiles
are 10 units wide and tall, when applicable.

The example in Figure 1 was generated with the following parameters, the exact
meaning of each is described in the documentation for the [`clugen()`](@ref)
function, and further discussed in the article mentioned above:

| Parameter values  | Description                 |
|:----------------- | :-------------------------- |
| ``n=2``           | Number of dimensions.       |
| ``c=4``           | Number of clusters.         |
| ``p=200``         | Total number of points.     |
| ``\mathbf{d}=\begin{bmatrix}1 & 1\end{bmatrix}^T``   | Average direction.          |
| ``\theta_\sigma=\pi/16\approx{}11.25^{\circ}``       | Angle dispersion.           |
| ``\mathbf{s}=\begin{bmatrix}10 & 10\end{bmatrix}^T`` | Average cluster separation. |
| ``l=10``          | Average line length.        |
| ``l_\sigma=1.5``  | Line length dispersion.     |
| ``f_\sigma=1``    | Cluster lateral dispersion. |

Additionally, all optional parameters (not listed above) were left to their
default values. These will also be discussed next. This example can be reproduced
and plotted with the following instructions:

```julia-repl
julia> using CluGen, Plots

julia> r = clugen(2, 4, 200, [1, 1], pi/16, [10, 10], 10, 1.5, 1; rng=1234);

julia> plot(r.points[:,1], r.points[:,2], seriestype=:scatter, group=r.clusters)
```
