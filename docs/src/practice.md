# Practice

A number of examples on how to use CluGen.jl. All these examples must be
preceded with:

```@example examples
ENV["GKSwstype"] = "100" # hide
using CluGen, Distributions, Plots, Random, StableRNGs
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
angdel_90_fn = (nclu, astd; rng=nothing) -> rand(rng, [0, pi / 2], nclu)

r1 = clugen(2, 6, 500, [1, 0], 0, [10, 10], 10, 1.5, 0.5; rng = StableRNG(1))
r2 = clugen(2, 6, 500, [1, 0], pi / 8, [10, 10], 10, 1.5, 0.5; rng = StableRNG(1))
r3 = clugen(2, 6, 500, [1, 0], 0, [10, 10], 10, 1.5, 0.5; angle_deltas_fn = angdel_90_fn, rng = StableRNG(1))

plt1 = plot(r1.points[:, 1], r1.points[:, 2], seriestype = :scatter, group=r1.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r1: angle_disp = 0", titlefontsize=9, xlim=(-35, 35), ylim=(-40, 20))
plt2 = plot(r2.points[:, 1], r2.points[:, 2], seriestype = :scatter, group=r2.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r2: angle_disp = π/8", titlefontsize=9, xlim=(-35, 35), ylim=(-40, 20))
plt3 = plot(r3.points[:, 1], r3.points[:, 2], seriestype = :scatter, group=r3.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r3: custom angle_deltas function", titlefontsize=9, xlim=(-35, 35), ylim=(-40, 20))

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
plt2 = plot(r2.points[:, 1], r2.points[:, 2], seriestype = :scatter, group=r2.point_clusters,  markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r2: llength = 10", titlefontsize=9, xlim=(-20, 35), ylim=(-30, 20))
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
plt2 = plot(r2.points[:, 1], r2.points[:, 2], seriestype = :scatter, group=r2.point_clusters,  markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r2: llength_disp = 5.0", titlefontsize=9, xlim=(-20, 35), ylim=(-30, 20))
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
plt2 = plot(r2.points[:, 1], r2.points[:, 2], seriestype = :scatter, group=r2.point_clusters,  markersize=2, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r2: cluster_sep = [30, 10]", titlefontsize=9, xlim=(-120, 80), ylim=(-125, 100))
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
plt2 = plot(r2.points[:, 1], r2.points[:, 2], seriestype = :scatter, group=r2.point_clusters,  markersize=2, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r2: cluster_offset = [20, -20]", titlefontsize=9, xlim=(-70, 70), ylim=(-70, 70))
plt3 = plot(r3.points[:, 1], r3.points[:, 2], seriestype = :scatter, group=r3.point_clusters, markersize=2, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r3: custom clucenters function", titlefontsize=9, xlim=(-70, 70), ylim=(-70, 70))

plt = plot(plt1, plt2, plt3, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex2d_06.png") # hide
nothing # hide
```

![](ex2d_06.png)

### Lateral dispersion and placement of point projections on the line

#### Normal projection placement (default): `proj_dist_fn = "norm"`

```@example examples
r1 = clugen(2, 4, 1000, [1, 0], pi / 2, [20, 20], 13, 2, 0.0; rng = StableRNG(456))
r2 = clugen(2, 4, 1000, [1, 0], pi / 2, [20, 20], 13, 2, 1.0; rng = StableRNG(456))
r3 = clugen(2, 4, 1000, [1, 0], pi / 2, [20, 20], 13, 2, 3.0; rng = StableRNG(456))

plt1 = plot(r1.points[:, 1], r1.points[:, 2], seriestype = :scatter, group=r1.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="r1: lateral_disp=0", titlefontsize=9, xlim=(-50, 30), ylim=(-50, 30))
plt2 = plot(r2.points[:, 1], r2.points[:, 2], seriestype = :scatter, group=r2.point_clusters,  markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="r2: lateral_disp=1", titlefontsize=9, xlim=(-50, 30), ylim=(-50, 30))
plt3 = plot(r3.points[:, 1], r3.points[:, 2], seriestype = :scatter, group=r3.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="r3: lateral_disp=3", titlefontsize=9, xlim=(-50, 30), ylim=(-50, 30))

plt = plot(plt1, plt2, plt3, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex2d_07.png") # hide
nothing # hide
```

![](ex2d_07.png)

#### Uniform projection placement: `proj_dist_fn = "unif"`

```@example examples
r4 = clugen(2, 4, 1000, [1, 0], pi / 2, [20, 20], 13, 2, 0.0; proj_dist_fn = "unif", rng = StableRNG(456))
r5 = clugen(2, 4, 1000, [1, 0], pi / 2, [20, 20], 13, 2, 1.0; proj_dist_fn = "unif", rng = StableRNG(456))
r6 = clugen(2, 4, 1000, [1, 0], pi / 2, [20, 20], 13, 2, 3.0; proj_dist_fn = "unif", rng = StableRNG(456))

plt4 = plot(r4.points[:, 1], r4.points[:, 2], seriestype = :scatter, group=r4.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="r4: lateral_disp=0", titlefontsize=9, xlim=(-50, 30), ylim=(-50, 30))
plt5 = plot(r5.points[:, 1], r5.points[:, 2], seriestype = :scatter, group=r5.point_clusters,  markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="r5: lateral_disp=1", titlefontsize=9, xlim=(-50, 30), ylim=(-50, 30))
plt6 = plot(r6.points[:, 1], r6.points[:, 2], seriestype = :scatter, group=r6.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="r6: lateral_disp=3", titlefontsize=9, xlim=(-50, 30), ylim=(-50, 30))

plt = plot(plt4, plt5, plt6, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex2d_08.png") # hide
nothing # hide
```

![](ex2d_08.png)

#### Custom projection placement using the Laplace distribution

```@example examples
# Custom proj_dist_fn: point projections placed using the Laplace distribution
proj_laplace = (len, n, rng) -> rand(rng, Laplace(0, len / 6), n)

r7 = clugen(2, 4, 1000, [1, 0], pi / 2, [20, 20], 13, 2, 0.0; proj_dist_fn = proj_laplace, rng = StableRNG(456))
r8 = clugen(2, 4, 1000, [1, 0], pi / 2, [20, 20], 13, 2, 1.0; proj_dist_fn = proj_laplace, rng = StableRNG(456))
r9 = clugen(2, 4, 1000, [1, 0], pi / 2, [20, 20], 13, 2, 3.0; proj_dist_fn = proj_laplace, rng = StableRNG(456))

plt7 = plot(r7.points[:, 1], r7.points[:, 2], seriestype = :scatter, group=r7.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="r7: lateral_disp=0", titlefontsize=9, xlim=(-50, 30), ylim=(-50, 30))
plt8 = plot(r8.points[:, 1], r8.points[:, 2], seriestype = :scatter, group=r8.point_clusters,  markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="r8: lateral_disp=1", titlefontsize=9, xlim=(-50, 30), ylim=(-50, 30))
plt9 = plot(r9.points[:, 1], r9.points[:, 2], seriestype = :scatter, group=r9.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="r9: lateral_disp=3", titlefontsize=9, xlim=(-50, 30), ylim=(-50, 30))

plt = plot(plt7, plt8, plt9, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex2d_09.png") # hide
nothing # hide
```

![](ex2d_09.png)

### Controlling final point positions from their projections on the cluster-supporting line

#### Points on hyperplane orthogonal to cluster-supporting line (default): `point_dist_fn = "n-1"`

```@example examples
r1 = clugen(2, 5, 1500, [1, 0], pi / 3, [20, 20], 12, 3, 1.0; rng = StableRNG(345))
r2 = clugen(2, 5, 1500, [1, 0], pi / 3, [20, 20], 12, 3, 1.0; proj_dist_fn = "unif", rng = StableRNG(345))
r3 = clugen(2, 5, 1500, [1, 0], pi / 3, [20, 20], 12, 3, 1.0; proj_dist_fn = proj_laplace, rng = StableRNG(345))

plt1 = plot(r1.points[:, 1], r1.points[:, 2], seriestype = :scatter, group=r1.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="r1: proj_dist_fn=\"norm\" (default)", titlefontsize=9, xlim=(-60, 40), ylim=(-30, 60))
plt2 = plot(r2.points[:, 1], r2.points[:, 2], seriestype = :scatter, group=r2.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="r2: proj_dist_fn=\"unif\"", titlefontsize=9, xlim=(-60, 40), ylim=(-30, 60))
plt3 = plot(r3.points[:, 1], r3.points[:, 2], seriestype = :scatter, group=r3.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="r3: custom proj_dist_fn (Laplace)", titlefontsize=9, xlim=(-60, 40), ylim=(-30, 60))

plt = plot(plt1, plt2, plt3, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex2d_10.png") # hide
nothing # hide
```

![](ex2d_10.png)

#### Points around projection on cluster-supporting line: `point_dist_fn = "n"`

```@example examples
r4 = clugen(2, 5, 1500, [1, 0], pi / 3, [20, 20], 12, 3, 1.0; point_dist_fn = "n", rng = StableRNG(345))
r5 = clugen(2, 5, 1500, [1, 0], pi / 3, [20, 20], 12, 3, 1.0; point_dist_fn = "n", proj_dist_fn = "unif", rng = StableRNG(345))
r6 = clugen(2, 5, 1500, [1, 0], pi / 3, [20, 20], 12, 3, 1.0; point_dist_fn = "n", proj_dist_fn = proj_laplace, rng = StableRNG(345))

plt4 = plot(r4.points[:, 1], r4.points[:, 2], seriestype = :scatter, group=r4.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="r4: proj_dist_fn=\"norm\" (default)", titlefontsize=9, xlim=(-60, 40), ylim=(-30, 60))
plt5 = plot(r5.points[:, 1], r5.points[:, 2], seriestype = :scatter, group=r5.point_clusters,  markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="r5: proj_dist_fn=\"unif\"", titlefontsize=9, xlim=(-60, 40), ylim=(-30, 60))
plt6 = plot(r6.points[:, 1], r6.points[:, 2], seriestype = :scatter, group=r6.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="r6: custom proj_dist_fn (Laplace)", titlefontsize=9, xlim=(-60, 40), ylim=(-30, 60))

plt = plot(plt4, plt5, plt6, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex2d_11.png") # hide
nothing # hide
```

![](ex2d_11.png)

#### Custom point placement using the exponential distribution


```@example examples
# Custom point_dist_fn: final points placed using the Exponential distribution
function clupoints_n_1_exp(projs, lat_std, len, clu_dir, clu_ctr; rng=nothing)
    dist_exp = (npts, lstd, rg) -> lstd .* rand(rg, Exponential(2 / lstd), npts, 1)
    return CluGen.clupoints_n_1_template(projs, lat_std, clu_dir, dist_exp; rng=rng)
end

r7 = clugen(2, 5, 1500, [1, 0], pi / 3, [20, 20], 12, 3, 1.0; point_dist_fn = clupoints_n_1_exp, rng = StableRNG(345))
r8 = clugen(2, 5, 1500, [1, 0], pi / 3, [20, 20], 12, 3, 1.0; point_dist_fn = clupoints_n_1_exp, proj_dist_fn = "unif", rng = StableRNG(345))
r9 = clugen(2, 5, 1500, [1, 0], pi / 3, [20, 20], 12, 3, 1.0; point_dist_fn = clupoints_n_1_exp, proj_dist_fn = proj_laplace, rng = StableRNG(345))

plt7 = plot(r7.points[:, 1], r7.points[:, 2], seriestype = :scatter, group=r7.point_clusters,  markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="r7: proj_dist_fn=\"norm\" (default)", titlefontsize=9, xlim=(-60, 40), ylim=(-30, 60))
plt8 = plot(r8.points[:, 1], r8.points[:, 2], seriestype = :scatter, group=r8.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="r8: proj_dist_fn=\"unif\"", titlefontsize=9, xlim=(-60, 40), ylim=(-30, 60))
plt9 = plot(r9.points[:, 1], r9.points[:, 2], seriestype = :scatter, group=r9.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="r9: custom proj_dist_fn (Laplace)", titlefontsize=9, xlim=(-60, 40), ylim=(-30, 60))

plt = plot(plt7, plt8, plt9, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex2d_12.png") # hide
nothing # hide
```

![](ex2d_12.png)

### Manipulating cluster sizes

```@example examples
# Custom clusizes_fn (r2): cluster sizes determined via the uniform distribution, no correction for total points
clusizes_unif = (nclu, npts, ae; rng = nothing) -> rand(rng, DiscreteUniform(1, 2 * npts / nclu), nclu)

# Custom clusizes_fn (r3): clusters all have the same size, no correction for total points
clusizes_equal = (nclu, npts, ae; rng = nothing) -> (npts ÷ nclu) .* ones(Integer, nclu)

# Custom clucenters_fn (all): yields fixed positions for the clusters
centers_fixed = (nclu, csep, coff; rng=nothing) -> [-csep[1] -csep[2]; csep[1] -csep[2]; -csep[1] csep[2]; csep[1] csep[2]]

r1 = clugen(2, 4, 1500, [1, 1], pi, [20, 20], 0, 0, 5; clucenters_fn = centers_fixed, point_dist_fn = "n", rng = StableRNG(9))
r2 = clugen(2, 4, 1500, [1, 1], pi, [20, 20], 0, 0, 5; clucenters_fn = centers_fixed, clusizes_fn = clusizes_unif, point_dist_fn = "n", rng = StableRNG(9))
r3 = clugen(2, 4, 1500, [1, 1], pi, [20, 20], 0, 0, 5; clucenters_fn = centers_fixed, clusizes_fn = clusizes_equal, point_dist_fn = "n", rng = StableRNG(9))

plt1 = plot(r1.points[:, 1], r1.points[:, 2], seriestype = :scatter, group=r1.point_clusters, markersize=2, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r1: normal dist. (default)", titlefontsize=9, xlim=(-40, 40), ylim=(-40, 40))
plt2 = plot(r2.points[:, 1], r2.points[:, 2], seriestype = :scatter, group=r2.point_clusters,  markersize=2, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r2: unif. dist. (custom)", titlefontsize=9, xlim=(-40, 40), ylim=(-40, 40))
plt3 = plot(r3.points[:, 1], r3.points[:, 2], seriestype = :scatter, group=r3.point_clusters, markersize=2, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r3: equal size (custom)", titlefontsize=9, xlim=(-40, 40), ylim=(-40, 40))

plt = plot(plt1, plt2, plt3, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex2d_13.png") # hide
nothing # hide
```

![](ex2d_13.png)

## 3D examples

### Manipulating the direction of cluster-supporting lines

```@example examples
r1 = clugen(3, 4, 500, [1, 0, 0], 0, [10, 10, 10], 15, 1.5, 0.5; rng = StableRNG(1))
r2 = clugen(3, 4, 500, [1, 1, 1], 0, [10, 10, 10], 15, 1.5, 0.5; rng = StableRNG(1))
r3 = clugen(3, 4, 500, [0, 0, 1], 0, [10, 10, 10], 15, 1.5, 0.5; rng = StableRNG(1))

plt1 = plot(r1.points[:, 1], r1.points[:, 2], r1.points[:, 3], seriestype = :scatter, group=r1.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r1: direction = [1, 0, 0]", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-20,20), ylim=(-20,20), zlim=(-23,13))
plt2 = plot(r2.points[:, 1], r2.points[:, 2], r2.points[:, 3], seriestype = :scatter, group=r2.point_clusters,  markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r2: direction = [1, 1, 1]", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-20,20), ylim=(-20,20), zlim=(-23,13))
plt3 = plot(r3.points[:, 1], r3.points[:, 2], r3.points[:, 3], seriestype = :scatter, group=r3.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r3: direction = [0, 1, 0]", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-20,20), ylim=(-20,20), zlim=(-23,13))

plt = plot(plt1, plt2, plt3, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex3d_01.png") # hide
nothing # hide
```

![](ex3d_01.png)

```@example examples
# Custom angle_deltas function: arbitrarily rotate some clusters by 90 degrees
angdel_90_fn = (nclu, astd; rng=nothing) -> rand(rng, [0, pi / 2], nclu)

r1 = clugen(3, 6, 1000, [1, 0, 0], 0, [10, 10, 10], 15, 1.5, 0.5; rng = StableRNG(2))
r2 = clugen(3, 6, 1000, [1, 0, 0], pi / 8, [10, 10, 10], 15, 1.5, 0.5; rng = StableRNG(2))
r3 = clugen(3, 6, 1000, [1, 0, 0], 0, [10, 10, 10], 15, 1.5, 0.5; angle_deltas_fn = angdel_90_fn, rng = StableRNG(2))

plt1 = plot(r1.points[:, 1], r1.points[:, 2], r1.points[:, 3], seriestype = :scatter, group=r1.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r1: angle_disp = 0", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-16, 40), ylim=(-30, 25), zlim=(-35, 32))
plt2 = plot(r2.points[:, 1], r2.points[:, 2], r2.points[:, 3], seriestype = :scatter, group=r2.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r2: angle_disp = π/8", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-16, 40), ylim=(-30, 25), zlim=(-35, 32))
plt3 = plot(r3.points[:, 1], r3.points[:, 2], r3.points[:, 3], seriestype = :scatter, group=r3.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r3: custom angle_deltas function", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-16, 40), ylim=(-30, 25), zlim=(-35, 32))

plt = plot(plt1, plt2, plt3, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex3d_02.png") # hide
nothing # hide
```

![](ex3d_02.png)

### Manipulating the length of cluster-supporting lines

```@example examples
r1 = clugen(3, 5, 800, [1, 0, 0], pi / 10, [10, 10, 10], 0, 0, 0.5; point_dist_fn = "n", rng = StableRNG(2))
r2 = clugen(3, 5, 800, [1, 0, 0], pi / 10, [10, 10, 10], 10, 0, 0.5; point_dist_fn = "n", rng = StableRNG(2))
r3 = clugen(3, 5, 800, [1, 0, 0], pi / 10, [10, 10, 10], 30, 0, 0.5; point_dist_fn = "n", rng = StableRNG(2))

plt1 = plot(r1.points[:, 1], r1.points[:, 2], r1.points[:, 3], seriestype = :scatter, group=r1.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r1: llength = 0", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-20, 40), ylim=(-30, 20), zlim=(-20, 25))
plt2 = plot(r2.points[:, 1], r2.points[:, 2], r2.points[:, 3], seriestype = :scatter, group=r2.point_clusters,  markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r2: llength = 10", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-20, 40), ylim=(-30, 20), zlim=(-20, 25))
plt3 = plot(r3.points[:, 1], r3.points[:, 2], r3.points[:, 3], seriestype = :scatter, group=r3.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r3: llength = 30", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-20, 40), ylim=(-30, 20), zlim=(-20, 25))

plt = plot(plt1, plt2, plt3, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex3d_03.png") # hide
nothing # hide
```

![](ex3d_03.png)

```@example examples
# Custom llengths function: line lengths grow for each new cluster
llen_grow_fn = (nclu, llen, llenstd; rng = nothing) -> llen * (collect(0:(nclu - 1)) + llenstd * randn(rng, nclu))

r1 = clugen(3, 5, 800, [1, 0, 0], pi / 10, [10, 10, 10], 15,  0.0, 0.5; point_dist_fn = "n", rng = StableRNG(2))
r2 = clugen(3, 5, 800, [1, 0, 0], pi / 10, [10, 10, 10], 15, 10.0, 0.5; point_dist_fn = "n", rng = StableRNG(2))
r3 = clugen(3, 5, 800, [1, 0, 0], pi / 10, [10, 10, 10], 10,  0.1, 0.5; llengths_fn = llen_grow_fn, point_dist_fn = "n", rng = StableRNG(2))

plt1 = plot(r1.points[:, 1], r1.points[:, 2], r1.points[:, 3], seriestype = :scatter, group=r1.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r1: llength_disp = 0.0", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-20, 40), ylim=(-30, 25), zlim=(-20, 25))
plt2 = plot(r2.points[:, 1], r2.points[:, 2], r2.points[:, 3], seriestype = :scatter, group=r2.point_clusters,  markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r2: llength_disp = 5.0", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-20, 40), ylim=(-30, 25), zlim=(-20, 25))
plt3 = plot(r3.points[:, 1], r3.points[:, 2], r3.points[:, 3], seriestype = :scatter, group=r3.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r3: custom llengths function", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-20, 40), ylim=(-30, 25), zlim=(-20, 25))

plt = plot(plt1, plt2, plt3, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex3d_04.png") # hide
nothing # hide
```

![](ex3d_04.png)


### Manipulating relative cluster positions

```@example examples
r1 = clugen(3, 8, 1000, [1, 1, 1], pi / 4, [30, 10, 10], 25, 4, 3; rng = StableRNG(321))
r2 = clugen(3, 8, 1000, [1, 1, 1], pi / 4, [10, 30, 10], 25, 4, 3; rng = StableRNG(321))
r3 = clugen(3, 8, 1000, [1, 1, 1], pi / 4, [10, 10, 30], 25, 4, 3; rng = StableRNG(321))

plt1 = plot(r1.points[:, 1], r1.points[:, 2], r1.points[:, 3], seriestype = :scatter, group=r1.point_clusters, markersize=2, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r1: cluster_sep = [30, 10, 10]", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-100, 100), ylim=(-100, 100), zlim=(-100, 100))
plt2 = plot(r2.points[:, 1], r2.points[:, 2], r2.points[:, 3], seriestype = :scatter, group=r2.point_clusters, markersize=2, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r2: cluster_sep = [10, 30, 10]", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-100, 100), ylim=(-100, 100), zlim=(-100, 100))
plt3 = plot(r3.points[:, 1], r3.points[:, 2], r3.points[:, 3], seriestype = :scatter, group=r3.point_clusters, markersize=2, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r3: cluster_sep = [10, 10, 30]", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-100, 100), ylim=(-100, 100), zlim=(-100, 100))

plt = plot(plt1, plt2, plt3, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex3d_05.png") # hide
nothing # hide
```

![](ex3d_05.png)

```@example examples
# Custom clucenters function: places clusters in a diagonal
centers_diag_fn = (nclu, csep, coff; rng=nothing) -> ones(nclu, length(csep)) .* (1:nclu) * maximum(csep) .+ coff'

r1 = clugen(3, 8, 1000, [1, 1, 1], pi / 4, [10, 10, 10], 12, 3, 2.5; rng = StableRNG(321))
r2 = clugen(3, 8, 1000, [1, 1, 1], pi / 4, [10, 10, 10], 12, 3, 2.5; cluster_offset = [20, -20, 20], rng = StableRNG(321))
r3 = clugen(3, 8, 1000, [1, 1, 1], pi / 4, [10, 10, 10], 12, 3, 2.5; cluster_offset = [-50, -50, -50], clucenters_fn = centers_diag_fn, rng = StableRNG(321))

plt1 = plot(r1.points[:, 1], r1.points[:, 2], r1.points[:, 3], seriestype = :scatter, group=r1.point_clusters, markersize=2, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r1: default", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-45, 40), ylim=(-65, 40), zlim=(-50, 55))
plt2 = plot(r2.points[:, 1], r2.points[:, 2], r2.points[:, 3], seriestype = :scatter, group=r2.point_clusters,  markersize=2, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r2: cluster_offset = [20, -20, 20]", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-45, 40), ylim=(-65, 40), zlim=(-50, 55))
plt3 = plot(r3.points[:, 1], r3.points[:, 2], r3.points[:, 3], seriestype = :scatter, group=r3.point_clusters, markersize=2, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="r3: custom clucenters function", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-45, 40), ylim=(-65, 40), zlim=(-50, 55))

plt = plot(plt1, plt2, plt3, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex3d_06.png") # hide
nothing # hide
```

![](ex3d_06.png)

### Lateral dispersion and placement of point projections on the line

#### Normal projection placement (default): `proj_dist_fn = "norm"`

```@example examples
r1 = clugen(3, 4, 1000, [1, 0, 0], pi / 2, [20, 20, 20], 13, 2, 0.0; rng = StableRNG(456))
r2 = clugen(3, 4, 1000, [1, 0, 0], pi / 2, [20, 20, 20], 13, 2, 1.0; rng = StableRNG(456))
r3 = clugen(3, 4, 1000, [1, 0, 0], pi / 2, [20, 20, 20], 13, 2, 3.0; rng = StableRNG(456))

plt1 = plot(r1.points[:, 1], r1.points[:, 2], r1.points[:, 3], seriestype = :scatter, group=r1.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="r1: lateral_disp=0", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-45, 35), ylim=(-50, 40), zlim=(-40, 5))
plt2 = plot(r2.points[:, 1], r2.points[:, 2], r2.points[:, 3], seriestype = :scatter, group=r2.point_clusters,  markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="r2: lateral_disp=1", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-45, 35), ylim=(-50, 40), zlim=(-40, 5))
plt3 = plot(r3.points[:, 1], r3.points[:, 2], r3.points[:, 3], seriestype = :scatter, group=r3.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="r3: lateral_disp=3", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-45, 35), ylim=(-50, 40), zlim=(-40, 5))

plt = plot(plt1, plt2, plt3, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex3d_07.png") # hide
nothing # hide
```

![](ex3d_07.png)

#### Uniform projection placement: `proj_dist_fn = "unif"`

```@example examples
r4 = clugen(3, 4, 1000, [1, 0, 0], pi / 2, [20, 20, 20], 13, 2, 0.0; proj_dist_fn = "unif", rng = StableRNG(456))
r5 = clugen(3, 4, 1000, [1, 0, 0], pi / 2, [20, 20, 20], 13, 2, 1.0; proj_dist_fn = "unif", rng = StableRNG(456))
r6 = clugen(3, 4, 1000, [1, 0, 0], pi / 2, [20, 20, 20], 13, 2, 3.0; proj_dist_fn = "unif", rng = StableRNG(456))

plt4 = plot(r4.points[:, 1], r4.points[:, 2], r4.points[:, 3], seriestype = :scatter, group=r4.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="r4: lateral_disp=1", xlabel="x", ylabel="y", zlabel="z", xlim=(-45, 35), ylim=(-50, 40), zlim=(-40, 5))
plt5 = plot(r5.points[:, 1], r5.points[:, 2], r5.points[:, 3], seriestype = :scatter, group=r5.point_clusters,  markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="r5: lateral_disp=1", xlabel="x", ylabel="y", zlabel="z", xlim=(-45, 35), ylim=(-50, 40), zlim=(-40, 5))
plt6 = plot(r6.points[:, 1], r6.points[:, 2], r6.points[:, 3], seriestype = :scatter, group=r6.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="r6: lateral_disp=3", xlabel="x", ylabel="y", zlabel="z", xlim=(-45, 35), ylim=(-50, 40), zlim=(-40, 5))

plt = plot(plt4, plt5, plt6, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex3d_08.png") # hide
nothing # hide
```

![](ex3d_08.png)

#### Custom projection placement using the Laplace distribution

```@example examples
# Custom proj_dist_fn: point projections placed using the Laplace distribution
proj_laplace = (len, n, rng) -> rand(rng, Laplace(0, len / 6), n)

r7 = clugen(3, 4, 1000, [1, 0, 0], pi / 2, [20, 20, 20], 13, 2, 0.0; proj_dist_fn = proj_laplace, rng = StableRNG(456))
r8 = clugen(3, 4, 1000, [1, 0, 0], pi / 2, [20, 20, 20], 13, 2, 1.0; proj_dist_fn = proj_laplace, rng = StableRNG(456))
r9 = clugen(3, 4, 1000, [1, 0, 0], pi / 2, [20, 20, 20], 13, 2, 3.0; proj_dist_fn = proj_laplace, rng = StableRNG(456))

plt7 = plot(r7.points[:, 1], r7.points[:, 2], r7.points[:, 3], seriestype = :scatter, group=r7.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="r7: lateral_disp=0", xlabel="x", ylabel="y", zlabel="z", xlim=(-45, 35), ylim=(-50, 40), zlim=(-40, 5))
plt8 = plot(r8.points[:, 1], r8.points[:, 2], r8.points[:, 3], seriestype = :scatter, group=r8.point_clusters,  markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="r8: lateral_disp=1", xlabel="x", ylabel="y", zlabel="z", xlim=(-45, 35), ylim=(-50, 40), zlim=(-40, 5))
plt9 = plot(r9.points[:, 1], r9.points[:, 2], r9.points[:, 3], seriestype = :scatter, group=r9.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="r9: lateral_disp=3", xlabel="x", ylabel="y", zlabel="z", xlim=(-45, 35), ylim=(-50, 40), zlim=(-40, 5))

plt = plot(plt7, plt8, plt9, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex3d_09.png") # hide
nothing # hide
```

![](ex3d_09.png)


TODO Continue following the 2D rationale

## Examples in other dimensions

### 1D

TODO

### 5D

TODO
