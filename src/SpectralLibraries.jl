module SpectralLibraries


abstract type AbstractSpectralLibrary end

include("phoenix.jl")

# Register datadep
function __init__()
    using DataDeps
    register(DataDep("PHOENIX_MODELS",
        "Download master PHOENIX ACES models file",
        "https://github.com/mileslucas/SpectralLibraries.jl/raw/master/data/PHOENIX_MODELS.csv",
        "8cebcb86999e90d2d2d7c49381574ba1b97edcd784a43cf87772e058e3fbe177"))
end

end # module
