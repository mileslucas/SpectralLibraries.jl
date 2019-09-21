using Documenter, SpectralLibraries

makedocs(;
    modules=[SpectralLibraries],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/mileslucas/SpectralLibraries.jl/blob/{commit}{path}#L{line}",
    sitename="SpectralLibraries.jl",
    authors="Miles Lucas <mdlucas@hawaii.edu>",
    assets=String[],
)

deploydocs(;
    repo="github.com/mileslucas/SpectralLibraries.jl",
)
