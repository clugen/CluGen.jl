# Development

## Setup package for development

```julia-repl
pkg> dev https://github.com/clugen/CluGen.jl.git
```

## Run tests

```julia-repl
pkg> test CluGen
```

!!! warning

    At the moment, due to PRNG differences between Julia versions, doctests will
    only run in Julia 1.6 LTS.

## Build the documentation

!!! note

    Building the documentation requires at least Julia 1.5.

The following instructions assume we're on the `CluGen` folder (typically
located in `~/.julia/dev/`).

To build the documentation, enter the Julia REPL. Then activate the `docs`
project and install its dependencies:

```julia-repl
pkg> activate docs

pkg> instantiate
```

The documentation can now be generated from the Julia REPL:

```
julia> include("docs/make.jl")
```

Or from the system terminal:

```
$ julia --project=docs --color=yes ./docs/make.jl
```

The generated documentation can be served locally with, e.g., Python's built-in
HTTP server:

```
$ python -m http.server 9000 -d ./docs/build
```

Point your browser to <http://localhost:9000/> to read the generated
documentation.

## Useful packages for helping development

While developing CluGen, the [Revise](https://timholy.github.io/Revise.jl/stable/)
package is useful to avoid restarting the Julia session each time CluGen's code
is edited. Install it with:

```julia-repl
pkg> add Revise
```

Then load it before CluGen, e.g.:

```julia-repl
julia> using Revise, CluGen
```

## Code style

To contribute to CluGen, follow this code style:

* Encoding: UTF-8
* Indentation: 4 spaces (no tabs)
* Line size limit: 100 chars
* Newlines: Unix style, i.e. LF or `\n`
