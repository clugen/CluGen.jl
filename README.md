[![Tests](https://github.com/clugen/CluGen.jl/actions/workflows/Tests.yml/badge.svg)](https://github.com/clugen/CluGen.jl/actions/workflows/Tests.yml)
[![codecov](https://codecov.io/gh/clugen/CluGen.jl/branch/main/graph/badge.svg?token=BJQ4UUK7V2)](https://codecov.io/gh/clugen/CluGen.jl)
[![version](https://juliahub.com/docs/CluGen/version.svg)](https://juliahub.com/ui/Packages/CluGen/hiy5g)
[![pkgeval](https://juliahub.com/docs/CluGen/pkgeval.svg)](https://juliahub.com/ui/Packages/CluGen/hiy5g)
[![docs](https://img.shields.io/badge/docs-stable-blue.svg)](https://clugen.github.io/CluGen.jl/stable)
[![MIT](https://img.shields.io/badge/license-MIT-yellowgreen.svg)](https://tldrlegal.com/license/mit-license)

# CluGen.jl

**CluGen.jl** is a Julia implementation of the *clugen* algorithm for generating
multidimensional clusters with arbitrary distributions. Each cluster is supported
by a line segment, the position, orientation and length of which guide where the
respective points are placed.

See the [documentation](https://clugen.github.io/CluGen.jl/stable) and
[examples](https://clugen.github.io/CluGen.jl/stable/examples/) for more
details.

## Installation

```julia
Pkg.add("CluGen")
```

## Quick start

```julia
using CluGen, Plots
```

```julia
o = clugen(2, 4, 400, [1, 0], pi / 8, [20, 10], 10, 1, 1.5)
p = plot(o.points[:, 1], o.points[:, 2], seriestype=:scatter, group=o.clusters)
```

![2D example](https://clugen.github.io/CluGen.jl/stable/ex2d_quick.svg)

```julia
o = clugen(3, 4, 1000, [1, 0, 1], pi / 8, [20, 15, 25], 16, 4, 3.5)
p = plot(o.points[:, 1], o.points[:, 2], o.points[:, 3], seriestype=:scatter, group=o.clusters)
```

![3D example](https://clugen.github.io/CluGen.jl/stable/ex3d_quick.svg)

## See also

* [pyclugen](https://github.com/clugen/pyclugen), a Python implementation of
  the *clugen* algorithm.
* [clugenr](https://github.com/clugen/clugenr), an R implementation of the
  *clugen* algorithm.
* [MOCluGen](https://github.com/clugen/MOCluGen), a MATLAB/Octave implementation
  of the *clugen* algorithm.

## Reference

If you use this software, please cite the following reference:

* Fachada, N. & de Andrade, D. (2023). Generating multidimensional clusters
  with support lines. *Knowledge-Based Systems*, 277, 110836.
  <https://doi.org/10.1016/j.knosys.2023.110836>
  ([arXiv preprint](https://doi.org/10.48550/arXiv.2301.10327))

## License

[MIT License](LICENSE)
