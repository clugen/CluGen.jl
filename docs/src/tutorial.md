# Tutorial

```@contents
Pages = ["tutorial.md"]
```

## What is CluGen?

CluGen is an algorithm for generating multidimensional clusters.

TODO Maybe give very general idea of lines as support for clusters?

## How CluGen works

Given a `direction` vector, the number of clusters, `num_clusters`...
Note that ``^*`` means the step is stochastic, with sane defaults but fully
controllable by the user.

1. Normalize `direction`
2. Determine cluster sizes``^*``
3. Determine cluster centers``^*``
4. Determine lengths of cluster-supporting lines``^*``
5. Determine angles between `direction` and cluster-supporting lines``^*``
6. Determine direction of cluster-supporting lines
7. For each cluster:
   1. Determine distance of point projections from the center of the cluster-supporting
      line
   2. Determine coordinates of point projections on the line
   3. Determine points from their projections on the line``^*``

The following demonstrates the algorithm steps for 4 clusters in 2D with a total
of 100 points, with the main `direction` set to ``\mathbf{v}=(1,1)``. Additional
parameters, which are detailed in the images, are mean cluster separation of 10
(in both dimensions), an angle standard deviation of ``\pi/32`` radians
(``\approx{}5.6^{\circ}``), line length of 10, line length standard deviation of
1.5, lateral dispersion of 1. Other parameters not specified used defaults which
will be discussed next, although each image hints on how these control the output.

```@eval
ENV["GKSwstype"] = "100"
Base.include(Main, "extras/CluGenExtras.jl")
using CluGen, LinearAlgebra, Plots, Printf, Random
Random.seed!(111)

# Create clusters
d = [1, 1]
nclu = 4
r = clugen(2, nclu, 1000, d, pi/16, [10, 10], 10, 1.5, 1)
plt = Main.CluGenExtras.plot2d(d, r)

savefig(plt, "algorithm.png")

nothing
```

![](algorithm.png)

## Quick start 2D and 3D

TODO

```@setup ex2D3D_1
ENV["GKSwstype"] = "100"
using CluGen, Plots, Random
```

Create data and see the points...

```@example ex2D3D_1
Random.seed!(123)
r = clugen(2, 5, 1000, [1, 1], pi/64, [10, 10], 12, 2, 1)
plot(r.points[:,1], r.points[:,2], seriestype = :scatter, group=r.points_cluster)
savefig("ex2D3D_1_points.png"); nothing # hide
```

![](ex2D3D_1_points.png)

How does this work? Let's see step by step:

```@example ex2D3D_1
plot()
for i in 1:length(r.clusters_length)
    l = r.clusters_length[i]
    p = points_on_line(r.clusters_center[i,:], r.clusters_direction[i, :], [-l/2,l/2])
    plot!(p[:,1],p[:,2],color="black",legend=false)
end
savefig("ex2D3D_1_lines.png"); nothing # hide
```

And now the projections (similar to setting `lateral_std` to 0):

![](ex2D3D_1_lines.png)

```@example ex2D3D_1
plot(r.points_projection[:,1], r.points_projection[:,2], seriestype = :scatter, group=r.points_cluster)
savefig("ex2D3D_1_projs.png"); nothing # hide
```

![](ex2D3D_1_projs.png)

And finally...

![](ex2D3D_1_points.png)

How about using `d`?

```@example ex2D3D_1
Random.seed!(123)
r = clugen(2, 5, 1000, [1, 1], pi/64, [10, 10], 12, 2, 1; point_offset="d")
plot(r.points[:,1], r.points[:,2], seriestype = :scatter, group=r.points_cluster)
savefig("ex2D3D_1_d.png"); nothing # hide
```

![](ex2D3D_1_d.png)


How about using `unif`?

```@example ex2D3D_1
Random.seed!(123)
r = clugen(2, 5, 1000, [1, 1], pi/64, [10, 10], 12, 2, 1; point_dist="unif")
plot(r.points[:,1], r.points[:,2], seriestype = :scatter, group=r.points_cluster)
savefig("ex2D3D_1_unif.png"); nothing # hide
```

![](ex2D3D_1_unif.png)


## Testing n-D

TODO

## Experimenting with basic parameters

TODO

## Experimenting with advanced parameters and user-defined functions

TODO

## Testing auxiliary functions

```@setup 1
# Setup code for all examples
ENV["GKSwstype"] = "100"
using CluGen, Plots, Random
```
### Plots (temp)

If we plot for `clupoints_d_1()` (default):

```@example 1
projs = points_on_line([5.0,5.0], [1.0,0.0], -4:2:4) # hide
points = CluGen.clupoints_d_1(projs, 0.5, [1,0], [0,0], MersenneTwister(123)) # hide
all = vcat(projs, points)
plot(all[:,1], all[:,2], seriestype=:scatter, group=vcat(ones(5), 2 .* ones(5)), label=["Projections" "Points"], ylims=(3,7), size=(600,400))
savefig("clup_d_1.png"); nothing # hide
```

![](clup_d_1.png)

If we plot for `clupoints_d()`:

```@example 1
projs = points_on_line([5.0,5.0], [1.0,0.0], -4:2:4) # hide
points = CluGen.clupoints_d(projs, 0.5, [1,0], [0,0], MersenneTwister(123)) # hide
all = vcat(projs, points)
plot(all[:,1], all[:,2], seriestype=:scatter, group=vcat(ones(5), 2 .* ones(5)), label=["Projections" "Points"], ylims=(3,7), size=(600,400))
savefig("clup_d.png"); nothing # hide
```

![](clup_d.png)

### Others (check)

Example using clusizes_fn parameter for specifying all equal cluster sizes (note
this does not verify if clusters are empty nor if total points is actually respected)

    clusizes_fn=(nclu,tp,ae;rng=Random.GLOBAL_RNG)-> tp ÷ nclu .* ones(Integer, nclu)