# Copyright (c) 2020-2022 Nuno Fachada, Diogo de Andrade, and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)
using CluGen, Documenter

# Generate the logo
include("logo.jl")

# Only run doctests in Julia 1.6 LTS
@static if v"1.6" ≤ VERSION < v"1.7"
    run_doctests = true
else
    run_doctests = false
end

# Set doctest metadata
DocMeta.setdocmeta!(CluGen, :DocTestSetup, :(using CluGen); recursive=true)

# Generate the documentation
makedocs(
    modules = [ CluGen ],
    sitename="CluGen documentation",
    pages = [
        "Home" => "index.md",
        "Examples" => "examples.md",
        "Theory" => "theory.md",
        "API" => "api.md",
        "Development" => "dev.md"
        ],
    doctest = run_doctests
)