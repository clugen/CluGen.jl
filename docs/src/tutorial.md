# Tutorial

```@contents
Pages = ["tutorial.md"]
```

## How CluGen works

TODO

- General algorithm
- Basic function usage

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