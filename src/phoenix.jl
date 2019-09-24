using DataFrames, FITSIO, Unitful, UnitfulAstro, CSV

export PHOENIX,
       update!,
       wave,
       params,
       ALL_PHOENIX_MODELS,
       download_PHOENIX_model


const PHOENIX_REGEX = r"lte(\d{5})-(\d\.\d{2})([\+|-]\d\.\d)(?:\.Alpha=([\+|-]\d\.\d{2}))?\.PHOENIX-ACES-AGSS-COND-2011-HiRes.fits"
const PHOENIX_WAVEFILE = "WAVE_PHOENIX-ACES-AGSS-COND-2011.fits"
const PHOENIX_PARAMETERS = ("T", "logg", "Z", "α")
const PHOENIX_WAVEUNITS = u"angstrom"
const PHOENIX_FLUXUNITS = u"erg/s/cm^3"

# Base definitions

mutable struct PHOENIX <: AbstractSpectralLibrary 
    path::String
    entries::DataFrame
    wave::AbstractArray
end

"""
    PHOENIX(path)

Stellar Atmosphere Spectra from Husser et al. (2013)

This interfaces the PHOENIX ACES models as computed by Husser et al. (2013). It is parametrized by the following:

| Parameter |     Range     | Description                                     |
|----------:|:-------------:|:------------------------------------------------|
|       `T` | [2300, 12000] | Teff - The effective temperature in Kelvin      |
|    `logg` |   [0.0, 6.0]  | log(g) - The surface gravity in log-solar units |
|       `Z` |  [-4.0, 1.0]  | [Fe/H] - The iron fraction in log-solar units   |
|       `α` |  [-0.2, 1.2]  | [α/M] - The helium concentration fraction       |

The files must be organized the same way they are organized on the Göttinghen servers, as this constructs a table mapping the parameters to each discovered filename.

# References
[[1]](https://ui.adsabs.harvard.edu/abs/2013A%26A...553A...6H) Husser et al. (2013)

# Examples
```julia-repl
julia> grid = PHOENIX("PHOENIX")
PHOENIX ACES Stellar Atmosphere Spectral Library (Husser et al. 2013)
path           = PHOENIX
parameters     = T, logg, Z, α
units          = wave (Å), flux (erg cm^-3 s^-1)
num. available = 659

# Indexing
julia> grid[1]
(T = 5700, logg = 3.5, Z = 0.5, α = 0.0) => Float32[2.3576384e-16, 2.3964725e-16, 2.4359302e-16, 2.4760205e-16, 2.516754e-16, 2.5581404e-16, 2.60019e-16, 2.642913e-16, 2.6863203e-16, 2.7304218e-16  …  1.06697366e12, 1.146122e12, 1.1551366e12, 1.1556633e12, 1.1557706e12, 1.1557903e12, 1.1554768e12, 1.1539062e12, 1.1525517e12, 1.1532526e12]

# We can iterate over the library
julia> [println(model.T) for (model, flux) in grid[[1, 100, 500]]];
5700
7200
7400

# Accessing certain parameters
julia> grid.logg[1:10]
10-element Array{Float64,1}:
 3.5
 4.0
 4.5
 5.0
 5.5
 6.0
 3.5
 4.0
 4.5
 5.0

```
"""
function PHOENIX(path::String)
    entries = load_PHOENIX_table(path)
    wavefile = joinpath(path, PHOENIX_WAVEFILE)
    # Check if wavefile exists gracefully
    !isfile(wavefile) && error("Could not find wavelength file $(PHOENIX_WAVEFILE) in $(path)")
    wavelengths = read(FITS(wavefile)[1])
    return PHOENIX(path, entries, wavelengths)
end

"""
    (::PHOENIX)(T, logg, Z, α=0; use_units=false)

Return the flux density of the model at the given parameters. Raises an error if the model cannot be found. If `use_units` is true, will return the flux density as a `Unitful.Quantity` with the appropriate units.

# Examples
```julia-repl
julia> grid = PHOENIX("PHOENIX")
PHOENIX ACES Stellar Atmosphere Spectral Library (Husser et al. 2013)
path           = PHOENIX
parameters     = T, logg, Z, α
units          = wave (Å), flux (erg cm^-3 s^-1)
num. available = 659

julia> grid(6000, 4.5, 0)[1:10]
10-element Array{Float32,1}:
 9.125983e-13 
 9.261124e-13 
 9.398209e-13 
 9.537266e-13 
 9.67832e-13  
 9.821403e-13 
 9.966539e-13 
 1.011376e-12 
 1.0263094e-12
 1.0414569e-12

julia> grid(6000, 4.5, 0, use_units=true)[1:10]
10-element Array{Unitful.Quantity{Float32,𝐌*𝐋^-1*𝐓^-3,Unitful.FreeUnits{(erg, cm^-3, s^-1),𝐌*𝐋^-1*𝐓^-3,nothing}},1}:
  9.125983f-13 erg cm^-3 s^-1
  9.261124f-13 erg cm^-3 s^-1
  9.398209f-13 erg cm^-3 s^-1
  9.537266f-13 erg cm^-3 s^-1
   9.67832f-13 erg cm^-3 s^-1
  9.821403f-13 erg cm^-3 s^-1
  9.966539f-13 erg cm^-3 s^-1
  1.011376f-12 erg cm^-3 s^-1
 1.0263094f-12 erg cm^-3 s^-1
 1.0414569f-12 erg cm^-3 s^-1

julia> grid(6000, 4.5, 2)[1:10]
ERROR: Could not find spectrum with parameters (6000, 4.5, 2, 0)
[...]

julia> grid.(6000:100:6200, 4.5, 0)
3-element Array{Array{Float32,1},1}:
 [9.125983e-13, 9.261124e-13, 9.398209e-13, 9.537266e-13, 9.67832e-13, 9.821403e-13, 9.966539e-13, 1.011376e-12, 1.0263094e-12, 1.0414569e-12  …  1.200507e12, 1.2106235e12, 1.2115639e12, 1.211697e12, 1.211749e12, 1.2117668e12, 1.2116947e12, 1.2112217e12, 1.2107722e12, 1.211132e12]          
 [3.4244803e-12, 3.4742658e-12, 3.5247538e-12, 3.5759542e-12, 3.6278769e-12, 3.6805316e-12, 3.733928e-12, 3.788077e-12, 3.842988e-12, 3.898672e-12  …  1.2244243e12, 1.2318009e12, 1.2325055e12, 1.2325888e12, 1.2326135e12, 1.2326139e12, 1.2325272e12, 1.2320685e12, 1.2316515e12, 1.231986e12]  
 [1.1416081e-11, 1.1579233e-11, 1.1744649e-11, 1.19123565e-11, 1.2082389e-11, 1.2254776e-11, 1.2429551e-11, 1.2606744e-11, 1.2786388e-11, 1.2968517e-11  …  1.2485481e12, 1.2531918e12, 1.2535282e12, 1.253531e12, 1.2535174e12, 1.2534951e12, 1.2534e12, 1.2529466e12, 1.2525302e12, 1.2528731e12]

```
"""
function (p::PHOENIX)(T, logg, Z, α = 0; use_units = false)
    query(p) = p.T == T && p.logg == logg && p.Z == Z && p.α == α
    filenames = filter(query, p).filename
    length(filenames) == 0 && error("Could not find spectrum with parameters ($T, $logg, $Z, $α)")
    flux = read(FITS(first(filenames))[1])
    return use_units ? flux * PHOENIX_FLUXUNITS : flux
end

# Custom functinos

function load_PHOENIX_table(path::String)
    filenames = DataFrame(T = Int[], logg = Float64[], Z = Float64[], α = Float64[], filename = [])
    # Walk through the root path and search for PHOENIX ACES files
    for (root, dirs, files) in walkdir(path)
        for file in files
            m = match(PHOENIX_REGEX, file)
            # If it looks like a PHOENIX file, parse the parameters from the regex string
            if !isnothing(m)
                T = parse(Int, m.captures[1])
                logg = parse(Float64, m.captures[2])
                Z = parse(Float64, m.captures[3])
                a = isnothing(m.captures[4]) ? 0.0 : parse(Float64, m.captures[4])
                push!(filenames, (T, logg, Z, a, joinpath(root, file)))
            end
        end
    end
    return filenames
end

"""
    update!(::PHOENIX)
    update!(::PHOENIX, path::String)

Goes through the given path (or the current path) for the library and recreates the table of models.
"""
function update!(p::PHOENIX, path::String)
    p.entries = load_PHOENIX_table(path)
    p.path = path
    return p
end

update!(p::PHOENIX) = update!(p, p.path)

"""
    wave(::PHOENIX; use_units=false)

Returns the wavelength array for the library. If `use_units` is true, will return a `Unitful.Quantity` array with the appropriate units.

# Examples
```julia-repl
julia> grid = PHOENIX("PHOENIX")
PHOENIX ACES Stellar Atmosphere Spectral Library (Husser et al. 2013)
path           = PHOENIX
parameters     = T, logg, Z, α
units          = wave (Å), flux (erg cm^-3 s^-1)
num. available = 659

julia> wave(grid)[1:10]
10-element Array{Float64,1}:
 500.0
 500.1
 500.2
 500.3
 500.4
 500.5
 500.6
 500.7
 500.8
 500.9

julia> wave(grid, use_units=true)[1:10]
10-element Array{Unitful.Quantity{Float64,𝐋,Unitful.FreeUnits{(Å,),𝐋,nothing}},1}:
 500.0 Å
 500.1 Å
 500.2 Å
 500.3 Å
 500.4 Å
 500.5 Å
 500.6 Å
 500.7 Å
 500.8 Å
 500.9 Å

```
"""
wave(p::PHOENIX; use_units = false) = use_units ? p.wave * PHOENIX_WAVEUNITS : p.wave

"""
    params(::PHOENIX)

Returns a dataframe of the parameters of each model.

# Examples
```julia-repl
julia> grid = PHOENIX("PHOENIX")
PHOENIX ACES Stellar Atmosphere Spectral Library (Husser et al. 2013)
path           = PHOENIX
parameters     = T, logg, Z, α
units          = wave (Å), flux (erg cm^-3 s^-1)
num. available = 659

julia> ps = params(grid)[1:10, :]
10×4 DataFrames.DataFrame
│ Row │ T     │ logg    │ Z       │ α       │
│     │ Int64 │ Float64 │ Float64 │ Float64 │
├─────┼───────┼─────────┼─────────┼─────────┤
│ 1   │ 5700  │ 3.5     │ 0.5     │ 0.0     │
│ 2   │ 5700  │ 4.0     │ 0.5     │ 0.0     │
│ 3   │ 5700  │ 4.5     │ 0.5     │ 0.0     │
│ 4   │ 5700  │ 5.0     │ 0.5     │ 0.0     │
│ 5   │ 5700  │ 5.5     │ 0.5     │ 0.0     │
│ 6   │ 5700  │ 6.0     │ 0.5     │ 0.0     │
│ 7   │ 5800  │ 3.5     │ 0.5     │ 0.0     │
│ 8   │ 5800  │ 4.0     │ 0.5     │ 0.0     │
│ 9   │ 5800  │ 4.5     │ 0.5     │ 0.0     │
│ 10  │ 5800  │ 5.0     │ 0.5     │ 0.0     │

julia> convert(Matrix, ps)
10×4 Array{Float64,2}:
 5700.0  3.5  0.5  0.0
 5700.0  4.0  0.5  0.0
 5700.0  4.5  0.5  0.0
 5700.0  5.0  0.5  0.0
 5700.0  5.5  0.5  0.0
 5700.0  6.0  0.5  0.0
 5800.0  3.5  0.5  0.0
 5800.0  4.0  0.5  0.0
 5800.0  4.5  0.5  0.0
 5800.0  5.0  0.5  0.0

```
"""
params(p::PHOENIX) = select(p.entries, Not(:filename))

"""
    ALL_PHOENIX_MODELS

`DataFrames.DataFrame` of every single available PHOENIX ACES model.
"""
const ALL_PHOENIX_MODELS = CSV.read(joinpath(@__DIR__, "..", "data", "PHOENIX_MODELS.csv"))

"""
    download_PHOENIX_model(::DataFrame   ; path="PHOENIX")
    download_PHOENIX_model(::DataFrameRow; path="PHOENIX")

Given a row or subframe from the [`ALL_PHOENIX_MODELS`](@ref) dataframe, download into the given path making all directories on the way. Files are downloaded from the Goettingen HTTP server and should not be abused. This will also download the wavelength file if it is not already present.

!!! warning
    Do not abuse the Goettingen HTTP server by spamming this function!

# Examples
```julia-repl
julia> size(ALL_PHOENIX_MODELS, 1)
27605

julia> subset = filter(r -> 6000 ≤ r.T ≤ 6300 && 4.0 ≤ r.logg ≤ 4.5 && r.Z == 0 && r.α == 0, a);

julia> size(subset, 1)
8

julia> download_PHOENIX_model(subset)
[ Info: Downloading wavelength file to PHOENIX/WAVE_PHOENIX-ACES-AGSS-COND-2011.fits
[ Info: Downloading model to PHOENIX/Z-0.0/lte06200-4.00-0.0.PHOENIX-ACES-AGSS-COND-2011-HiRes.fits
[ Info: Downloading model to PHOENIX/Z-0.0/lte06300-4.00-0.0.PHOENIX-ACES-AGSS-COND-2011-HiRes.fits
[ Info: Downloading model to PHOENIX/Z-0.0/lte06100-4.00-0.0.PHOENIX-ACES-AGSS-COND-2011-HiRes.fits
[ Info: Downloading model to PHOENIX/Z-0.0/lte06000-4.00-0.0.PHOENIX-ACES-AGSS-COND-2011-HiRes.fits
[ Info: Downloading model to PHOENIX/Z-0.0/lte06200-4.50-0.0.PHOENIX-ACES-AGSS-COND-2011-HiRes.fits
[ Info: Downloading model to PHOENIX/Z-0.0/lte06300-4.50-0.0.PHOENIX-ACES-AGSS-COND-2011-HiRes.fits
[ Info: Downloading model to PHOENIX/Z-0.0/lte06100-4.50-0.0.PHOENIX-ACES-AGSS-COND-2011-HiRes.fits
[ Info: Downloading model to PHOENIX/Z-0.0/lte06000-4.50-0.0.PHOENIX-ACES-AGSS-COND-2011-HiRes.fits

```
"""
function download_PHOENIX_model(model::DataFrameRow; path = "PHOENIX")
    # Set up folders
    folder = joinpath(path, model.folder)
    !isdir(folder) && mkpath(folder)

    # Download wavelength file
    if !isfile(joinpath(path, PHOENIX_WAVEFILE))
        front = "http://phoenix.astro.physik.uni-goettingen.de/data/HiResFITS"
        url = join([front, PHOENIX_WAVEFILE], "/")
        filename = joinpath(path, PHOENIX_WAVEFILE)
        @info "Downloading wavelength file to $filename"
        download(url, filename)
    end

    # Download model
    front = "http://phoenix.astro.physik.uni-goettingen.de/data/HiResFITS/PHOENIX-ACES-AGSS-COND-2011"
    url = join([front, model.folder, model.filename], "/")
    filename = joinpath(folder, model.filename)
    if !isfile(filename)
        @info "Downloading model to $filename"
        download(url, filename)
    end
end

download_PHOENIX_model(models::DataFrame; path = "PHOENIX") = download_PHOENIX_model.(eachrow(models), path = path)

# Extended functions

function Base.show(io::IO, s::PHOENIX)
    println(io, "PHOENIX ACES Stellar Atmosphere Spectral Library (Husser et al. 2013)")
println(io, "path           = $(s.path)")
    pstring = join(PHOENIX_PARAMETERS, ", ")
    println(io, "parameters     = $pstring")
    println(io, "units          = wave ($PHOENIX_WAVEUNITS), flux ($PHOENIX_FLUXUNITS)")
    println(io, "num. available = $(length(s))")
end

"""
    length(::PHOENIX)

Returns the number of models in the library.
"""
Base.length(p::PHOENIX) = size(p.entries, 1)

function Base.iterate(p::PHOENIX, row::Int)
    row > length(p) && return nothing
    return p[row], row + 1
end

Base.iterate(p::PHOENIX) = iterate(p, 1)

function Base.getproperty(p::PHOENIX, name::Symbol)
    if name in propertynames(p)
        return getfield(p, name)
    elseif name in propertynames(p.entries)
        return getproperty(p.entries, name)
    end
end

function Base.getindex(p::PHOENIX, idx::Int)
    entry = p.entries[idx, :]
    params = copy(entry[Not(:filename)])
    filename = entry[:filename]
    flux = read(FITS(filename)[1])
    return params => flux
end

function Base.getindex(p::PHOENIX, idxs)
    return getindex.(Ref(p), idxs)
end

"""
    filter!(function, ::PHOENIX)

In-place version of [`filter`](@ref)
"""
function Base.filter!(fn, p::PHOENIX)
    p.entries = filter(fn, p.entries)
    return p
end

"""
    filter(function, ::PHOENIX)

Returns a library with parameters filtered by the function.

# Examples
```julia-repl
julia> grid = PHOENIX("PHOENIX")
PHOENIX ACES Stellar Atmosphere Spectral Library (Husser et al. 2013)
path           = PHOENIX
parameters     = T, logg, Z, α
units          = wave (Å), flux (erg cm^-3 s^-1)
num. available = 659

julia> query(model) = 6000 < model.T < 7000 &&
               4.0 < model.logg < 5.0 &&
               -1.0 < model.Z < 1.0 &&
               model.α == 0
query (generic function with 1 method)

julia> new_grid = filter(query, grid)
PHOENIX ACES Stellar Atmosphere Spectral Library (Husser et al. 2013)
path           = PHOENIX
parameters     = T, logg, Z, α
units          = wave (Å), flux (erg cm^-3 s^-1)
num. available = 27

```
"""
function Base.filter(fn, p::PHOENIX)
    return filter!(fn, deepcopy(p))
end

"""
    sort!(p::PHOENIX, cols;
          alg::Union{Algorithm, Nothing}=nothing, lt=isless, by=identity,
          rev::Bool=false, order::Ordering=Forward)

In-place version of [`sort`](@ref)
"""
function Base.sort!(p::PHOENIX, cols;
    alg::Union{DataFrames.Algorithm,Nothing} = nothing, lt = isless, by = identity,
    rev::Bool = false, order::DataFrames.Ordering = DataFrames.Forward)
    p.entries = sort!(p.entries, cols, alg = alg, lt = lt, by = by, rev = rev, order = order)
    return p
end

"""
    sort(p::PHOENIX, cols;
         alg::Union{Algorithm, Nothing}=nothing, lt=isless, by=identity,
         rev::Bool=false, order::Ordering=Forward)

Return a copy of the model library sorted by parameter(s) cols. cols can be either a Symbol or Integer column index, or a tuple or vector of such indices.

If alg is nothing (the default), the most appropriate algorithm is chosen automatically among TimSort, MergeSort and RadixSort depending on the type of the sorting columns and on the number of rows in df. If rev is true, reverse sorting is performed. To enable reverse sorting only for some columns, pass order(c, rev=true) in cols, with c the corresponding column index (see example below). See sort! for a description of other keyword arguments.

# Examples
```julia-repl
julia> grid = PHOENIX("PHOENIX")
PHOENIX ACES Stellar Atmosphere Spectral Library (Husser et al. 2013)
path           = PHOENIX
parameters     = T, logg, Z, α
units          = wave (Å), flux (erg cm^-3 s^-1)
num. available = 659

julia> params(grid)[1:10, :]
10×4 DataFrames.DataFrame
│ Row │ T     │ logg    │ Z       │ α       │
│     │ Int64 │ Float64 │ Float64 │ Float64 │
├─────┼───────┼─────────┼─────────┼─────────┤
│ 1   │ 5700  │ 3.5     │ 0.5     │ 0.0     │
│ 2   │ 5700  │ 4.0     │ 0.5     │ 0.0     │
│ 3   │ 5700  │ 4.5     │ 0.5     │ 0.0     │
│ 4   │ 5700  │ 5.0     │ 0.5     │ 0.0     │
│ 5   │ 5700  │ 5.5     │ 0.5     │ 0.0     │
│ 6   │ 5700  │ 6.0     │ 0.5     │ 0.0     │
│ 7   │ 5800  │ 3.5     │ 0.5     │ 0.0     │
│ 8   │ 5800  │ 4.0     │ 0.5     │ 0.0     │
│ 9   │ 5800  │ 4.5     │ 0.5     │ 0.0     │
│ 10  │ 5800  │ 5.0     │ 0.5     │ 0.0     │

julia> logg_sorted = sort(p, :logg, rev=true)
PHOENIX ACES Stellar Atmosphere Spectral Library (Husser et al. 2013)
path           = /Users/miles/dev/starfish/examples/PHOENIX
parameters     = T, logg, Z, α
units          = wave (Å), flux (erg cm^-3 s^-1)
num. available = 659

julia> params(logg_sorted)[1:10, :]
10×4 DataFrames.DataFrame
│ Row │ T     │ logg    │ Z       │ α       │
│     │ Int64 │ Float64 │ Float64 │ Float64 │
├─────┼───────┼─────────┼─────────┼─────────┤
│ 1   │ 5700  │ 6.0     │ 0.5     │ 0.0     │
│ 2   │ 5800  │ 6.0     │ 0.5     │ 0.0     │
│ 3   │ 5900  │ 6.0     │ 0.5     │ 0.0     │
│ 4   │ 6000  │ 6.0     │ 0.5     │ 0.0     │
│ 5   │ 6100  │ 6.0     │ 0.5     │ 0.0     │
│ 6   │ 6200  │ 6.0     │ 0.5     │ 0.0     │
│ 7   │ 6300  │ 6.0     │ 0.5     │ 0.0     │
│ 8   │ 6400  │ 6.0     │ 0.5     │ 0.0     │
│ 9   │ 6500  │ 6.0     │ 0.5     │ 0.0     │
│ 10  │ 6600  │ 6.0     │ 0.5     │ 0.0     │

```
"""
function Base.sort(p::PHOENIX, cols;
    alg::Union{DataFrames.Algorithm,Nothing} = nothing, lt = isless, by = identity,
    rev::Bool = false, order::DataFrames.Ordering = DataFrames.Forward)
    return sort!(deepcopy(p), cols, alg = alg, lt = lt, by = by, rev = rev, order = order)
end
