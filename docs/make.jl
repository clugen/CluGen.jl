using CluGen, Documenter

DocMeta.setdocmeta!(CluGen, :DocTestSetup, :(using CluGen, Random); recursive=true)

makedocs(sitename="CluGen.jl documentation")