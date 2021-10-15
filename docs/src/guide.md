# Guide

```@contents
Pages = ["guide.md"]
```

## What is CluGen?

CluGen is an algorithm for generating multidimensional clusters. Each cluster is
supported by a line, the position, orientation and length of which determine
where the respective points are placed.

## Overview

Given the main `direction` ``$n$``-dimensional vector, the number of clusters
(`num_clusters`), the total number of points (`num_points`), and a number of
additional parameters which will be discussed shortly, the _clugen_ algorithm
works as follows (``^*`` means the algorithm step is stochastic):

1. Normalize `direction`
2. ``^*``Determine cluster sizes
3. ``^*``Determine cluster centers
4. ``^*``Determine lengths of cluster-supporting lines
5. ``^*``Determine angles between `direction` and cluster-supporting lines
6. Determine direction of cluster-supporting lines
7. For each cluster:
   1. Determine distance of point projections from the center of the
      cluster-supporting line
   3. Determine coordinates of point projections on the line
   4. ``^*``Determine points from their projections on the line

The following image provides a stylized overview of the algorithm steps when the
main `direction` is set to ``\mathbf{v}=\begin{bmatrix}1 & 1\end{bmatrix}^T`` (thus
in 2D space), 4 clusters, and a total of 200 points. Additional parameters include
a mean cluster separation (`cluster_sep`) of 10 in both dimensions, an angle
standard deviation of ``\pi/32`` radians (``\approx{}5.6^{\circ}``)—the angle of
the main `direction` is considered the mean, line length mean (`llength`) of
10, line length standard deviation (`llength_disp`) of 1.5, and lateral
dispersion (`lateral_disp`) of 1.

```@eval
ENV["GKSwstype"] = "100"
Base.include(Main, "extras/CluGenExtras.jl")
using CluGen, LinearAlgebra, Plots, Printf, Random
Random.seed!(111)

# Create clusters
d = [1, 1]
nclu = 4
r = clugen(2, nclu, 200, d, pi/16, [10, 10], 10, 1.5, 1)
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

## Detailed description

Here we provide a detailed description of the algorithm and its parameters. We
start by looking at the mandatory parameters, then the optional ones, and then
see how it all fits together.

### Mandatory parameters

| Symbol           | Parameter         | Description                                                      |
|:---------------- |:----------------- |:---------------------------------------------------------------- |
| ``n``            | `num_dims`        | Number of dimensions.                                            |
| ``c``            | `num_clusters`    | Number of clusters.                                              |
| ``p``            | `num_points`      | Total number of points to generate.                              |
| ``\mathbf{d}``   | `direction`       | Average direction of cluster-supporting lines (``n \times 1``).  |
| ``\theta_\sigma``| `angle_disp`      | Angle dispersion of cluster-supporting lines (radians).          |
| ``\mathbf{s}``   | `cluster_sep`     | Average cluster separation (``n \times 1``).                     |
| ``l``            | `llength`         | Average length of cluster-supporting lines.                      |
| ``l_\sigma``     | `llength_disp`    | Length dispersion of cluster-supporting lines.                   |
| ``f_\sigma``     | `lateral_disp`    | Cluster lateral dispersion, i.e., dispersion of points from their projection on the cluster-supporting line. |

### Optional parameters

| Symbol              | Parameter         | Default value            | Description                                                       |
|:------------------- |:----------------- | :----------------------- | :---------------------------------------------------------------- |
| ``\phi``            | `allow_empty`     | `false`                  | Allow empty clusters?                                             |
| ``\mathbf{o}``      | `cluster_offset`  | `zeros(num_dims)`        | Offset to add to all cluster centers (``n \times 1``).            |
| ``p_\text{proj}()`` | `proj_dist_fn`    | `"norm"`                 | Distribution of point projections along cluster-supporting lines. |
| ``p_\text{final}()``| `point_dist_fn`   | `"n-1"`                  | Distribution of final points from their projections.              |
| ``c_s()``           | `clusizes_fn`     | [`clusizes()`](@ref)     | Distribution of cluster sizes.                                    |
| ``c_c()``           | `clucenters_fn`   | [`clucenters()`](@ref)   | Distribution of cluster centers.                                  |
| ``l()``             | `llengths_fn`     | [`llengths()`](@ref)     | Distribution of line lengths.                                     |
| ``\theta_\Delta()`` | `angle_deltas_fn` | [`angle_deltas()`](@ref) | Distribution of line angle deltas (w.r.t. ``\mathbf{d}``).        |

### The algorithm in detail

TODO Describe steps

## Algorithm parameters in depth

### `proj_dist_fn`

```@eval
ENV["GKSwstype"] = "100"
using CluGen, Distributions, Plots, Random

pltbg = RGB(0.92, 0.92, 0.95) #"whitesmoke"

# General cluster definitions
d = [1, 1]
nclu = 4
npts = 5000
astd = pi/16
clusep = [10, 10]
linelen = 10
linelen_std = 1.5
latstd = 1

# Different proj_dist_fn's to use
pdist_names = ("Normal", "Uniform", "Laplace", "Rayleigh")

pdists = Dict(
   pdist_names[1] => "norm",
   pdist_names[2] => "unif",
   pdist_names[3] => (len, n) -> rand(Laplace(0, len / 6), n),
   pdist_names[4] => (len, n) -> rand(Rayleigh(len / 3), n) .- len / 2
)

# Results and plots
r_all = []
p_all = []

for pd_name in pdist_names
   Random.seed!(111)
   r = clugen(2, nclu, npts, d, astd, clusep, linelen, linelen_std, latstd; proj_dist_fn=pdists[pd_name])
   push!(r_all, r)
   p = plot(r.points[:,1], r.points[:,2], seriestype = :scatter,
      group=r.point_clusters, xlim=(-35,35), ylim=(-35,35), legend=false,
      markersize=1.5, markerstrokewidth=0.1, formatter=x->"", framestyle=:grid,
      foreground_color_grid=:white, gridalpha=1, background_color_inside=pltbg,
      gridlinewidth=2, aspectratio=1, title=pd_name)
   push!(p_all, p)
end

plt = plot(p_all..., layout = (2, 2), size=(800,800))

savefig(plt, "proj_dist_fn.png")

nothing
```

![](proj_dist_fn.png)

### `point_dist_fn`

```@eval
ENV["GKSwstype"] = "100"
using CluGen, Distributions, Plots, Random

pltbg = RGB(0.92, 0.92, 0.95) #"whitesmoke"

# General cluster definitions
d = [1, 1]
nclu = 4
npts = 5000
astd = pi/16
clusep = [10, 10]
linelen = 10
linelen_std = 1.5
latstd = 1

# Different proj_dist_fn's to use
poffs_names = ("n-1", "d-1 Exponential", "d-1 Bimodal", "n", "d Hollow", "d Hollow + unif")

dist_exp = (npts, lstd) -> lstd .* rand(Exponential(2/lstd), npts, 1)
dist_bimod = (npts, lstd) -> lstd .* rand((-1, 1), npts) + lstd/3 .* randn(npts, 1)

poffs = Dict(
   poffs_names[1] => ("n-1", "norm"),
   poffs_names[2] => ((projs, lat_std, len, clu_dir, clu_ctr; rng=nothing) -> CluGen.clupoints_d_1_template(projs, lat_std, clu_dir, dist_exp; rng=rng), "norm"),
   poffs_names[3] => ((projs, lat_std, len, clu_dir, clu_ctr; rng=nothing) -> CluGen.clupoints_d_1_template(projs, lat_std, clu_dir, dist_bimod; rng=rng), "norm"),
   poffs_names[4] => ("n", "norm"),
   poffs_names[5] => (Main.CluGenExtras.clupoints_d_hollow, "norm"),
   poffs_names[6] => (Main.CluGenExtras.clupoints_d_hollow, "unif")
)

# Results and plots
r_all = []
p_all = []

for po_name in poffs_names
   Random.seed!(111)
   r = clugen(2, nclu, npts, d, astd, clusep, linelen, linelen_std, latstd; point_dist_fn=poffs[po_name][1], proj_dist_fn=poffs[po_name][2])
   push!(r_all, r)
   p = plot(r.points[:,1], r.points[:,2], seriestype = :scatter,
      group=r.point_clusters, xlim=(-35,35), ylim=(-35,35), legend=false,
      markersize=1.5, markerstrokewidth=0.1, formatter=x->"", framestyle=:grid,
      foreground_color_grid=:white, gridalpha=1, background_color_inside=pltbg,
      gridlinewidth=2, aspectratio=1, title=po_name)
   push!(p_all, p)
end

plt = plot(p_all..., layout = (2, 3), size=(1200,800))

savefig(plt, "point_dist_fn.png")

nothing
```

![](point_dist_fn.png)

### `clusizes_fn`

```@eval
ENV["GKSwstype"] = "100"
using CluGen, Distributions, Plots, Random

pltbg = RGB(0.92, 0.92, 0.95) #"whitesmoke"

# General cluster definitions
d = [1, 1]
nclu = 4
npts = 5000
astd = pi/16
clusep = [10, 10]
linelen = 10
linelen_std = 1.5
latstd = 1

# Different clusizes_fn's to use
clusz_names = ("Normal (default)", "Uniform", "Poisson", "Poisson (no fix_num_points!)")

clusz = Dict(
   clusz_names[1] => clusizes,
   clusz_names[2] => (nclu, npts, aempty; rng = Random.GLOBAL_RNG) -> CluGen.fix_num_points!(rand(rng, DiscreteUniform(1, 2 * npts / nclu), nclu), npts), # Never empty since we're starting at 1
   clusz_names[3] => (nclu, npts, aempty; rng = Random.GLOBAL_RNG) -> CluGen.fix_empty!(CluGen.fix_num_points!(rand(rng, Poisson(npts / nclu), nclu), npts), aempty),
   clusz_names[4] => (nclu, npts, aempty; rng = Random.GLOBAL_RNG) -> CluGen.fix_empty!(rand(rng, Poisson(npts / nclu), nclu), aempty)
)

# Plots
p_all = []
cluszs_all = Dict()
maxclu = 0

for csz_name in clusz_names

   Random.seed!(111)

   cluszs_all[csz_name] = clusz[csz_name](nclu, npts, false)

   if maximum(cluszs_all[csz_name]) > maxclu
      global maxclu = maximum(cluszs_all[csz_name])
   end

end

for csz_name in clusz_names

   p = plot(title=csz_name, legend=false, showaxis=false,
      foreground_color_axis=ARGB(1,1,1,0), grid=false, ticks=[], aspectratio=1)

   Main.CluGenExtras.plot_clusizes!(p, cluszs_all[csz_name]; maxsize = maxclu)

   push!(p_all, p)
end

plt = plot(p_all..., layout = (2, 2), size=(800,800))

savefig(plt, "clusizes.png")

nothing
```

![](clusizes.png)

### `clucenters_fn`


```@eval
ENV["GKSwstype"] = "100"
using CluGen, Distributions, Plots, Random

pltbg = RGB(0.92, 0.92, 0.95) #"whitesmoke"

# General cluster definitions
d = [1, 1]
nclu = 4
npts = 5000
astd = pi/16
clusep = [10, 10]
linelen = 10
linelen_std = 1.5
latstd = 1

# Different clucenter_fn's to use
cluctr_names = ("Uniform (default)", "Hand-picked")

cluctr = Dict(
   cluctr_names[1] => clucenters,
   cluctr_names[2] => (nclu, clusep, cluoff; rng = Random.GLOBAL_RNG) -> rand(rng, nclu, length(clusep)) .* 0 + [-20 -20; -20 20; 20 20; 20 -20]
)

# Results and plots
r_all = []
p_all = []

for cluc_name in cluctr_names
   Random.seed!(111)
   r = clugen(2, nclu, npts, d, astd, clusep, linelen, linelen_std, latstd; clucenters_fn = cluctr[cluc_name])
   push!(r_all, r)
   p = plot(r.points[:,1], r.points[:,2], seriestype = :scatter,
      group=r.point_clusters, xlim=(-35,35), ylim=(-35,35), legend=false,
      markersize=1.5, markerstrokewidth=0.1, formatter=x->"", framestyle=:grid,
      foreground_color_grid=:white, gridalpha=1, background_color_inside=pltbg,
      gridlinewidth=2, aspectratio=1, title=cluc_name)
   push!(p_all, p)
end

plt = plot(p_all..., layout = (1, 2), size=(800,400))

savefig(plt, "clucenters.png")

nothing
```

![](clucenters.png)


### `llengths_fn`

```@eval
ENV["GKSwstype"] = "100"
using CluGen, Distributions, Plots, Random

pltbg = RGB(0.92, 0.92, 0.95) #"whitesmoke"

# General cluster definitions
d = [1, 1]
nclu = 4
npts = 5000
astd = 0 # To better see line lengths
clusep = [10, 10]
linelen = 10
linelen_std = 1.5
latstd = 0 # To better see line lengths

# Different llengths_fn's to use
ll_names = ("Normal (default)", "Poisson", "Uniform", "Hand-picked")

ll = Dict(
   ll_names[1] => llengths,
   ll_names[2] => (nclu, ll, llstd; rng=Random.GLOBAL_RNG) -> rand(rng, Poisson(ll), nclu),
   ll_names[3] => (nclu, ll, llstd; rng=Random.GLOBAL_RNG) -> rand(rng, DiscreteUniform(0, ll * 2), nclu),
   ll_names[4] => (nclu, ll, llstd; rng=Random.GLOBAL_RNG) -> rand(rng, nclu) .* 0 + [2, 8, 16, 32]
)

# Results and plots
r_all = []
p_all = []

for ll_name in ll_names
   Random.seed!(111)
   r = clugen(2, nclu, npts, d, astd, clusep, linelen, linelen_std, latstd; llengths_fn = ll[ll_name], proj_dist_fn="unif")
   push!(r_all, r)
   p = plot(r.points[:,1], r.points[:,2], seriestype = :scatter,
      group=r.point_clusters, xlim=(-35,35), ylim=(-35,35), legend=false,
      markersize=1.5, markerstrokewidth=0.1, formatter=x->"", framestyle=:grid,
      foreground_color_grid=:white, gridalpha=1, background_color_inside=pltbg,
      gridlinewidth=2, aspectratio=1, title=ll_name)
   push!(p_all, p)
end

plt = plot(p_all..., layout = (2, 2), size=(800,800))

savefig(plt, "llengths.png")

nothing
```

![](llengths.png)

### `angle_deltas_fn`


```@eval
ENV["GKSwstype"] = "100"
using CluGen, Distributions, Plots, Random

pltbg = RGB(0.92, 0.92, 0.95) #"whitesmoke"

# General cluster definitions
d = [1, 1]
nclu = 4
npts = 5000
astd = pi/16
clusep = [10, 10]
linelen = 10
linelen_std = 0 # To better see line angles
latstd = 0 # To better see line angles

# Different angle_deltas_fn's to use
la_names = ("Wrapped Normal (default)", "Hand-picked")

la = Dict(
   la_names[1] => angle_deltas,
   la_names[2] => (nclu, astd; rng=Random.GLOBAL_RNG) -> rand(rng, nclu) .* 0 + [0, pi/2, 0, pi/2]
)

# Results and plots
r_all = []
p_all = []

for la_name in la_names
   Random.seed!(111)
   r = clugen(2, nclu, npts, d, astd, clusep, linelen, linelen_std, latstd; angle_deltas_fn = la[la_name], proj_dist_fn="unif")
   push!(r_all, r)
   p = plot(r.points[:,1], r.points[:,2], seriestype = :scatter,
      group=r.point_clusters, xlim=(-35,35), ylim=(-35,35), legend=false,
      markersize=1.5, markerstrokewidth=0.1, formatter=x->"", framestyle=:grid,
      foreground_color_grid=:white, gridalpha=1, background_color_inside=pltbg,
      gridlinewidth=2, aspectratio=1, title=la_name)
   push!(p_all, p)
end

plt = plot(p_all..., layout = (1, 2), size=(800,400))

savefig(plt, "angle_deltas.png")

nothing
```

![](angle_deltas.png)

