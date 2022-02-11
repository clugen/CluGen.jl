# Practice

A number of examples on how to use CluGen.jl. All these examples must be
preceded with:

```@example examples
ENV["GKSwstype"] = "100" # hide
using CluGen, Plots, StableRNGs
```

## 2D examples

### Manipulating the direction of cluster-supporting lines

```@example examples
r1 = clugen(2, 4, 200, [1, 0], 0, [10, 10], 10, 1.5, 0.5; rng = StableRNG(1))
r2 = clugen(2, 4, 200, [1, 1], 0, [10, 10], 10, 1.5, 0.5; rng = StableRNG(1))
r3 = clugen(2, 4, 200, [0, 1], 0, [10, 10], 10, 1.5, 0.5; rng = StableRNG(1))

plt1 = plot(r1.points[:, 1], r1.points[:, 2], seriestype = :scatter, group=r1.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r1: direction = [1, 0]", titlefontsize=9, xlim=(-20, 20), ylim=(-25, 25))
plt2 = plot(r2.points[:,1], r2.points[:,2], seriestype = :scatter, group=r2.point_clusters,  markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r2: direction = [1, 1]", titlefontsize=9, xlim=(-20, 20), ylim=(-25, 25))
plt3 = plot(r3.points[:, 1], r3.points[:, 2], seriestype = :scatter, group=r3.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r3: direction = [0, 1]", titlefontsize=9, xlim=(-20, 20), ylim=(-25, 25))

plt = plot(plt1, plt2, plt3, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex2d_01.png") # hide
nothing # hide
```

![](ex2d_01.png)

```@example examples
# Custom angle_deltas function: arbitrarily rotate some clusters by 90 degrees
angdel_90_fn = (nclu, astd; rng=nothing) -> rand(rng, [0, pi/2], nclu)

r1 = clugen(2, 6, 500, [1, 0], 0, [10, 10], 10, 1.5, 0.5; rng = StableRNG(1))
r2 = clugen(2, 6, 500, [1, 0], pi / 8, [10, 10], 10, 1.5, 0.5; rng = StableRNG(1))
r3 = clugen(2, 6, 500, [1, 0], 0, [10, 10], 10, 1.5, 0.5; angle_deltas_fn = angdel_90_fn, rng = StableRNG(1))

plt1 = plot(r1.points[:, 1], r1.points[:, 2], seriestype = :scatter, group=r1.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r1: angle_disp = 0", titlefontsize=9, xlim=(-35, 35), ylim=(-40, 20))
plt2 = plot(r2.points[:, 1], r2.points[:, 2], seriestype = :scatter, group=r2.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r2: angle_disp = π/8", titlefontsize=9, xlim=(-35, 35), ylim=(-40, 20))
plt3 = plot(r3.points[:,1], r3.points[:,2], seriestype = :scatter, group=r3.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r3: custom angle_deltas function", titlefontsize=9, xlim=(-35, 35), ylim=(-40, 20))

plt = plot(plt1, plt2, plt3, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex2d_02.png") # hide
nothing # hide
```

![](ex2d_02.png)

### Manipulating the length of cluster-supporting lines

```@example examples
r1 = clugen(2, 5, 800, [1, 0], pi / 10, [10, 10], 0, 0, 0.5; point_dist_fn = "n", rng = StableRNG(2))
r2 = clugen(2, 5, 800, [1, 0], pi / 10, [10, 10], 10, 0, 0.5; point_dist_fn = "n", rng = StableRNG(2))
r3 = clugen(2, 5, 800, [1, 0], pi / 10, [10, 10], 30, 0, 0.5; point_dist_fn = "n", rng = StableRNG(2))

plt1 = plot(r1.points[:, 1], r1.points[:, 2], seriestype = :scatter, group=r1.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r1: llength = 0", titlefontsize=9, xlim=(-20, 35), ylim=(-30, 20))
plt2 = plot(r2.points[:,1], r2.points[:,2], seriestype = :scatter, group=r2.point_clusters,  markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r2: llength = 10", titlefontsize=9, xlim=(-20, 35), ylim=(-30, 20))
plt3 = plot(r3.points[:, 1], r3.points[:, 2], seriestype = :scatter, group=r3.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r3: llength = 30", titlefontsize=9, xlim=(-20, 35), ylim=(-30, 20))

plt = plot(plt1, plt2, plt3, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex2d_03.png") # hide
nothing # hide
```

![](ex2d_03.png)

```@example examples
# Custom llengths function: line lengths grow for each new cluster
llen_grow_fn = (nclu, llen, llenstd; rng = nothing) -> llen * (collect(0:(nclu - 1)) + llenstd * randn(rng, nclu))

r1 = clugen(2, 5, 800, [1, 0], pi / 10, [10, 10], 15,  0.0, 0.5; point_dist_fn = "n", rng = StableRNG(2))
r2 = clugen(2, 5, 800, [1, 0], pi / 10, [10, 10], 15, 10.0, 0.5; point_dist_fn = "n", rng = StableRNG(2))
r3 = clugen(2, 5, 800, [1, 0], pi / 10, [10, 10], 10,  0.1, 0.5; llengths_fn = llen_grow_fn, point_dist_fn = "n", rng = StableRNG(2))

plt1 = plot(r1.points[:, 1], r1.points[:, 2], seriestype = :scatter, group=r1.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r1: llength_disp = 0.0", titlefontsize=9, xlim=(-20, 35), ylim=(-30, 20))
plt2 = plot(r2.points[:,1], r2.points[:,2], seriestype = :scatter, group=r2.point_clusters,  markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r2: llength_disp = 5.0", titlefontsize=9, xlim=(-20, 35), ylim=(-30, 20))
plt3 = plot(r3.points[:, 1], r3.points[:, 2], seriestype = :scatter, group=r3.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r3: custom llengths function", titlefontsize=9, xlim=(-20, 35), ylim=(-30, 20))

plt = plot(plt1, plt2, plt3, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex2d_04.png") # hide
nothing # hide
```

![](ex2d_04.png)

### Manipulating relative cluster positions

```@example examples
r1 = clugen(2, 8, 1000, [1, 1], pi / 4, [10, 10], 10, 2, 2.5; rng = StableRNG(321))
r2 = clugen(2, 8, 1000, [1, 1], pi / 4, [30, 10], 10, 2, 2.5; rng = StableRNG(321))
r3 = clugen(2, 8, 1000, [1, 1], pi / 4, [10, 30], 10, 2, 2.5; rng = StableRNG(321))

plt1 = plot(r1.points[:, 1], r1.points[:, 2], seriestype = :scatter, group=r1.point_clusters, markersize=2, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r1: cluster_sep = [10, 10]", titlefontsize=9, xlim=(-120, 80), ylim=(-125, 100))
plt2 = plot(r2.points[:,1], r2.points[:,2], seriestype = :scatter, group=r2.point_clusters,  markersize=2, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r2: cluster_sep = [30, 10]", titlefontsize=9, xlim=(-120, 80), ylim=(-125, 100))
plt3 = plot(r3.points[:, 1], r3.points[:, 2], seriestype = :scatter, group=r3.point_clusters, markersize=2, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r3: cluster_sep = [10, 30]", titlefontsize=9, xlim=(-120, 80), ylim=(-125, 100))

plt = plot(plt1, plt2, plt3, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex2d_05.png") # hide
nothing # hide
```

![](ex2d_05.png)

```@example examples
# Custom clucenters function: places clusters in a diagonal
centers_diag_fn = (nclu, csep, coff; rng=nothing) -> ones(nclu, length(csep)) .* (1:nclu) * maximum(csep) .+ coff'

r1 = clugen(2, 8, 1000, [1, 1], pi / 4, [10, 10], 10, 2, 2.5; rng = StableRNG(321))
r2 = clugen(2, 8, 1000, [1, 1], pi / 4, [10, 10], 10, 2, 2.5; cluster_offset = [20, -20], rng = StableRNG(321))
r3 = clugen(2, 8, 1000, [1, 1], pi / 4, [10, 10], 10, 2, 2.5; cluster_offset = [-50, -50], clucenters_fn = centers_diag_fn, rng = StableRNG(321))

plt1 = plot(r1.points[:, 1], r1.points[:, 2], seriestype = :scatter, group=r1.point_clusters, markersize=2, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r1: default", titlefontsize=9, xlim=(-70, 70), ylim=(-70, 70))
plt2 = plot(r2.points[:,1], r2.points[:,2], seriestype = :scatter, group=r2.point_clusters,  markersize=2, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r2: cluster_offset = [20, -20]", titlefontsize=9, xlim=(-70, 70), ylim=(-70, 70))
plt3 = plot(r3.points[:, 1], r3.points[:, 2], seriestype = :scatter, group=r3.point_clusters, markersize=2, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r3: custom clucenters function", titlefontsize=9, xlim=(-70, 70), ylim=(-70, 70))

plt = plot(plt1, plt2, plt3, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex2d_06.png") # hide
nothing # hide
```

![](ex2d_06.png)

## 3D examples

TODO

### Basic parameters

TODO

### Advanced parameters

TODO

## Examples in other dimensions

TODO

### 1D

TODO

### 5D

TODO
