# Practice

A number of examples on how to use CluGen.jl. All these examples must be
preceded with:

```@example
using CluGen, Distributions, Plots, Random, StableRNGs
```

## 2D examples

### Manipulating the direction of cluster-supporting lines

#### Using the `direction` parameter

```@example
ENV["GKSwstype"] = "100" # hide
using CluGen, Distributions, Plots, Random, StableRNGs # hide

e01 = clugen(2, 4, 200, [1, 0], 0, [10, 10], 10, 1.5, 0.5; rng = StableRNG(1))
e02 = clugen(2, 4, 200, [1, 1], 0, [10, 10], 10, 1.5, 0.5; rng = StableRNG(1))
e03 = clugen(2, 4, 200, [0, 1], 0, [10, 10], 10, 1.5, 0.5; rng = StableRNG(1))

p01 = plot(e01.points[:, 1], e01.points[:, 2], seriestype = :scatter, group=e01.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e01: direction = [1, 0]", titlefontsize=9, xlim=(-20, 20), ylim=(-25, 25))
p02 = plot(e02.points[:, 1], e02.points[:, 2], seriestype = :scatter, group=e02.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e02: direction = [1, 1]", titlefontsize=9, xlim=(-20, 20), ylim=(-25, 25))
p03 = plot(e03.points[:, 1], e03.points[:, 2], seriestype = :scatter, group=e03.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e03: direction = [0, 1]", titlefontsize=9, xlim=(-20, 20), ylim=(-25, 25))

plt = plot(p01, p02, p03, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex2d_01.png") # hide
nothing # hide
```

![](ex2d_01.png)

#### Changing the `angle_disp` parameter and using a custom `angle_deltas_fn` function

```@example
ENV["GKSwstype"] = "100" # hide
using CluGen, Distributions, Plots, Random, StableRNGs # hide

# Custom angle_deltas function: arbitrarily rotate some clusters by 90 degrees
angdel_90_fn(nclu, astd; rng=nothing) = rand(rng, [0, pi / 2], nclu)

e04 = clugen(2, 6, 500, [1, 0], 0, [10, 10], 10, 1.5, 0.5; rng = StableRNG(1))
e05 = clugen(2, 6, 500, [1, 0], pi / 8, [10, 10], 10, 1.5, 0.5; rng = StableRNG(1))
e06 = clugen(2, 6, 500, [1, 0], 0, [10, 10], 10, 1.5, 0.5; angle_deltas_fn = angdel_90_fn, rng = StableRNG(1))

p04 = plot(e04.points[:, 1], e04.points[:, 2], seriestype = :scatter, group=e04.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e04: angle_disp = 0", titlefontsize=9, xlim=(-35, 35), ylim=(-40, 20))
p05 = plot(e05.points[:, 1], e05.points[:, 2], seriestype = :scatter, group=e05.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e05: angle_disp = π/8", titlefontsize=9, xlim=(-35, 35), ylim=(-40, 20))
p06 = plot(e06.points[:, 1], e06.points[:, 2], seriestype = :scatter, group=e06.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e06: custom angle_deltas function", titlefontsize=9, xlim=(-35, 35), ylim=(-40, 20))

plt = plot(p04, p05, p06, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex2d_02.png") # hide
nothing # hide
```

![](ex2d_02.png)

### Manipulating the length of cluster-supporting lines

#### Using the `llength` parameter

```@example
ENV["GKSwstype"] = "100" # hide
using CluGen, Distributions, Plots, Random, StableRNGs # hide

e07 = clugen(2, 5, 800, [1, 0], pi / 10, [10, 10], 0, 0, 0.5; point_dist_fn = "n", rng = StableRNG(2))
e08 = clugen(2, 5, 800, [1, 0], pi / 10, [10, 10], 10, 0, 0.5; point_dist_fn = "n", rng = StableRNG(2))
e09 = clugen(2, 5, 800, [1, 0], pi / 10, [10, 10], 30, 0, 0.5; point_dist_fn = "n", rng = StableRNG(2))

p07 = plot(e07.points[:, 1], e07.points[:, 2], seriestype = :scatter, group=e07.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e07: llength = 0", titlefontsize=9, xlim=(-20, 35), ylim=(-30, 20))
p08 = plot(e08.points[:, 1], e08.points[:, 2], seriestype = :scatter, group=e08.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e08: llength = 10", titlefontsize=9, xlim=(-20, 35), ylim=(-30, 20))
p09 = plot(e09.points[:, 1], e09.points[:, 2], seriestype = :scatter, group=e09.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e09: llength = 30", titlefontsize=9, xlim=(-20, 35), ylim=(-30, 20))

plt = plot(p07, p08, p09, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex2d_03.png") # hide
nothing # hide
```

![](ex2d_03.png)

#### Changing the `llength_disp` parameter and using a custom `llengths_fn` function

```@example
ENV["GKSwstype"] = "100" # hide
using CluGen, Distributions, Plots, Random, StableRNGs # hide

# Custom llengths function: line lengths grow for each new cluster
llen_grow_fn(nclu, llen, llenstd; rng = nothing) = llen * (collect(0:(nclu - 1)) + llenstd * randn(rng, nclu))

e10 = clugen(2, 5, 800, [1, 0], pi / 10, [10, 10], 15,  0.0, 0.5; point_dist_fn = "n", rng = StableRNG(2))
e11 = clugen(2, 5, 800, [1, 0], pi / 10, [10, 10], 15, 10.0, 0.5; point_dist_fn = "n", rng = StableRNG(2))
e12 = clugen(2, 5, 800, [1, 0], pi / 10, [10, 10], 10,  0.1, 0.5; llengths_fn = llen_grow_fn, point_dist_fn = "n", rng = StableRNG(2))

p10 = plot(e10.points[:, 1], e10.points[:, 2], seriestype = :scatter, group=e10.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e10: llength_disp = 0.0", titlefontsize=9, xlim=(-20, 35), ylim=(-30, 20))
p11 = plot(e11.points[:, 1], e11.points[:, 2], seriestype = :scatter, group=e11.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e11: llength_disp = 5.0", titlefontsize=9, xlim=(-20, 35), ylim=(-30, 20))
p12 = plot(e12.points[:, 1], e12.points[:, 2], seriestype = :scatter, group=e12.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e12: custom llengths function", titlefontsize=9, xlim=(-20, 35), ylim=(-30, 20))

plt = plot(p10, p11, p12, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex2d_04.png") # hide
nothing # hide
```

![](ex2d_04.png)

### Manipulating relative cluster positions

#### Using the `cluster_sep` parameter

```@example
ENV["GKSwstype"] = "100" # hide
using CluGen, Distributions, Plots, Random, StableRNGs # hide

e13 = clugen(2, 8, 1000, [1, 1], pi / 4, [10, 10], 10, 2, 2.5; rng = StableRNG(321))
e14 = clugen(2, 8, 1000, [1, 1], pi / 4, [30, 10], 10, 2, 2.5; rng = StableRNG(321))
e15 = clugen(2, 8, 1000, [1, 1], pi / 4, [10, 30], 10, 2, 2.5; rng = StableRNG(321))

p13 = plot(e13.points[:, 1], e13.points[:, 2], seriestype = :scatter, group=e13.point_clusters, markersize=2, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e13: cluster_sep = [10, 10]", titlefontsize=9, xlim=(-120, 80), ylim=(-125, 100))
p14 = plot(e14.points[:, 1], e14.points[:, 2], seriestype = :scatter, group=e14.point_clusters, markersize=2, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e14: cluster_sep = [30, 10]", titlefontsize=9, xlim=(-120, 80), ylim=(-125, 100))
p15 = plot(e15.points[:, 1], e15.points[:, 2], seriestype = :scatter, group=e15.point_clusters, markersize=2, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e15: cluster_sep = [10, 30]", titlefontsize=9, xlim=(-120, 80), ylim=(-125, 100))

plt = plot(p13, p14, p15, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex2d_05.png") # hide
nothing # hide
```

![](ex2d_05.png)

#### Changing the `cluster_offset` parameter and using a custom `clucenters_fn` function

```@example
ENV["GKSwstype"] = "100" # hide
using CluGen, Distributions, Plots, Random, StableRNGs # hide

# Custom clucenters function: places clusters in a diagonal
centers_diag_fn(nclu, csep, coff; rng=nothing) = ones(nclu, length(csep)) .* (1:nclu) * maximum(csep) .+ coff'

e16 = clugen(2, 8, 1000, [1, 1], pi / 4, [10, 10], 10, 2, 2.5; rng = StableRNG(321))
e17 = clugen(2, 8, 1000, [1, 1], pi / 4, [10, 10], 10, 2, 2.5; cluster_offset = [20, -20], rng = StableRNG(321))
e18 = clugen(2, 8, 1000, [1, 1], pi / 4, [10, 10], 10, 2, 2.5; cluster_offset = [-50, -50], clucenters_fn = centers_diag_fn, rng = StableRNG(321))

p16 = plot(e16.points[:, 1], e16.points[:, 2], seriestype = :scatter, group=e16.point_clusters, markersize=2, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e16: default", titlefontsize=9, xlim=(-70, 70), ylim=(-70, 70))
p17 = plot(e17.points[:, 1], e17.points[:, 2], seriestype = :scatter, group=e17.point_clusters, markersize=2, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e17: cluster_offset = [20, -20]", titlefontsize=9, xlim=(-70, 70), ylim=(-70, 70))
p18 = plot(e18.points[:, 1], e18.points[:, 2], seriestype = :scatter, group=e18.point_clusters, markersize=2, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e18: custom clucenters function", titlefontsize=9, xlim=(-70, 70), ylim=(-70, 70))

plt = plot(p16, p17, p18, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex2d_06.png") # hide
nothing # hide
```

![](ex2d_06.png)

### Lateral dispersion and placement of point projections on the line

#### Normal projection placement (default): `proj_dist_fn = "norm"`

```@example
ENV["GKSwstype"] = "100" # hide
using CluGen, Distributions, Plots, Random, StableRNGs # hide

e19 = clugen(2, 4, 1000, [1, 0], pi / 2, [20, 20], 13, 2, 0.0; rng = StableRNG(456))
e20 = clugen(2, 4, 1000, [1, 0], pi / 2, [20, 20], 13, 2, 1.0; rng = StableRNG(456))
e21 = clugen(2, 4, 1000, [1, 0], pi / 2, [20, 20], 13, 2, 3.0; rng = StableRNG(456))

p19 = plot(e19.points[:, 1], e19.points[:, 2], seriestype = :scatter, group=e19.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="e19: lateral_disp=0", titlefontsize=9, xlim=(-50, 30), ylim=(-50, 30))
p20 = plot(e20.points[:, 1], e20.points[:, 2], seriestype = :scatter, group=e20.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="e20: lateral_disp=1", titlefontsize=9, xlim=(-50, 30), ylim=(-50, 30))
p21 = plot(e21.points[:, 1], e21.points[:, 2], seriestype = :scatter, group=e21.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="e21: lateral_disp=3", titlefontsize=9, xlim=(-50, 30), ylim=(-50, 30))

plt = plot(p19, p20, p21, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex2d_07.png") # hide
nothing # hide
```

![](ex2d_07.png)

#### Uniform projection placement: `proj_dist_fn = "unif"`

```@example
ENV["GKSwstype"] = "100" # hide
using CluGen, Distributions, Plots, Random, StableRNGs # hide

e22 = clugen(2, 4, 1000, [1, 0], pi / 2, [20, 20], 13, 2, 0.0; proj_dist_fn = "unif", rng = StableRNG(456))
e23 = clugen(2, 4, 1000, [1, 0], pi / 2, [20, 20], 13, 2, 1.0; proj_dist_fn = "unif", rng = StableRNG(456))
e24 = clugen(2, 4, 1000, [1, 0], pi / 2, [20, 20], 13, 2, 3.0; proj_dist_fn = "unif", rng = StableRNG(456))

p22 = plot(e22.points[:, 1], e22.points[:, 2], seriestype = :scatter, group=e22.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="e22: lateral_disp=0", titlefontsize=9, xlim=(-50, 30), ylim=(-50, 30))
p23 = plot(e23.points[:, 1], e23.points[:, 2], seriestype = :scatter, group=e23.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="e23: lateral_disp=1", titlefontsize=9, xlim=(-50, 30), ylim=(-50, 30))
p24 = plot(e24.points[:, 1], e24.points[:, 2], seriestype = :scatter, group=e24.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="e24: lateral_disp=3", titlefontsize=9, xlim=(-50, 30), ylim=(-50, 30))

plt = plot(p22, p23, p24, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex2d_08.png") # hide
nothing # hide
```

![](ex2d_08.png)

#### Custom projection placement using the Laplace distribution

```@example
ENV["GKSwstype"] = "100" # hide
using CluGen, Distributions, Plots, Random, StableRNGs # hide

# Custom proj_dist_fn: point projections placed using the Laplace distribution
proj_laplace(len, n, rng) = rand(rng, Laplace(0, len / 6), n)

e25 = clugen(2, 4, 1000, [1, 0], pi / 2, [20, 20], 13, 2, 0.0; proj_dist_fn = proj_laplace, rng = StableRNG(456))
e26 = clugen(2, 4, 1000, [1, 0], pi / 2, [20, 20], 13, 2, 1.0; proj_dist_fn = proj_laplace, rng = StableRNG(456))
e27 = clugen(2, 4, 1000, [1, 0], pi / 2, [20, 20], 13, 2, 3.0; proj_dist_fn = proj_laplace, rng = StableRNG(456))

p25 = plot(e25.points[:, 1], e25.points[:, 2], seriestype = :scatter, group=e25.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="e25: lateral_disp=0", titlefontsize=9, xlim=(-50, 30), ylim=(-50, 30))
p26 = plot(e26.points[:, 1], e26.points[:, 2], seriestype = :scatter, group=e26.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="e26: lateral_disp=1", titlefontsize=9, xlim=(-50, 30), ylim=(-50, 30))
p27 = plot(e27.points[:, 1], e27.points[:, 2], seriestype = :scatter, group=e27.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="e27: lateral_disp=3", titlefontsize=9, xlim=(-50, 30), ylim=(-50, 30))

plt = plot(p25, p26, p27, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex2d_09.png") # hide
nothing # hide
```

![](ex2d_09.png)

### Controlling final point positions from their projections on the cluster-supporting line

#### Points on hyperplane orthogonal to cluster-supporting line (default): `point_dist_fn = "n-1"`

```@example
ENV["GKSwstype"] = "100" # hide
using CluGen, Distributions, Plots, Random, StableRNGs # hide

# Custom proj_dist_fn: point projections placed using the Laplace distribution
proj_laplace(len, n, rng) = rand(rng, Laplace(0, len / 6), n)

e28 = clugen(2, 5, 1500, [1, 0], pi / 3, [20, 20], 12, 3, 1.0; rng = StableRNG(345))
e29 = clugen(2, 5, 1500, [1, 0], pi / 3, [20, 20], 12, 3, 1.0; proj_dist_fn = "unif", rng = StableRNG(345))
e30 = clugen(2, 5, 1500, [1, 0], pi / 3, [20, 20], 12, 3, 1.0; proj_dist_fn = proj_laplace, rng = StableRNG(345))

p28 = plot(e28.points[:, 1], e28.points[:, 2], seriestype = :scatter, group=e28.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="e28: proj_dist_fn=\"norm\" (default)", titlefontsize=9, xlim=(-60, 40), ylim=(-30, 60))
p29 = plot(e29.points[:, 1], e29.points[:, 2], seriestype = :scatter, group=e29.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="e29: proj_dist_fn=\"unif\"", titlefontsize=9, xlim=(-60, 40), ylim=(-30, 60))
p30 = plot(e30.points[:, 1], e30.points[:, 2], seriestype = :scatter, group=e30.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="e30: custom proj_dist_fn (Laplace)", titlefontsize=9, xlim=(-60, 40), ylim=(-30, 60))

plt = plot(p28, p29, p30, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex2d_10.png") # hide
nothing # hide
```

![](ex2d_10.png)

#### Points around projection on cluster-supporting line: `point_dist_fn = "n"`

```@example
ENV["GKSwstype"] = "100" # hide
using CluGen, Distributions, Plots, Random, StableRNGs # hide

# Custom proj_dist_fn: point projections placed using the Laplace distribution
proj_laplace(len, n, rng) = rand(rng, Laplace(0, len / 6), n)

e31 = clugen(2, 5, 1500, [1, 0], pi / 3, [20, 20], 12, 3, 1.0; point_dist_fn = "n", rng = StableRNG(345))
e32 = clugen(2, 5, 1500, [1, 0], pi / 3, [20, 20], 12, 3, 1.0; point_dist_fn = "n", proj_dist_fn = "unif", rng = StableRNG(345))
e33 = clugen(2, 5, 1500, [1, 0], pi / 3, [20, 20], 12, 3, 1.0; point_dist_fn = "n", proj_dist_fn = proj_laplace, rng = StableRNG(345))

p31 = plot(e31.points[:, 1], e31.points[:, 2], seriestype = :scatter, group=e31.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="e31: proj_dist_fn=\"norm\" (default)", titlefontsize=9, xlim=(-60, 40), ylim=(-30, 60))
p32 = plot(e32.points[:, 1], e32.points[:, 2], seriestype = :scatter, group=e32.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="e32: proj_dist_fn=\"unif\"", titlefontsize=9, xlim=(-60, 40), ylim=(-30, 60))
p33 = plot(e33.points[:, 1], e33.points[:, 2], seriestype = :scatter, group=e33.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="e33: custom proj_dist_fn (Laplace)", titlefontsize=9, xlim=(-60, 40), ylim=(-30, 60))

plt = plot(p31, p32, p33, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex2d_11.png") # hide
nothing # hide
```

![](ex2d_11.png)

#### Custom point placement using the exponential distribution

```@example
ENV["GKSwstype"] = "100" # hide
using CluGen, Distributions, Plots, Random, StableRNGs # hide

# Custom point_dist_fn: final points placed using the Exponential distribution
function clupoints_n_1_exp(projs, lat_std, len, clu_dir, clu_ctr; rng=nothing)
    dist_exp(npts, lstd, rg) = lstd .* rand(rg, Exponential(2 / lstd), npts, 1)
    return CluGen.clupoints_n_1_template(projs, lat_std, clu_dir, dist_exp; rng=rng)
end

# Custom proj_dist_fn: point projections placed using the Laplace distribution
proj_laplace(len, n, rng) = rand(rng, Laplace(0, len / 6), n)

e34 = clugen(2, 5, 1500, [1, 0], pi / 3, [20, 20], 12, 3, 1.0; point_dist_fn = clupoints_n_1_exp, rng = StableRNG(345))
e35 = clugen(2, 5, 1500, [1, 0], pi / 3, [20, 20], 12, 3, 1.0; point_dist_fn = clupoints_n_1_exp, proj_dist_fn = "unif", rng = StableRNG(345))
e36 = clugen(2, 5, 1500, [1, 0], pi / 3, [20, 20], 12, 3, 1.0; point_dist_fn = clupoints_n_1_exp, proj_dist_fn = proj_laplace, rng = StableRNG(345))

p34 = plot(e34.points[:, 1], e34.points[:, 2], seriestype = :scatter, group=e34.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="e34: proj_dist_fn=\"norm\" (default)", titlefontsize=9, xlim=(-60, 40), ylim=(-30, 60))
p35 = plot(e35.points[:, 1], e35.points[:, 2], seriestype = :scatter, group=e35.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="e35: proj_dist_fn=\"unif\"", titlefontsize=9, xlim=(-60, 40), ylim=(-30, 60))
p36 = plot(e36.points[:, 1], e36.points[:, 2], seriestype = :scatter, group=e36.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="e36: custom proj_dist_fn (Laplace)", titlefontsize=9, xlim=(-60, 40), ylim=(-30, 60))

plt = plot(p34, p35, p36, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex2d_12.png") # hide
nothing # hide
```

![](ex2d_12.png)

### Manipulating cluster sizes

```@example
ENV["GKSwstype"] = "100" # hide
using CluGen, Distributions, Plots, Random, StableRNGs # hide

# Custom clusizes_fn (e38): cluster sizes determined via the uniform distribution, no correction for total points
clusizes_unif(nclu, npts, ae; rng = nothing) = rand(rng, DiscreteUniform(1, 2 * npts / nclu), nclu)

# Custom clusizes_fn (e39): clusters all have the same size, no correction for total points
clusizes_equal(nclu, npts, ae; rng = nothing) = (npts ÷ nclu) .* ones(Integer, nclu)

# Custom clucenters_fn (all): yields fixed positions for the clusters
centers_fixed(nclu, csep, coff; rng=nothing) = [-csep[1] -csep[2]; csep[1] -csep[2]; -csep[1] csep[2]; csep[1] csep[2]]

e37 = clugen(2, 4, 1500, [1, 1], pi, [20, 20], 0, 0, 5; clucenters_fn = centers_fixed, point_dist_fn = "n", rng = StableRNG(9))
e38 = clugen(2, 4, 1500, [1, 1], pi, [20, 20], 0, 0, 5; clucenters_fn = centers_fixed, clusizes_fn = clusizes_unif, point_dist_fn = "n", rng = StableRNG(9))
e39 = clugen(2, 4, 1500, [1, 1], pi, [20, 20], 0, 0, 5; clucenters_fn = centers_fixed, clusizes_fn = clusizes_equal, point_dist_fn = "n", rng = StableRNG(9))

p37 = plot(e37.points[:, 1], e37.points[:, 2], seriestype = :scatter, group=e37.point_clusters, markersize=2, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e37: normal dist. (default)", titlefontsize=9, xlim=(-40, 40), ylim=(-40, 40))
p38 = plot(e38.points[:, 1], e38.points[:, 2], seriestype = :scatter, group=e38.point_clusters, markersize=2, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e38: unif. dist. (custom)", titlefontsize=9, xlim=(-40, 40), ylim=(-40, 40))
p39 = plot(e39.points[:, 1], e39.points[:, 2], seriestype = :scatter, group=e39.point_clusters, markersize=2, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e39: equal size (custom)", titlefontsize=9, xlim=(-40, 40), ylim=(-40, 40))

plt = plot(p37, p38, p39, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex2d_13.png") # hide
nothing # hide
```

![](ex2d_13.png)

## 3D examples

### Manipulating the direction of cluster-supporting lines

#### Using the `direction` parameter

```@example
ENV["GKSwstype"] = "100" # hide
using CluGen, Distributions, Plots, Random, StableRNGs # hide

e40 = clugen(3, 4, 500, [1, 0, 0], 0, [10, 10, 10], 15, 1.5, 0.5; rng = StableRNG(1))
e41 = clugen(3, 4, 500, [1, 1, 1], 0, [10, 10, 10], 15, 1.5, 0.5; rng = StableRNG(1))
e42 = clugen(3, 4, 500, [0, 0, 1], 0, [10, 10, 10], 15, 1.5, 0.5; rng = StableRNG(1))

p40 = plot(e40.points[:, 1], e40.points[:, 2], e40.points[:, 3], seriestype = :scatter, group=e40.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e40: direction = [1, 0, 0]", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-20,20), ylim=(-20,20), zlim=(-23,13))
p41 = plot(e41.points[:, 1], e41.points[:, 2], e41.points[:, 3], seriestype = :scatter, group=e41.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e41: direction = [1, 1, 1]", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-20,20), ylim=(-20,20), zlim=(-23,13))
p42 = plot(e42.points[:, 1], e42.points[:, 2], e42.points[:, 3], seriestype = :scatter, group=e42.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e42: direction = [0, 1, 0]", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-20,20), ylim=(-20,20), zlim=(-23,13))

plt = plot(p40, p41, p42, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex3d_01.png") # hide
nothing # hide
```

![](ex3d_01.png)

#### Changing the `angle_disp` parameter and using a custom `angle_deltas_fn` function

```@example
ENV["GKSwstype"] = "100" # hide
using CluGen, Distributions, Plots, Random, StableRNGs # hide

# Custom angle_deltas function: arbitrarily rotate some clusters by 90 degrees
angdel_90_fn(nclu, astd; rng=nothing) = rand(rng, [0, pi / 2], nclu)

e43 = clugen(3, 6, 1000, [1, 0, 0], 0, [10, 10, 10], 15, 1.5, 0.5; rng = StableRNG(2))
e44 = clugen(3, 6, 1000, [1, 0, 0], pi / 8, [10, 10, 10], 15, 1.5, 0.5; rng = StableRNG(2))
e45 = clugen(3, 6, 1000, [1, 0, 0], 0, [10, 10, 10], 15, 1.5, 0.5; angle_deltas_fn = angdel_90_fn, rng = StableRNG(2))

p43 = plot(e43.points[:, 1], e43.points[:, 2], e43.points[:, 3], seriestype = :scatter, group=e43.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e43: angle_disp = 0", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-16, 40), ylim=(-30, 25), zlim=(-35, 32))
p44 = plot(e44.points[:, 1], e44.points[:, 2], e44.points[:, 3], seriestype = :scatter, group=e44.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e44: angle_disp = π/8", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-16, 40), ylim=(-30, 25), zlim=(-35, 32))
p45 = plot(e45.points[:, 1], e45.points[:, 2], e45.points[:, 3], seriestype = :scatter, group=e45.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e45: custom angle_deltas function", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-16, 40), ylim=(-30, 25), zlim=(-35, 32))

plt = plot(p43, p44, p45, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex3d_02.png") # hide
nothing # hide
```

![](ex3d_02.png)

### Manipulating the length of cluster-supporting lines

#### Using the `llength` parameter

```@example
ENV["GKSwstype"] = "100" # hide
using CluGen, Distributions, Plots, Random, StableRNGs # hide

e46 = clugen(3, 5, 800, [1, 0, 0], pi / 10, [10, 10, 10], 0, 0, 0.5; point_dist_fn = "n", rng = StableRNG(2))
e47 = clugen(3, 5, 800, [1, 0, 0], pi / 10, [10, 10, 10], 10, 0, 0.5; point_dist_fn = "n", rng = StableRNG(2))
e48 = clugen(3, 5, 800, [1, 0, 0], pi / 10, [10, 10, 10], 30, 0, 0.5; point_dist_fn = "n", rng = StableRNG(2))

p46 = plot(e46.points[:, 1], e46.points[:, 2], e46.points[:, 3], seriestype = :scatter, group=e46.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e46: llength = 0", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-20, 40), ylim=(-30, 20), zlim=(-20, 25))
p47 = plot(e47.points[:, 1], e47.points[:, 2], e47.points[:, 3], seriestype = :scatter, group=e47.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e47: llength = 10", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-20, 40), ylim=(-30, 20), zlim=(-20, 25))
p48 = plot(e48.points[:, 1], e48.points[:, 2], e48.points[:, 3], seriestype = :scatter, group=e48.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e48: llength = 30", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-20, 40), ylim=(-30, 20), zlim=(-20, 25))

plt = plot(p46, p47, p48, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex3d_03.png") # hide
nothing # hide
```

![](ex3d_03.png)

#### Changing the `llength_disp` parameter and using a custom `llengths_fn` function

```@example
ENV["GKSwstype"] = "100" # hide
using CluGen, Distributions, Plots, Random, StableRNGs # hide

# Custom llengths function: line lengths grow for each new cluster
llen_grow_fn(nclu, llen, llenstd; rng = nothing) = llen * (collect(0:(nclu - 1)) + llenstd * randn(rng, nclu))

e49 = clugen(3, 5, 800, [1, 0, 0], pi / 10, [10, 10, 10], 15,  0.0, 0.5; point_dist_fn = "n", rng = StableRNG(2))
e50 = clugen(3, 5, 800, [1, 0, 0], pi / 10, [10, 10, 10], 15, 10.0, 0.5; point_dist_fn = "n", rng = StableRNG(2))
e51 = clugen(3, 5, 800, [1, 0, 0], pi / 10, [10, 10, 10], 10,  0.1, 0.5; llengths_fn = llen_grow_fn, point_dist_fn = "n", rng = StableRNG(2))

p49 = plot(e49.points[:, 1], e49.points[:, 2], e49.points[:, 3], seriestype = :scatter, group=e49.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e49: llength_disp = 0.0", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-20, 40), ylim=(-30, 25), zlim=(-20, 25))
p50 = plot(e50.points[:, 1], e50.points[:, 2], e50.points[:, 3], seriestype = :scatter, group=e50.point_clusters,  markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e50: llength_disp = 5.0", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-20, 40), ylim=(-30, 25), zlim=(-20, 25))
p51 = plot(e51.points[:, 1], e51.points[:, 2], e51.points[:, 3], seriestype = :scatter, group=e51.point_clusters, markersize=2.5, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e51: custom llengths function", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-20, 40), ylim=(-30, 25), zlim=(-20, 25))

plt = plot(p49, p50, p51, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex3d_04.png") # hide
nothing # hide
```

![](ex3d_04.png)

### Manipulating relative cluster positions

#### Using the `cluster_sep` parameter

```@example
ENV["GKSwstype"] = "100" # hide
using CluGen, Distributions, Plots, Random, StableRNGs # hide

e52 = clugen(3, 8, 1000, [1, 1, 1], pi / 4, [30, 10, 10], 25, 4, 3; rng = StableRNG(321))
e53 = clugen(3, 8, 1000, [1, 1, 1], pi / 4, [10, 30, 10], 25, 4, 3; rng = StableRNG(321))
e54 = clugen(3, 8, 1000, [1, 1, 1], pi / 4, [10, 10, 30], 25, 4, 3; rng = StableRNG(321))

p52 = plot(e52.points[:, 1], e52.points[:, 2], e52.points[:, 3], seriestype = :scatter, group=e52.point_clusters, markersize=2, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e52: cluster_sep = [30, 10, 10]", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-100, 100), ylim=(-100, 100), zlim=(-100, 100))
p53 = plot(e53.points[:, 1], e53.points[:, 2], e53.points[:, 3], seriestype = :scatter, group=e53.point_clusters, markersize=2, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e53: cluster_sep = [10, 30, 10]", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-100, 100), ylim=(-100, 100), zlim=(-100, 100))
p54 = plot(e54.points[:, 1], e54.points[:, 2], e54.points[:, 3], seriestype = :scatter, group=e54.point_clusters, markersize=2, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e54: cluster_sep = [10, 10, 30]", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-100, 100), ylim=(-100, 100), zlim=(-100, 100))

plt = plot(p52, p53, p54, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex3d_05.png") # hide
nothing # hide
```

![](ex3d_05.png)

#### Changing the `cluster_offset` parameter and using a custom `clucenters_fn` function

```@example
ENV["GKSwstype"] = "100" # hide
using CluGen, Distributions, Plots, Random, StableRNGs # hide

# Custom clucenters function: places clusters in a diagonal
centers_diag_fn(nclu, csep, coff; rng=nothing) = ones(nclu, length(csep)) .* (1:nclu) * maximum(csep) .+ coff'

e55 = clugen(3, 8, 1000, [1, 1, 1], pi / 4, [10, 10, 10], 12, 3, 2.5; rng = StableRNG(321))
e56 = clugen(3, 8, 1000, [1, 1, 1], pi / 4, [10, 10, 10], 12, 3, 2.5; cluster_offset = [20, -20, 20], rng = StableRNG(321))
e57 = clugen(3, 8, 1000, [1, 1, 1], pi / 4, [10, 10, 10], 12, 3, 2.5; cluster_offset = [-50, -50, -50], clucenters_fn = centers_diag_fn, rng = StableRNG(321))

p55 = plot(e55.points[:, 1], e55.points[:, 2], e55.points[:, 3], seriestype = :scatter, group=e55.point_clusters, markersize=2, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e55: default", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-45, 40), ylim=(-65, 40), zlim=(-50, 55))
p56 = plot(e56.points[:, 1], e56.points[:, 2], e56.points[:, 3], seriestype = :scatter, group=e56.point_clusters,  markersize=2, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e56: cluster_offset = [20, -20, 20]", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-45, 40), ylim=(-65, 40), zlim=(-50, 55))
p57 = plot(e57.points[:, 1], e57.points[:, 2], e57.points[:, 3], seriestype = :scatter, group=e57.point_clusters, markersize=2, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e57: custom clucenters function", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-45, 40), ylim=(-65, 40), zlim=(-50, 55))

plt = plot(p55, p56, p57, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex3d_06.png") # hide
nothing # hide
```

![](ex3d_06.png)

### Lateral dispersion and placement of point projections on the line

#### Normal projection placement (default): `proj_dist_fn = "norm"`

```@example
ENV["GKSwstype"] = "100" # hide
using CluGen, Distributions, Plots, Random, StableRNGs # hide

e58 = clugen(3, 4, 1000, [1, 0, 0], pi / 2, [20, 20, 20], 13, 2, 0.0; rng = StableRNG(456))
e59 = clugen(3, 4, 1000, [1, 0, 0], pi / 2, [20, 20, 20], 13, 2, 1.0; rng = StableRNG(456))
e60 = clugen(3, 4, 1000, [1, 0, 0], pi / 2, [20, 20, 20], 13, 2, 3.0; rng = StableRNG(456))

p58 = plot(e58.points[:, 1], e58.points[:, 2], e58.points[:, 3], seriestype = :scatter, group=e58.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="e58: lateral_disp=0", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-45, 35), ylim=(-50, 40), zlim=(-40, 5))
p59 = plot(e59.points[:, 1], e59.points[:, 2], e59.points[:, 3], seriestype = :scatter, group=e59.point_clusters,  markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="e59: lateral_disp=1", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-45, 35), ylim=(-50, 40), zlim=(-40, 5))
p60 = plot(e60.points[:, 1], e60.points[:, 2], e60.points[:, 3], seriestype = :scatter, group=e60.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="e60: lateral_disp=3", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-45, 35), ylim=(-50, 40), zlim=(-40, 5))

plt = plot(p58, p59, p60, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex3d_07.png") # hide
nothing # hide
```

![](ex3d_07.png)

#### Uniform projection placement: `proj_dist_fn = "unif"`

```@example
ENV["GKSwstype"] = "100" # hide
using CluGen, Distributions, Plots, Random, StableRNGs # hide

e61 = clugen(3, 4, 1000, [1, 0, 0], pi / 2, [20, 20, 20], 13, 2, 0.0; proj_dist_fn = "unif", rng = StableRNG(456))
e62 = clugen(3, 4, 1000, [1, 0, 0], pi / 2, [20, 20, 20], 13, 2, 1.0; proj_dist_fn = "unif", rng = StableRNG(456))
e63 = clugen(3, 4, 1000, [1, 0, 0], pi / 2, [20, 20, 20], 13, 2, 3.0; proj_dist_fn = "unif", rng = StableRNG(456))

p61 = plot(e61.points[:, 1], e61.points[:, 2], e61.points[:, 3], seriestype = :scatter, group=e61.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="e61: lateral_disp=1", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-45, 35), ylim=(-50, 40), zlim=(-40, 5))
p62 = plot(e62.points[:, 1], e62.points[:, 2], e62.points[:, 3], seriestype = :scatter, group=e62.point_clusters,  markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="e62: lateral_disp=1", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-45, 35), ylim=(-50, 40), zlim=(-40, 5))
p63 = plot(e63.points[:, 1], e63.points[:, 2], e63.points[:, 3], seriestype = :scatter, group=e63.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="e63: lateral_disp=3", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-45, 35), ylim=(-50, 40), zlim=(-40, 5))

plt = plot(p61, p62, p63, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex3d_08.png") # hide
nothing # hide
```

![](ex3d_08.png)

#### Custom projection placement using the Laplace distribution

```@example
ENV["GKSwstype"] = "100" # hide
using CluGen, Distributions, Plots, Random, StableRNGs # hide

# Custom proj_dist_fn: point projections placed using the Laplace distribution
proj_laplace(len, n, rng) = rand(rng, Laplace(0, len / 6), n)

e64 = clugen(3, 4, 1000, [1, 0, 0], pi / 2, [20, 20, 20], 13, 2, 0.0; proj_dist_fn = proj_laplace, rng = StableRNG(456))
e65 = clugen(3, 4, 1000, [1, 0, 0], pi / 2, [20, 20, 20], 13, 2, 1.0; proj_dist_fn = proj_laplace, rng = StableRNG(456))
e66 = clugen(3, 4, 1000, [1, 0, 0], pi / 2, [20, 20, 20], 13, 2, 3.0; proj_dist_fn = proj_laplace, rng = StableRNG(456))

p64 = plot(e64.points[:, 1], e64.points[:, 2], e64.points[:, 3], seriestype = :scatter, group=e64.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="e64: lateral_disp=0", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-45, 35), ylim=(-50, 40), zlim=(-40, 5))
p65 = plot(e65.points[:, 1], e65.points[:, 2], e65.points[:, 3], seriestype = :scatter, group=e65.point_clusters,  markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="e65: lateral_disp=1", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-45, 35), ylim=(-50, 40), zlim=(-40, 5))
p66 = plot(e66.points[:, 1], e66.points[:, 2], e66.points[:, 3], seriestype = :scatter, group=e66.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="e66: lateral_disp=3", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-45, 35), ylim=(-50, 40), zlim=(-40, 5))

plt = plot(p64, p65, p66, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex3d_09.png") # hide
nothing # hide
```

![](ex3d_09.png)

### Controlling final point positions from their projections on the cluster-supporting line

#### Points on hyperplane orthogonal to cluster-supporting line (default): `point_dist_fn = "n-1"`

```@example
ENV["GKSwstype"] = "100" # hide
using CluGen, Distributions, Plots, Random, StableRNGs # hide

# Custom proj_dist_fn: point projections placed using the Laplace distribution
proj_laplace(len, n, rng) = rand(rng, Laplace(0, len / 6), n)

e67 = clugen(3, 5, 1500, [1, 0, 0], pi / 3, [20, 20, 20], 22, 3, 2; rng = StableRNG(34))
e68 = clugen(3, 5, 1500, [1, 0, 0], pi / 3, [20, 20, 20], 22, 3, 2; proj_dist_fn = "unif", rng = StableRNG(34))
e69 = clugen(3, 5, 1500, [1, 0, 0], pi / 3, [20, 20, 20], 22, 3, 2; proj_dist_fn = proj_laplace, rng = StableRNG(34))

p67 = plot(e67.points[:, 1], e67.points[:, 2], e67.points[:, 3], seriestype = :scatter, group=e67.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="e67: proj_dist_fn=\"norm\" (default)", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-45, 45), ylim=(-62, 38), zlim=(-58, 38))
p68 = plot(e68.points[:, 1], e68.points[:, 2], e68.points[:, 3], seriestype = :scatter, group=e68.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="e68: proj_dist_fn=\"unif\"", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-45, 45), ylim=(-62, 38), zlim=(-58, 38))
p69 = plot(e69.points[:, 1], e69.points[:, 2], e69.points[:, 3], seriestype = :scatter, group=e69.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="e69: custom proj_dist_fn (Laplace)", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-45, 45), ylim=(-62, 38), zlim=(-58, 38))

plt = plot(p67, p68, p69, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex3d_10.png") # hide
nothing # hide
```

![](ex3d_10.png)

#### Points around projection on cluster-supporting line: `point_dist_fn = "n"`

```@example examples
ENV["GKSwstype"] = "100" # hide
using CluGen, Distributions, Plots, Random, StableRNGs # hide

# Custom proj_dist_fn: point projections placed using the Laplace distribution
proj_laplace(len, n, rng) = rand(rng, Laplace(0, len / 6), n)

e70 = clugen(3, 5, 1500, [1, 0, 0], pi / 3, [20, 20, 20], 22, 3, 2; point_dist_fn = "n", rng = StableRNG(34))
e71 = clugen(3, 5, 1500, [1, 0, 0], pi / 3, [20, 20, 20], 22, 3, 2; point_dist_fn = "n", proj_dist_fn = "unif", rng = StableRNG(34))
e72 = clugen(3, 5, 1500, [1, 0, 0], pi / 3, [20, 20, 20], 22, 3, 2; point_dist_fn = "n", proj_dist_fn = proj_laplace, rng = StableRNG(34))

p70 = plot(e70.points[:, 1], e70.points[:, 2], e70.points[:, 3], seriestype = :scatter, group=e70.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="e70: proj_dist_fn=\"norm\" (default)", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-45, 45), ylim=(-62, 38), zlim=(-58, 38))
p71 = plot(e71.points[:, 1], e71.points[:, 2], e71.points[:, 3], seriestype = :scatter, group=e71.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="e71: proj_dist_fn=\"unif\"", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-45, 45), ylim=(-62, 38), zlim=(-58, 38))
p72 = plot(e72.points[:, 1], e72.points[:, 2], e72.points[:, 3], seriestype = :scatter, group=e72.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="e72: custom proj_dist_fn (Laplace)", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-45, 45), ylim=(-62, 38), zlim=(-58, 38))

plt = plot(p70, p71, p72, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex3d_11.png") # hide
nothing # hide
```

![](ex3d_11.png)

#### Custom point placement using the exponential distribution

```@example examples
ENV["GKSwstype"] = "100" # hide
using CluGen, Distributions, Plots, Random, StableRNGs # hide

# Custom point_dist_fn: final points placed using the Exponential distribution
function clupoints_n_1_exp(projs, lat_std, len, clu_dir, clu_ctr; rng=nothing)
    dist_exp(npts, lstd, rg) = lstd .* rand(rg, Exponential(2 / lstd), npts, 1)
    return CluGen.clupoints_n_1_template(projs, lat_std, clu_dir, dist_exp; rng=rng)
end

# Custom proj_dist_fn: point projections placed using the Laplace distribution
proj_laplace(len, n, rng) = rand(rng, Laplace(0, len / 6), n)

e73 = clugen(3, 5, 1500, [1, 0, 0], pi / 3, [20, 20, 20], 22, 3, 2; point_dist_fn = clupoints_n_1_exp, rng = StableRNG(34))
e74 = clugen(3, 5, 1500, [1, 0, 0], pi / 3, [20, 20, 20], 22, 3, 2; point_dist_fn = clupoints_n_1_exp, proj_dist_fn = "unif", rng = StableRNG(34))
e75 = clugen(3, 5, 1500, [1, 0, 0], pi / 3, [20, 20, 20], 22, 3, 2; point_dist_fn = clupoints_n_1_exp, proj_dist_fn = proj_laplace, rng = StableRNG(34))

p73 = plot(e73.points[:, 1], e73.points[:, 2], e73.points[:, 3], seriestype = :scatter, group=e73.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="e73: proj_dist_fn=\"norm\" (default)", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-45, 45), ylim=(-62, 38), zlim=(-58, 38))
p74 = plot(e74.points[:, 1], e74.points[:, 2], e74.points[:, 3], seriestype = :scatter, group=e74.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="e74: proj_dist_fn=\"unif\"", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-45, 45), ylim=(-62, 38), zlim=(-58, 38))
p75 = plot(e75.points[:, 1], e75.points[:, 2], e75.points[:, 3], seriestype = :scatter, group=e75.point_clusters, markersize=2, markerstrokewidth=0.1, aspectratio=1, legend=nothing, title="e75: custom proj_dist_fn (Laplace)", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-45, 45), ylim=(-62, 38), zlim=(-58, 38))

plt = plot(p73, p74, p75, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex3d_12.png") # hide
nothing # hide
```

![](ex3d_12.png)

### Manipulating cluster sizes

```@example
ENV["GKSwstype"] = "100" # hide
using CluGen, Distributions, Plots, Random, StableRNGs # hide

# Custom clusizes_fn (e77): cluster sizes determined via the uniform distribution, no correction for total points
clusizes_unif(nclu, npts, ae; rng = nothing) = rand(rng, DiscreteUniform(1, 2 * npts / nclu), nclu)

# Custom clusizes_fn (e78): clusters all have the same size, no correction for total points
clusizes_equal(nclu, npts, ae; rng = nothing) = (npts ÷ nclu) .* ones(Integer, nclu)

# Custom clucenters_fn (all): yields fixed positions for the clusters
centers_fixed(nclu, csep, coff; rng=nothing) = [-csep[1] -csep[2] -csep[3]; csep[1] -csep[2] -csep[3]; -csep[1] csep[2] csep[3]; csep[1] csep[2] csep[3]]

e76 = clugen(3, 4, 1500, [1, 1, 1], pi, [20, 20, 20], 0, 0, 5; clucenters_fn = centers_fixed, point_dist_fn = "n", rng = StableRNG(9))
e77 = clugen(3, 4, 1500, [1, 1, 1], pi, [20, 20, 20], 0, 0, 5; clucenters_fn = centers_fixed, clusizes_fn = clusizes_unif, point_dist_fn = "n", rng = StableRNG(9))
e78 = clugen(3, 4, 1500, [1, 1, 1], pi, [20, 20, 20], 0, 0, 5; clucenters_fn = centers_fixed, clusizes_fn = clusizes_equal, point_dist_fn = "n", rng = StableRNG(9))

p76 = plot(e76.points[:, 1], e76.points[:, 2], e76.points[:, 3], seriestype = :scatter, group=e76.point_clusters, markersize=2, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e76: normal dist. (default)", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-40, 40), ylim=(-45, 39), zlim=(-43, 41))
p77 = plot(e77.points[:, 1], e77.points[:, 2], e77.points[:, 3], seriestype = :scatter, group=e77.point_clusters, markersize=2, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e77: unif. dist. (custom)", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-40, 40), ylim=(-45, 39), zlim=(-43, 41))
p78 = plot(e78.points[:, 1], e78.points[:, 2], e78.points[:, 3], seriestype = :scatter, group=e78.point_clusters, markersize=2, markerstrokewidth=0.2, aspectratio=1, legend=nothing, title="e78: equal size (custom)", titlefontsize=9, xlabel="x", ylabel="y", zlabel="z", xlim=(-40, 40), ylim=(-45, 39), zlim=(-43, 41))

plt = plot(p76, p77, p78, size=(900, 300), layout=(1, 3)) # hide
savefig(plt, "ex3d_13.png") # hide
nothing # hide
```

![](ex3d_13.png)

## Examples in other dimensions

### 1D

TODO

### 5D

TODO
