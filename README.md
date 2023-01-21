![Tests](https://github.com/clugen/CluGen.jl/actions/workflows/Tests.yml/badge.svg)

# CluGen.jl

**CluGen.jl** is a Julia package for generating multidimensional clusters.
Each cluster is supported by a line segment, the position, orientation and
length of which guide where the respective points are placed. It provides the
`clugen()` function for this purpose, as well as a number of auxiliary
functions, used internally and modularly by `clugen()`. Users can swap
these auxiliary functions by their own customized versions, fine-tuning their
cluster generation strategies, or even use them as the basis for their own
generation algorithms.

## Install the package

From the registry:

```julia-repl
pkg> add CluGen
```

From GitHub:

```julia-repl
pkg> add https://github.com/clugen/CluGen.jl
```

## Citation

* Fachada, N. & de Andrade, D. (2023). Generating Multidimensional Clusters With
  Support Lines. *Under review*.

## License

[MIT License](LICENSE)