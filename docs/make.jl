# Copyright (c) 2020-2023 Nuno Fachada, Diogo de Andrade, and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)
using CluGen, Documenter

# Generate the logo
include("logo.jl")

# Include the CluGenExtras module, necessary for building the docs
include("./CluGenExtras.jl")

# Only run doctests in Julia 1.6 LTS
@static if v"1.6" ≤ VERSION < v"1.7"
    run_doctests = true
else
    run_doctests = false
end

# Set doctest metadata
DocMeta.setdocmeta!(CluGen, :DocTestSetup, :(using CluGen); recursive=true)

# Generate the documentation
makedocs(;
    modules=[CluGen],
    sitename="CluGen documentation",
    format=Documenter.HTML(; assets=["assets/favicon.ico"]),
    pages=[
        "Home" => "index.md",
        "Theory" => "theory.md",
        "Examples" => "examples.md",
        "API" => "api.md",
        "Development" => "dev.md",
    ],
    doctest=run_doctests,
)

deploydocs(; repo="github.com/clugen/CluGen.jl.git", forcepush=true)