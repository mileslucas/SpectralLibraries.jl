using Documenter, SpectralLibraries

makedocs(;
    modules=[SpectralLibraries],
    format=Documenter.HTML(
        prettyurls = get(ENV, "CI", false)
    ),
    pages=[
        "Home" => "index.md",
        "Libraries" => [
            "PHOENIX ACES" => "phoenix.md",
        ],
    ],
    strict=true,
    repo="https://github.com/mileslucas/SpectralLibraries.jl/blob/{commit}{path}#L{line}",
    sitename="SpectralLibraries.jl",
    authors="Miles Lucas <mdlucas@hawaii.edu>",
)

deploydocs(;
    repo="github.com/mileslucas/SpectralLibraries.jl",
)
