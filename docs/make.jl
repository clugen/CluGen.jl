using CluGen, Documenter

DocMeta.setdocmeta!(
    CluGen, :DocTestSetup, :(using CluGen, LinearAlgebra, Random);
    recursive=true
)

makedocs(
    modules = [ CluGen ],
    sitename="CluGen.jl",
    pages = [
        "Home" => "index.md",
        "Practice" => "practice.md",
        "Theory" => "theory.md",
        "API" => "api.md",
        "Development" => "dev.md"
        ]
)