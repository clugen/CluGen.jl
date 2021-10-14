# Guide

```@contents
Pages = ["guide.md"]
```

## What is CluGen?

CluGen is an algorithm for generating multidimensional clusters. Each cluster is
supported by a line, the position, orientation and length of which guide where
the respective points are placed.

## Overview

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
main `direction` is set to ``\mathbf{v}=\begin{bmatrix}1 & 1\end{bmatrix}^T`` (thus
in 2D space), 4 clusters, and a total of 200 points. Additional parameters include
a mean cluster separation (`cluster_sep`) of 10 in both dimensions, an angle
standard deviation of ``\pi/32`` radians (``\approx{}5.6^{\circ}``)—the angle of
the main `direction` is considered the mean, line length mean (`line_length`) of
10, line length standard deviation (`line_length_std`) of 1.5, and lateral
dispersion (`lateral_std`) of 1.

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

| Math             | Code           | Description           |
|:---------------- |:-------------- |:--------------------- |
| ``d``            | `num_dims`     | Number of dimensions. |
| ``n``            | `num_clusters` | Number of clusters.   |
| ``p_\text{tot}`` | `total_points` | Total points.         |
| ``\mathbf{v}``   | `direction`    | Main direction.       |


TODO Describe steps

## Algorithm parameters in depth

### `point_dist`

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

# Different point_dist's to use
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
   r = clugen(2, nclu, npts, d, astd, clusep, linelen, linelen_std, latstd; point_dist=pdists[pd_name])
   push!(r_all, r)
   p = plot(r.points[:,1], r.points[:,2], seriestype = :scatter,
      group=r.point_clusters, xlim=(-35,35), ylim=(-35,35), legend=false,
      markersize=1.5, markerstrokewidth=0.1, formatter=x->"", framestyle=:grid,
      foreground_color_grid=:white, gridalpha=1, background_color_inside=pltbg,
      gridlinewidth=2, aspectratio=1, title=pd_name)
   push!(p_all, p)
end

plt = plot(p_all..., layout = (2, 2), size=(800,800))

savefig(plt, "point_dist.png")

nothing
```

![](point_dist.png)

### `point_offset`

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

# Different point_dist's to use
poffs_names = ("d-1", "d-1 Exponential", "d-1 Bimodal", "d", "d Hollow", "d Hollow + unif")

dist_exp = (npts, lstd) -> lstd .* rand(Exponential(2/lstd), npts, 1)
dist_bimod = (npts, lstd) -> lstd .* rand((-1, 1), npts) + lstd/3 .* randn(npts, 1)

poffs = Dict(
   poffs_names[1] => ("d-1", "norm"),
   poffs_names[2] => ((projs, lat_std, len, clu_dir, clu_ctr; rng=nothing) -> CluGen.clupoints_d_1_template(projs, lat_std, clu_dir, dist_exp; rng=rng), "norm"),
   poffs_names[3] => ((projs, lat_std, len, clu_dir, clu_ctr; rng=nothing) -> CluGen.clupoints_d_1_template(projs, lat_std, clu_dir, dist_bimod; rng=rng), "norm"),
   poffs_names[4] => ("d", "norm"),
   poffs_names[5] => (Main.CluGenExtras.clupoints_d_hollow, "norm"),
   poffs_names[6] => (Main.CluGenExtras.clupoints_d_hollow, "unif")
)

# Results and plots
r_all = []
p_all = []

for po_name in poffs_names
   Random.seed!(111)
   r = clugen(2, nclu, npts, d, astd, clusep, linelen, linelen_std, latstd; point_offset=poffs[po_name][1], point_dist=poffs[po_name][2])
   push!(r_all, r)
   p = plot(r.points[:,1], r.points[:,2], seriestype = :scatter,
      group=r.point_clusters, xlim=(-35,35), ylim=(-35,35), legend=false,
      markersize=1.5, markerstrokewidth=0.1, formatter=x->"", framestyle=:grid,
      foreground_color_grid=:white, gridalpha=1, background_color_inside=pltbg,
      gridlinewidth=2, aspectratio=1, title=po_name)
   push!(p_all, p)
end

plt = plot(p_all..., layout = (2, 3), size=(1200,800))

savefig(plt, "point_offset.png")

nothing
```

![](point_offset.png)

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
clusz_names = ("Normal (default)", "Uniform", "Poisson", "Poisson (no fix_total_points!)")

clusz = Dict(
   clusz_names[1] => clusizes,
   clusz_names[2] => (nclu, npts, aempty; rng = Random.GLOBAL_RNG) -> CluGen.fix_total_points!(rand(rng, DiscreteUniform(1, 2 * npts / nclu), nclu), npts), # Never empty since we're starting at 1
   clusz_names[3] => (nclu, npts, aempty; rng = Random.GLOBAL_RNG) -> CluGen.fix_empty!(CluGen.fix_total_points!(rand(rng, Poisson(npts / nclu), nclu), npts), aempty),
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


### `line_lengths_fn`

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

# Different line_lengths_fn's to use
ll_names = ("Normal (default)", "Poisson", "Uniform", "Hand-picked")

ll = Dict(
   ll_names[1] => line_lengths,
   ll_names[2] => (nclu, ll, llstd; rng=Random.GLOBAL_RNG) -> rand(rng, Poisson(ll), nclu),
   ll_names[3] => (nclu, ll, llstd; rng=Random.GLOBAL_RNG) -> rand(rng, DiscreteUniform(0, ll * 2), nclu),
   ll_names[4] => (nclu, ll, llstd; rng=Random.GLOBAL_RNG) -> rand(rng, nclu) .* 0 + [2, 8, 16, 32]
)

# Results and plots
r_all = []
p_all = []

for ll_name in ll_names
   Random.seed!(111)
   r = clugen(2, nclu, npts, d, astd, clusep, linelen, linelen_std, latstd; line_lengths_fn = ll[ll_name], point_dist="unif")
   push!(r_all, r)
   p = plot(r.points[:,1], r.points[:,2], seriestype = :scatter,
      group=r.point_clusters, xlim=(-35,35), ylim=(-35,35), legend=false,
      markersize=1.5, markerstrokewidth=0.1, formatter=x->"", framestyle=:grid,
      foreground_color_grid=:white, gridalpha=1, background_color_inside=pltbg,
      gridlinewidth=2, aspectratio=1, title=ll_name)
   push!(p_all, p)
end

plt = plot(p_all..., layout = (2, 2), size=(800,800))

savefig(plt, "line_lengths.png")

nothing
```

![](line_lengths.png)

### `line_angles_fn`


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

# Different line_angles_fn's to use
la_names = ("Wrapped Normal (default)", "Hand-picked")

la = Dict(
   la_names[1] => line_angles,
   la_names[2] => (nclu, astd; rng=Random.GLOBAL_RNG) -> rand(rng, nclu) .* 0 + [0, pi/2, 0, pi/2]
)

# Results and plots
r_all = []
p_all = []

for la_name in la_names
   Random.seed!(111)
   r = clugen(2, nclu, npts, d, astd, clusep, linelen, linelen_std, latstd; line_angles_fn = la[la_name], point_dist="unif")
   push!(r_all, r)
   p = plot(r.points[:,1], r.points[:,2], seriestype = :scatter,
      group=r.point_clusters, xlim=(-35,35), ylim=(-35,35), legend=false,
      markersize=1.5, markerstrokewidth=0.1, formatter=x->"", framestyle=:grid,
      foreground_color_grid=:white, gridalpha=1, background_color_inside=pltbg,
      gridlinewidth=2, aspectratio=1, title=la_name)
   push!(p_all, p)
end

plt = plot(p_all..., layout = (1, 2), size=(800,400))

savefig(plt, "line_angles.png")

nothing
```

![](line_angles.png)

