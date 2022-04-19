# Home

**CluGen.jl** is a Julia package for generating multidimensional clusters using
the _clugen_ algorithm. It provides the [`clugen()`](@ref) function for this
purpose, as well as a number of auxiliary functions, used internally and
modularly by [`clugen()`](@ref). Users can swap these auxiliary functions by
their own customized versions, fine-tuning their cluster generation strategies,
or even use them as the basis for their own generation algorithms.

## Installation

### From Julia's general registry

```julia-repl
julia> using Pkg
julia> Pkg.add("CluGen")
```

### From source/GitHub

```julia-repl
julia> using Pkg
julia> Pkg.add("https://github.com/clugen/CluGen.jl")
```

## Quick examples

TO DO: 2D example

TO DO: 3D example

## Further reading

```@contents
Pages = ["theory.md", "examples.md", "api.md", "dev.md"]
```
