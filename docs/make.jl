using CluGen, Documenter

DocMeta.setdocmeta!(
    CluGen, :DocTestSetup, :(using CluGen, LinearAlgebra, Random);
    recursive=true
)

makedocs(
    sitename="CluGen.jl",
    pages = [
        "Introduction" => "index.md",
        "Tutorial" => "tutorial.md",
        "Examples" => "examples.md",
        "API" => "api.md"
        ]
)