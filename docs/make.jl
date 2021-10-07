using CluGen, Documenter

DocMeta.setdocmeta!(
    CluGen, :DocTestSetup, :(using CluGen, LinearAlgebra, Random);
    recursive=true
)

makedocs(
    sitename="CluGen.jl",
    pages = [
        "Home" => "index.md",
        "Tutorial" => "tutorial.md",
        "Gallery" => "gallery.md",
        "To sort" => "to_sort.md",
        "API" => "api.md"
        ]
)