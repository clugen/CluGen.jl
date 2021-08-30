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
using CluGen, LinearAlgebra, Plots, Printf, Random
Random.seed!(111)

# Create clusters
d = [1, 1]
d1 = normalize(d)
nclu = 4
r = clugen(2, nclu, 1000, d, pi/16, [10, 10], 10, 1.5, 1)

# Get current theme colors
theme_colors = theme_palette(:auto).colors.colors

# Plot 1
p1format = (x) -> x ≈ 1 ? "1" : @sprintf("%.3f", x)

p1 = plot([0,0],[0,0],label="User-specified direction",legend=:topleft,xlabel="x",ylabel="y",title="Step 1",color=theme_colors[2],linewidth=2,grid=false,xlim=(0, 1.1), ylim=(0, 1.1), ticks=[d[1], d1[1]],formatter=p1format)

plot!(p1, [0, d[1]], [d[2], d[2]], linewidth=1, linestyle=:dot, label="", color=theme_colors[2])
plot!(p1, [d[1], d[1]], [0, d[2]], linewidth=1, linestyle=:dot, label="", color=theme_colors[2])

plot!(p1, [0, d1[1]], [d1[2], d1[2]], linewidth=1, linestyle=:dot, label="", color=theme_colors[1])
plot!(p1, [d1[1], d1[1]], [0, d1[2]], linewidth=1, linestyle=:dot, label="", color=theme_colors[1])

plot!(p1, d1, d1, label="Normalized direction",color=theme_colors[1],linestyle=:dash,linewidth=2)
plot!(p1,[0, d[1]],[0, d[2]], label="",color=theme_colors[2],arrow=true,linewidth=2)
plot!(p1, [0, d1[1]],[0, d1[2]],label="",color=theme_colors[1],arrow=true,linestyle=:dash,linewidth=2)

# Plot 2
p2 = plot(r.clusters_size, seriestype = :bar, group = 1:nclu, ylabel="Number of points", xlabel="Clusters", legend=false, title="Step 2")

# Plot 3
p3 = plot(r.clusters_center[:,1], r.clusters_center[:,2], seriestype=:scatter, group=map((x)->"Center $x",1:nclu), markersize=5, xlim=(-25,30), ylim=(-30,30), legend=:bottomleft, xlabel="x", ylabel="y", title="Step 3")

# Plot 4
p4 = plot(title="Step 4",xlim=(-25,30), ylim=(-30,30), legend=:bottomleft, xlabel="x", ylabel="y")
for i in 1:length(r.clusters_length)
    l = r.clusters_length[i]
    p = points_on_line(r.clusters_center[i,:], d1, [-l/2,l/2])
    plot!(p4, p[:,1],p[:,2], label="Line $i", linewidth=2, linestyle=:dot)
end
for i in 1:length(r.clusters_length)
    l = r.clusters_length[i]
    p = points_on_line(r.clusters_center[i,:], d1, [-l/2,l/2])
    plot!(p4, [r.clusters_center[i, 1]], [r.clusters_center[i, 2]], seriestype=:scatter, color=theme_colors[i], label="", markersize=5)
end

# Plot 5
#adiff(cludir) = acos(dot(cludir, d1) / (norm(cludir) * norm(d1)))
p5 = plot(abs.(r.clusters_angle), seriestype = :bar, group = 1:nclu, ylabel="Angle
diff. to main direction", xlabel="Clusters", legend=false, title="Step 5")

# Plot 6
p6 = plot(title="Step 6",xlim=(-25,30), ylim=(-30,30), legend=:bottomleft, xlabel="x", ylabel="y")
for i in 1:nclu
    l = r.clusters_length[i]
    pf = points_on_line(r.clusters_center[i,:], r.clusters_direction[i, :], [-l/2,l/2])
    plot!(p6, pf[:,1],pf[:,2], label="Line $i", linewidth=3)
end
for i in 1:nclu
    l = r.clusters_length[i]
    po = points_on_line(r.clusters_center[i,:], d1, [-l/2,l/2])
    plot!(p6, po[:,1],po[:,2], label="", linewidth=1, linestyle=:dot, color="black")
    plot!(p6, [r.clusters_center[i, 1]], [r.clusters_center[i, 2]], seriestype=:scatter, color=theme_colors[i], label="", markersize=5)
end

# Plot 7.1
p71 = plot(title="Step 7.1")

# Plot 7.2
p72 = plot(title="Step 7.2")

# Plot 7.3
p73 = plot(title="Step 7.3")

# All plots
plot(p1, p2, p3, p4, p5, p6, p71, p72, p73, layout = (3, 3), size=(1200,1200))

savefig("algorithm.png")

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