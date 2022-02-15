# Copyright (c) 2020-2022 Nuno Fachada, Diogo de Andrade, and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)
using CluGen, Documenter

# Generate the logo
include("logo.jl")

DocMeta.setdocmeta!(CluGen, :DocTestSetup, :(using CluGen); recursive=true)

makedocs(
    modules = [ CluGen ],
    sitename="CluGen documentation",
    pages = [
        "Home" => "index.md",
        "Examples" => "examples.md",
        "Theory" => "theory.md",
        "API" => "api.md",
        "Development" => "dev.md"
        ]
)