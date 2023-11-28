using AdaptiveTestPlots
using Documenter
using Documenter.Remotes: GitHub

format = Documenter.HTML(prettyurls = get(ENV, "CI", "false") == "true",
    canonical = "https://JuliaPsychometricsBazaar.github.io/AdaptiveTestPlots.jl")

makedocs(;
    modules = [AdaptiveTestPlots],
    authors = "Frankie Robertson",
    repo = GitHub("JuliaPsychometricsBazaar", "AdaptiveTestPlots.jl"),
    sitename = "AdaptiveTestPlots.jl",
    format = format,
    pages = [
        "Home" => "index.md",
    ],)

deploydocs(;
    repo = "github.com/JuliaPsychometricsBazaar/AdaptiveTestPlots.jl",
    devbranch = "main",)
