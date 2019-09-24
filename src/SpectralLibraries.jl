module SpectralLibraries


abstract type AbstractSpectralLibrary end

include("phoenix.jl")

# Register datadep
function __init__()
    using DataDeps
    register(DataDep("PHOENIX_MODELS",
        "Download master PHOENIX ACES models file",
        "https://github.com/mileslucas/SpectralLibraries.jl/raw/master/data/PHOENIX_MODELS.csv"))
end

end # module
