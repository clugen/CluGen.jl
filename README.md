# CluGen

TODO The README!

## Build docs

```
$ cd docs
$ julia --color=yes make.jl
```

## Run tests (from Julia REPL)

```julia
using CluGen, Pkg
Pkg.test("CluGen")
```

## Develop CluGen.jl

```julia
using Revise, CluGen, Plots, Random, LinearAlgebra, Pkg, Test, Documenter, Distributions
```
