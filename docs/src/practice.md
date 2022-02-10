# Practice

A number of examples on how to use CluGen.jl. All these examples must be
preceded with:

```julia-repl
julia> using CluGen, Plots, StableRNGs
```

## 2D examples

### Example 1: basic parameters

Let's start with a basic 2D example:

```julia-repl
julia> r = clugen(2, 4, 200, [1, 1], pi / 16, [10, 10], 10, 1.5, 1) # Invoke clugen()

julia> plt = plot(r.points[:,1], r.points[:,2], seriestype = :scatter, group=r.point_clusters)
```

Which results in the following cluster configuration:

```@eval
ENV["GKSwstype"] = "100"
using CluGen, Plots, StableRNGs

# Create clusters
r = clugen(2, 4, 200, [1,1], pi/16, [10,10], 10, 1.5, 1; rng = StableRNG(1))
plt = plot(r.points[:,1], r.points[:,2], seriestype = :scatter, group=r.point_clusters)
plot!(plt,aspectratio=1,size=(500,300), xlims=(-33, 33), ylims=(-22, 22))

savefig(plt, "ex2d_01.png")

nothing
```

![](ex2d_01.png)

In this example [`clugen()`](@ref) was invoked with the following parameters:

* `2` - Dimensions, 2D in this case.
* `4` - Number of clusters.
* `200` - Total number of points.
* `[1, 1]` - Main direction (notice the general direction of the clusters).
* `pi / 16` - Angle dispersion. By default and broadly speaking, cluster
  directions are obtain from the normal distribution, and this value represents
  the standard deviation.
* `[10, 10]` - The average cluster separation in each dimension. See
  [`CluGen.clucenters()`](@ref) to understand how these values affect how
  cluster centers are determined by default.
* `10` - The mean length of the cluster-supporting lines, considering these
  lengths are drawn from the normal distribution by default.
* `1.5` - Consider this value the respective standard deviation of the line
  lengths.
* `1` - Lateral dispersion, or how much points can spread from the respective
  cluster-supporting line.


### Example 2: reproducibility

Cluster generation can be made reproducible by previously [setting a
seed](https://docs.julialang.org/en/v1/stdlib/Random/#Random.seed!), or by
specifying a random-number generator (RNG) as an optional parameter. Julia
provides several RNGs, but these do not guarantee the same stream of random
numbers between Julia versions. For this purpose we can use the RNG from the
[StableRNGs](https://github.com/JuliaRandom/StableRNGs.jl). The following
instructions uses the same parameters as in the previous example, but also
specifies a PRNG:

```julia-repl
julia> r = clugen(2, 4, 200, [1, 1], pi / 16, [10, 10], 10, 1.5, 1; rng = StableRNG(123))
```

This yields the following cluster configuration:

```@eval
ENV["GKSwstype"] = "100"
using CluGen, Plots, StableRNGs

# Create clusters
r = clugen(2, 4, 200, [1,1], pi/16, [10,10], 10, 1.5, 1; rng = StableRNG(123))
plt = plot(r.points[:,1], r.points[:,2], seriestype = :scatter, group=r.point_clusters)
plot!(plt,aspectratio=1,size=(500,300),xlims=(-33, 33), ylims=(-22, 22))

savefig(plt, "ex2d_02.png")

nothing
```

![](ex2d_02.png)

### Example 3: changing a few basic parameters

Let's change a number of basic parameters:

```julia-repl
julia> r = clugen(2, 5, 1000, [0,1], pi/8, [10,30], 50, 15, 1; rng = StableRNG(11))
```

We now have one more cluster (`5` instead of `4`), many more points (`1000`
instead of `200`), up direction (`[0, 1]`) with greater angle dispersion
(`pi / 8`), different cluster separation in each dimension (`[10, 30]`), and
longer cluster-supporting lines (with mean set to `50` and standard deviation to
`15`). This yields the following cluster distribution:

```@eval
ENV["GKSwstype"] = "100"
using CluGen, Plots, StableRNGs

# Create clusters
r = clugen(2, 5, 1000, [0,1], pi/8, [10,30], 50, 15, 1; rng = StableRNG(11))
plt = plot(r.points[:,1], r.points[:,2], seriestype = :scatter, group=r.point_clusters, markersize = 2)
plot!(plt,aspectratio=1,size=(500,300))

savefig(plt, "ex2d_03.png")

nothing
```

![](ex2d_03.png)

### Example 4: changing lateral dispersion


### Advanced parameters

TODO

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
