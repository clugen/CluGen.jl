# CluGen

TODO The README!

## Install the package

From registry:

```julia-repl
pkg> add CluGen
```

From GitHub:

```julia-repl
pkg> add https://github.com/clugen/CluGen.jl
```

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
