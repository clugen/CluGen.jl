using CluGen, Documenter

DocMeta.setdocmeta!(
    CluGen, :DocTestSetup, :(using CluGen, LinearAlgebra, Random);
    recursive=true
)

makedocs(
    sitename="CluGen.jl",
    pages = [
        "Home" => "index.md",
        "Guide" => "guide.md",
        "Gallery" => "gallery.md",
        "API" => "api.md"
        ]
)