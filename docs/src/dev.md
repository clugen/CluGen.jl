# Development

## Get the source code

```
$ git clone https://github.com/clugen/CluGen.jl.git
```

## Run tests

To run the tests, `cd` into the `CluGen.jl` folder, enter the `julia` REPL and
run the following commands:

```julia-repl
pkg> activate .

julia> import CluGen

julia> using CluGen, Pkg

julia> Pkg.test("CluGen")
```

Notes:

* Press `]` to enter the `pkg>` mode in the Julia REPL and backspace to leave
  it.
* In earlier versions of Julia it may be necessary to install dependencies by
  hand (see [Develop CluGen.jl](@ref)).

## Build the documentation

To build the documentation, and assuming we're on the `CluGen.jl` folder, run
the following commands in the terminal (requires the `Documenter` and `Plots`
packages):

```
$ cd docs
$ julia --color=yes make.jl
```

The generated documentation can be served locally with, e.g., the built-in HTTP
server in Python:

```
$ cd build
$ python3 -m http.server 9000
```

## Develop CluGen.jl

After [running the tests](@ref Run-tests), to continue developing CluGen, a number
of packages should be installed and loaded:

```julia-repl
pkg> add Revise Plots Random LinearAlgebra Pkg Test Documenter Distributions

julia> using Revise, CluGen, Plots, Random, LinearAlgebra, Pkg, Test, Documenter, Distributions
```

To contribute to CluGen, follow this code style:

* Encoding: UTF-8
* Indentation: 4 spaces (no tabs)
* Line size limit: 100 chars
* Newlines: Unix style, i.e. LF or `\n`
