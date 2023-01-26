# Home

**CluGen.jl** is a Julia implementation of the *clugen* algorithm for generating
multidimensional clusters. Each cluster is supported by a line segment, the
position, orientation and length of which guide where the respective points are
placed. It provides the [`clugen()`](@ref) function for this purpose, as well as
a number of auxiliary functions, used internally and modularly by
[`clugen()`](@ref). Users can swap these auxiliary functions by their own
customized versions, fine-tuning their cluster generation strategies, or even
use them as the basis for their own generation algorithms.

## How to install

From Julia's general registry:

```julia-repl
julia> using Pkg
julia> Pkg.add("CluGen")
```

From source/GitHub:

```julia-repl
julia> using Pkg
julia> Pkg.add("https://github.com/clugen/CluGen.jl")
```

## Quick start

```@example quick
ENV["GKSwstype"] = "100" # hide
using Random # hide
Random.seed!(123) # hide
using CluGen, Plots
```

```@example quick
o = clugen(2, 4, 400, [1, 0], pi / 8, [20, 10], 10, 1, 1.5)
p = plot(o.points[:, 1], o.points[:, 2], seriestype = :scatter, group=o.clusters)
savefig(p, "ex2d_quick.svg") # hide
nothing # hide
```

![2D example](ex2d_quick.svg)

```@example quick
o = clugen(3, 4, 1000, [1, 0, 1], pi / 8, [20, 15, 25], 16, 4, 3.5)
p = plot(o.points[:, 1], o.points[:, 2], o.points[:, 3], seriestype = :scatter, group=o.clusters)
savefig(p, "ex3d_quick.svg") # hide
nothing # hide
```

![3D example](ex3d_quick.svg)

## Further reading

The *clugen* algorithm and its several implementations are detailed in the
following reference (please cite it if you use this software):

* Fachada, N. & de Andrade, D. (2023). Generating Multidimensional Clusters With
  Support Lines. <https://doi.org/10.48550/arXiv.2301.10327>.

## Also on this documentation

```@contents
Pages = ["theory.md", "examples.md", "reference.md", "dev.md"]
```
