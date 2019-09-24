var documenterSearchIndex = {"docs":
[{"location":"phoenix/#phoenix-1","page":"PHOENIX ACES","title":"PHOENIX ACES","text":"","category":"section"},{"location":"phoenix/#","page":"PHOENIX ACES","title":"PHOENIX ACES","text":"The models can be downloaded from the ftp server by following these instructions","category":"page"},{"location":"phoenix/#Getting-the-Models-1","page":"PHOENIX ACES","title":"Getting the Models","text":"","category":"section"},{"location":"phoenix/#","page":"PHOENIX ACES","title":"PHOENIX ACES","text":"ALL_PHOENIX_MODELS\ndownload_PHOENIX_model","category":"page"},{"location":"phoenix/#SpectralLibraries.ALL_PHOENIX_MODELS","page":"PHOENIX ACES","title":"SpectralLibraries.ALL_PHOENIX_MODELS","text":"ALL_PHOENIX_MODELS\n\nDataFrames.DataFrame of every single available PHOENIX ACES model.\n\n\n\n\n\n","category":"constant"},{"location":"phoenix/#SpectralLibraries.download_PHOENIX_model","page":"PHOENIX ACES","title":"SpectralLibraries.download_PHOENIX_model","text":"download_PHOENIX_model(::DataFrame   ; path=\"PHOENIX\")\ndownload_PHOENIX_model(::DataFrameRow; path=\"PHOENIX\")\n\nGiven a row or subframe from the ALL_PHOENIX_MODELS dataframe, download into the given path making all directories on the way. Files are downloaded from the Goettingen HTTP server and should not be abused. This will also download the wavelength file if it is not already present.\n\nwarning: Warning\nDo not abuse the Goettingen HTTP server by spamming this function!\n\nExamples\n\njulia> size(ALL_PHOENIX_MODELS, 1)\n27605\n\njulia> subset = filter(r -> 6000 ≤ r.T ≤ 6300 && 4.0 ≤ r.logg ≤ 4.5 && r.Z == 0 && r.α == 0, a);\n\njulia> size(subset, 1)\n8\n\njulia> download_PHOENIX_model(subset)\n[ Info: Downloading wavelength file to PHOENIX/WAVE_PHOENIX-ACES-AGSS-COND-2011.fits\n[ Info: Downloading model to PHOENIX/Z-0.0/lte06200-4.00-0.0.PHOENIX-ACES-AGSS-COND-2011-HiRes.fits\n[ Info: Downloading model to PHOENIX/Z-0.0/lte06300-4.00-0.0.PHOENIX-ACES-AGSS-COND-2011-HiRes.fits\n[ Info: Downloading model to PHOENIX/Z-0.0/lte06100-4.00-0.0.PHOENIX-ACES-AGSS-COND-2011-HiRes.fits\n[ Info: Downloading model to PHOENIX/Z-0.0/lte06000-4.00-0.0.PHOENIX-ACES-AGSS-COND-2011-HiRes.fits\n[ Info: Downloading model to PHOENIX/Z-0.0/lte06200-4.50-0.0.PHOENIX-ACES-AGSS-COND-2011-HiRes.fits\n[ Info: Downloading model to PHOENIX/Z-0.0/lte06300-4.50-0.0.PHOENIX-ACES-AGSS-COND-2011-HiRes.fits\n[ Info: Downloading model to PHOENIX/Z-0.0/lte06100-4.50-0.0.PHOENIX-ACES-AGSS-COND-2011-HiRes.fits\n[ Info: Downloading model to PHOENIX/Z-0.0/lte06000-4.50-0.0.PHOENIX-ACES-AGSS-COND-2011-HiRes.fits\n\n\n\n\n\n\n","category":"function"},{"location":"phoenix/#Using-the-Models-1","page":"PHOENIX ACES","title":"Using the Models","text":"","category":"section"},{"location":"phoenix/#","page":"PHOENIX ACES","title":"PHOENIX ACES","text":"PHOENIX\nupdate!\nwave\nparams\nlength\nfilter\nfilter!\nsort\nsort!","category":"page"},{"location":"phoenix/#SpectralLibraries.PHOENIX","page":"PHOENIX ACES","title":"SpectralLibraries.PHOENIX","text":"PHOENIX(path)\n\nStellar Atmosphere Spectra from Husser et al. (2013)\n\nThis interfaces the PHOENIX ACES models as computed by Husser et al. (2013). It is parametrized by the following:\n\nParameter Range Description\nT [2300, 12000] Teff - The effective temperature in Kelvin\nlogg [0.0, 6.0] log(g) - The surface gravity in log-solar units\nZ [-4.0, 1.0] [Fe/H] - The iron fraction in log-solar units\nα [-0.2, 1.2] [α/M] - The helium concentration fraction\n\nThe files must be organized the same way they are organized on the Göttinghen servers, as this constructs a table mapping the parameters to each discovered filename.\n\nReferences\n\n[1] Husser et al. (2013)\n\nExamples\n\njulia> grid = PHOENIX(\"PHOENIX\")\nPHOENIX ACES Stellar Atmosphere Spectral Library (Husser et al. 2013)\npath           = PHOENIX\nparameters     = T, logg, Z, α\nunits          = wave (Å), flux (erg cm^-3 s^-1)\nnum. available = 659\n\n# Indexing\njulia> grid[1]\n(T = 5700, logg = 3.5, Z = 0.5, α = 0.0) => Float32[2.3576384e-16, 2.3964725e-16, 2.4359302e-16, 2.4760205e-16, 2.516754e-16, 2.5581404e-16, 2.60019e-16, 2.642913e-16, 2.6863203e-16, 2.7304218e-16  …  1.06697366e12, 1.146122e12, 1.1551366e12, 1.1556633e12, 1.1557706e12, 1.1557903e12, 1.1554768e12, 1.1539062e12, 1.1525517e12, 1.1532526e12]\n\n# We can iterate over the library\njulia> [println(model.T) for (model, flux) in grid[[1, 100, 500]]];\n5700\n7200\n7400\n\n# Accessing certain parameters\njulia> grid.logg[1:10]\n10-element Array{Float64,1}:\n 3.5\n 4.0\n 4.5\n 5.0\n 5.5\n 6.0\n 3.5\n 4.0\n 4.5\n 5.0\n\n\n\n\n\n\n(::PHOENIX)(T, logg, Z, α=0; use_units=false)\n\nReturn the flux density of the model at the given parameters. Raises an error if the model cannot be found. If use_units is true, will return the flux density as a Unitful.Quantity with the appropriate units.\n\nExamples\n\njulia> grid = PHOENIX(\"PHOENIX\")\nPHOENIX ACES Stellar Atmosphere Spectral Library (Husser et al. 2013)\npath           = PHOENIX\nparameters     = T, logg, Z, α\nunits          = wave (Å), flux (erg cm^-3 s^-1)\nnum. available = 659\n\njulia> grid(6000, 4.5, 0)[1:10]\n10-element Array{Float32,1}:\n 9.125983e-13 \n 9.261124e-13 \n 9.398209e-13 \n 9.537266e-13 \n 9.67832e-13  \n 9.821403e-13 \n 9.966539e-13 \n 1.011376e-12 \n 1.0263094e-12\n 1.0414569e-12\n\njulia> grid(6000, 4.5, 0, use_units=true)[1:10]\n10-element Array{Unitful.Quantity{Float32,𝐌*𝐋^-1*𝐓^-3,Unitful.FreeUnits{(erg, cm^-3, s^-1),𝐌*𝐋^-1*𝐓^-3,nothing}},1}:\n  9.125983f-13 erg cm^-3 s^-1\n  9.261124f-13 erg cm^-3 s^-1\n  9.398209f-13 erg cm^-3 s^-1\n  9.537266f-13 erg cm^-3 s^-1\n   9.67832f-13 erg cm^-3 s^-1\n  9.821403f-13 erg cm^-3 s^-1\n  9.966539f-13 erg cm^-3 s^-1\n  1.011376f-12 erg cm^-3 s^-1\n 1.0263094f-12 erg cm^-3 s^-1\n 1.0414569f-12 erg cm^-3 s^-1\n\njulia> grid(6000, 4.5, 2)[1:10]\nERROR: Could not find spectrum with parameters (6000, 4.5, 2, 0)\n[...]\n\njulia> grid.(6000:100:6200, 4.5, 0)\n3-element Array{Array{Float32,1},1}:\n [9.125983e-13, 9.261124e-13, 9.398209e-13, 9.537266e-13, 9.67832e-13, 9.821403e-13, 9.966539e-13, 1.011376e-12, 1.0263094e-12, 1.0414569e-12  …  1.200507e12, 1.2106235e12, 1.2115639e12, 1.211697e12, 1.211749e12, 1.2117668e12, 1.2116947e12, 1.2112217e12, 1.2107722e12, 1.211132e12]          \n [3.4244803e-12, 3.4742658e-12, 3.5247538e-12, 3.5759542e-12, 3.6278769e-12, 3.6805316e-12, 3.733928e-12, 3.788077e-12, 3.842988e-12, 3.898672e-12  …  1.2244243e12, 1.2318009e12, 1.2325055e12, 1.2325888e12, 1.2326135e12, 1.2326139e12, 1.2325272e12, 1.2320685e12, 1.2316515e12, 1.231986e12]  \n [1.1416081e-11, 1.1579233e-11, 1.1744649e-11, 1.19123565e-11, 1.2082389e-11, 1.2254776e-11, 1.2429551e-11, 1.2606744e-11, 1.2786388e-11, 1.2968517e-11  …  1.2485481e12, 1.2531918e12, 1.2535282e12, 1.253531e12, 1.2535174e12, 1.2534951e12, 1.2534e12, 1.2529466e12, 1.2525302e12, 1.2528731e12]\n\n\n\n\n\n\n","category":"type"},{"location":"phoenix/#SpectralLibraries.update!","page":"PHOENIX ACES","title":"SpectralLibraries.update!","text":"update!(::PHOENIX)\nupdate!(::PHOENIX, path::String)\n\nGoes through the given path (or the current path) for the library and recreates the table of models.\n\n\n\n\n\n","category":"function"},{"location":"phoenix/#SpectralLibraries.wave","page":"PHOENIX ACES","title":"SpectralLibraries.wave","text":"wave(::PHOENIX; use_units=false)\n\nReturns the wavelength array for the library. If use_units is true, will return a Unitful.Quantity array with the appropriate units.\n\nExamples\n\njulia> grid = PHOENIX(\"PHOENIX\")\nPHOENIX ACES Stellar Atmosphere Spectral Library (Husser et al. 2013)\npath           = PHOENIX\nparameters     = T, logg, Z, α\nunits          = wave (Å), flux (erg cm^-3 s^-1)\nnum. available = 659\n\njulia> wave(grid)[1:10]\n10-element Array{Float64,1}:\n 500.0\n 500.1\n 500.2\n 500.3\n 500.4\n 500.5\n 500.6\n 500.7\n 500.8\n 500.9\n\njulia> wave(grid, use_units=true)[1:10]\n10-element Array{Unitful.Quantity{Float64,𝐋,Unitful.FreeUnits{(Å,),𝐋,nothing}},1}:\n 500.0 Å\n 500.1 Å\n 500.2 Å\n 500.3 Å\n 500.4 Å\n 500.5 Å\n 500.6 Å\n 500.7 Å\n 500.8 Å\n 500.9 Å\n\n\n\n\n\n\n","category":"function"},{"location":"phoenix/#SpectralLibraries.params","page":"PHOENIX ACES","title":"SpectralLibraries.params","text":"params(::PHOENIX)\n\nReturns a dataframe of the parameters of each model.\n\nExamples\n\njulia> grid = PHOENIX(\"PHOENIX\")\nPHOENIX ACES Stellar Atmosphere Spectral Library (Husser et al. 2013)\npath           = PHOENIX\nparameters     = T, logg, Z, α\nunits          = wave (Å), flux (erg cm^-3 s^-1)\nnum. available = 659\n\njulia> ps = params(grid)[1:10, :]\n10×4 DataFrames.DataFrame\n│ Row │ T     │ logg    │ Z       │ α       │\n│     │ Int64 │ Float64 │ Float64 │ Float64 │\n├─────┼───────┼─────────┼─────────┼─────────┤\n│ 1   │ 5700  │ 3.5     │ 0.5     │ 0.0     │\n│ 2   │ 5700  │ 4.0     │ 0.5     │ 0.0     │\n│ 3   │ 5700  │ 4.5     │ 0.5     │ 0.0     │\n│ 4   │ 5700  │ 5.0     │ 0.5     │ 0.0     │\n│ 5   │ 5700  │ 5.5     │ 0.5     │ 0.0     │\n│ 6   │ 5700  │ 6.0     │ 0.5     │ 0.0     │\n│ 7   │ 5800  │ 3.5     │ 0.5     │ 0.0     │\n│ 8   │ 5800  │ 4.0     │ 0.5     │ 0.0     │\n│ 9   │ 5800  │ 4.5     │ 0.5     │ 0.0     │\n│ 10  │ 5800  │ 5.0     │ 0.5     │ 0.0     │\n\njulia> convert(Matrix, ps)\n10×4 Array{Float64,2}:\n 5700.0  3.5  0.5  0.0\n 5700.0  4.0  0.5  0.0\n 5700.0  4.5  0.5  0.0\n 5700.0  5.0  0.5  0.0\n 5700.0  5.5  0.5  0.0\n 5700.0  6.0  0.5  0.0\n 5800.0  3.5  0.5  0.0\n 5800.0  4.0  0.5  0.0\n 5800.0  4.5  0.5  0.0\n 5800.0  5.0  0.5  0.0\n\n\n\n\n\n\n","category":"function"},{"location":"phoenix/#Base.length","page":"PHOENIX ACES","title":"Base.length","text":"length(::PHOENIX)\n\nReturns the number of models in the library.\n\n\n\n\n\n","category":"function"},{"location":"phoenix/#Base.filter","page":"PHOENIX ACES","title":"Base.filter","text":"filter(function, ::PHOENIX)\n\nReturns a library with parameters filtered by the function.\n\nExamples\n\njulia> grid = PHOENIX(\"PHOENIX\")\nPHOENIX ACES Stellar Atmosphere Spectral Library (Husser et al. 2013)\npath           = PHOENIX\nparameters     = T, logg, Z, α\nunits          = wave (Å), flux (erg cm^-3 s^-1)\nnum. available = 659\n\njulia> query(model) = 6000 < model.T < 7000 &&\n               4.0 < model.logg < 5.0 &&\n               -1.0 < model.Z < 1.0 &&\n               model.α == 0\nquery (generic function with 1 method)\n\njulia> new_grid = filter(query, grid)\nPHOENIX ACES Stellar Atmosphere Spectral Library (Husser et al. 2013)\npath           = PHOENIX\nparameters     = T, logg, Z, α\nunits          = wave (Å), flux (erg cm^-3 s^-1)\nnum. available = 27\n\n\n\n\n\n\n","category":"function"},{"location":"phoenix/#Base.filter!","page":"PHOENIX ACES","title":"Base.filter!","text":"filter!(function, ::PHOENIX)\n\nIn-place version of filter\n\n\n\n\n\n","category":"function"},{"location":"phoenix/#Base.sort","page":"PHOENIX ACES","title":"Base.sort","text":"sort(p::PHOENIX, cols;\n     alg::Union{Algorithm, Nothing}=nothing, lt=isless, by=identity,\n     rev::Bool=false, order::Ordering=Forward)\n\nReturn a copy of the model library sorted by parameter(s) cols. cols can be either a Symbol or Integer column index, or a tuple or vector of such indices.\n\nIf alg is nothing (the default), the most appropriate algorithm is chosen automatically among TimSort, MergeSort and RadixSort depending on the type of the sorting columns and on the number of rows in df. If rev is true, reverse sorting is performed. To enable reverse sorting only for some columns, pass order(c, rev=true) in cols, with c the corresponding column index (see example below). See sort! for a description of other keyword arguments.\n\nExamples\n\njulia> grid = PHOENIX(\"PHOENIX\")\nPHOENIX ACES Stellar Atmosphere Spectral Library (Husser et al. 2013)\npath           = PHOENIX\nparameters     = T, logg, Z, α\nunits          = wave (Å), flux (erg cm^-3 s^-1)\nnum. available = 659\n\njulia> params(grid)[1:10, :]\n10×4 DataFrames.DataFrame\n│ Row │ T     │ logg    │ Z       │ α       │\n│     │ Int64 │ Float64 │ Float64 │ Float64 │\n├─────┼───────┼─────────┼─────────┼─────────┤\n│ 1   │ 5700  │ 3.5     │ 0.5     │ 0.0     │\n│ 2   │ 5700  │ 4.0     │ 0.5     │ 0.0     │\n│ 3   │ 5700  │ 4.5     │ 0.5     │ 0.0     │\n│ 4   │ 5700  │ 5.0     │ 0.5     │ 0.0     │\n│ 5   │ 5700  │ 5.5     │ 0.5     │ 0.0     │\n│ 6   │ 5700  │ 6.0     │ 0.5     │ 0.0     │\n│ 7   │ 5800  │ 3.5     │ 0.5     │ 0.0     │\n│ 8   │ 5800  │ 4.0     │ 0.5     │ 0.0     │\n│ 9   │ 5800  │ 4.5     │ 0.5     │ 0.0     │\n│ 10  │ 5800  │ 5.0     │ 0.5     │ 0.0     │\n\njulia> logg_sorted = sort(p, :logg, rev=true)\nPHOENIX ACES Stellar Atmosphere Spectral Library (Husser et al. 2013)\npath           = /Users/miles/dev/starfish/examples/PHOENIX\nparameters     = T, logg, Z, α\nunits          = wave (Å), flux (erg cm^-3 s^-1)\nnum. available = 659\n\njulia> params(logg_sorted)[1:10, :]\n10×4 DataFrames.DataFrame\n│ Row │ T     │ logg    │ Z       │ α       │\n│     │ Int64 │ Float64 │ Float64 │ Float64 │\n├─────┼───────┼─────────┼─────────┼─────────┤\n│ 1   │ 5700  │ 6.0     │ 0.5     │ 0.0     │\n│ 2   │ 5800  │ 6.0     │ 0.5     │ 0.0     │\n│ 3   │ 5900  │ 6.0     │ 0.5     │ 0.0     │\n│ 4   │ 6000  │ 6.0     │ 0.5     │ 0.0     │\n│ 5   │ 6100  │ 6.0     │ 0.5     │ 0.0     │\n│ 6   │ 6200  │ 6.0     │ 0.5     │ 0.0     │\n│ 7   │ 6300  │ 6.0     │ 0.5     │ 0.0     │\n│ 8   │ 6400  │ 6.0     │ 0.5     │ 0.0     │\n│ 9   │ 6500  │ 6.0     │ 0.5     │ 0.0     │\n│ 10  │ 6600  │ 6.0     │ 0.5     │ 0.0     │\n\n\n\n\n\n\n","category":"function"},{"location":"phoenix/#Base.sort!","page":"PHOENIX ACES","title":"Base.sort!","text":"sort!(p::PHOENIX, cols;\n      alg::Union{Algorithm, Nothing}=nothing, lt=isless, by=identity,\n      rev::Bool=false, order::Ordering=Forward)\n\nIn-place version of sort\n\n\n\n\n\n","category":"function"},{"location":"phoenix/#API/Reference-1","page":"PHOENIX ACES","title":"API/Reference","text":"","category":"section"},{"location":"phoenix/#","page":"PHOENIX ACES","title":"PHOENIX ACES","text":"Pages = [\"phoenix.md\"]","category":"page"},{"location":"#SpectralLibraries.jl-1","page":"Home","title":"SpectralLibraries.jl","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"(Image: Build Status) (Image: codecov)","category":"page"},{"location":"#","page":"Home","title":"Home","text":"This package provides a common interface to synthetic spectral libraries. ","category":"page"},{"location":"#Installation-1","page":"Home","title":"Installation","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"Currently this package is not registered, so to add it","category":"page"},{"location":"#","page":"Home","title":"Home","text":"(v1.2) pkg> add https://github.com/mileslucas/SpectralLibraries.jl\n\njulia> using SpectralLibraries\n","category":"page"},{"location":"#Libraries-1","page":"Home","title":"Libraries","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"The following libraries are currently supported","category":"page"},{"location":"#","page":"Home","title":"Home","text":"PHOENIX ACES HiRes","category":"page"},{"location":"#Citation-1","page":"Home","title":"Citation","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"Please refer to the appropriate references when using one of the model libraries.","category":"page"},{"location":"#Contributing-1","page":"Home","title":"Contributing","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"If you would like to extend this package, feel free to open an issue or a pull request on github","category":"page"}]
}