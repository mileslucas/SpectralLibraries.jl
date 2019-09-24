using DataFrames, FITSIO, Unitful, UnitfulAstro

export PHOENIX,
       update!,
       wave,
       params


const PHOENIX_REGEX = r"lte(\d{5})-(\d\.\d{2})([\+|-]\d\.\d)(?:\.Alpha=([\+|-]\d\.\d{2}))?\.PHOENIX-ACES-AGSS-COND-2011-HiRes.fits"
const PHOENIX_WAVEFILE = "WAVE_PHOENIX-ACES-AGSS-COND-2011.fits"
const PHOENIX_PARAMETERS = ("T", "logg", "Z", "α")
const PHOENIX_WAVEUNITS = u"angstrom"
const PHOENIX_FLUXUNITS = u"erg/s/cm^3"

mutable struct PHOENIX <: AbstractSpectralLibrary 
    path::String
    entries::DataFrame
    wave::AbstractArray
    use_units::Bool
end

function Base.show(io::IO, s::PHOENIX)
    println(io, "PHOENIX ACES Stellar Atmosphere Spectral Library (Husser et al. 2011)")
    println(io, "path           = $(s.path)")
    pstring = join(PHOENIX_PARAMETERS, ", ")
    println(io, "parameters     = $pstring")
    println(io, "units          = (wave) $PHOENIX_WAVEUNITS, (flux) $PHOENIX_FLUXUNITS")
    println(io, "num. available = $(size(s.entries, 1))")
end

function Base.getproperty(p::PHOENIX, name::Symbol)
    if name in propertynames(p)
        return getfield(p, name)
    elseif name in propertynames(p.entries)
        return getproperty(p.entries, name)
    end
end

function load_PHOENIX_table(path)
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

function PHOENIX(path::String; use_units=false)
    entries = load_PHOENIX_table(path)
    wavefile = joinpath(path, PHOENIX_WAVEFILE)
    # Check if wavefile exists gracefully
    !isfile(wavefile) && error("Could not find wavelength file $(PHOENIX_WAVEFILE) in $(path)")
    wavelengths = read(FITS(wavefile)[1])
    return PHOENIX(path, entries, wavelengths, use_units)
end

function update!(p::PHOENIX, path)
    p.entries = load_PHOENIX_table(path)
    p.path = path
    return p
end

update!(p::PHOENIX) = update!(p, p.path)


function Base.filter!(fn, p::PHOENIX)
    p.entries = filter(fn, p.entries)
    return p
end

function Base.filter(fn, p::PHOENIX)
    newp = deepcopy(p)
    return filter!(fn, newp)
end

function (p::PHOENIX)(T, logg, Z, α=0)
    query(p) = p.T == T && p.logg == logg && p.Z == Z && p.α == α
    filenames = filter(query, p).filename
    length(filenames) == 0 && error("Could not find spectrum with parameters ($T, $logg, $Z, $α)")
    flux = read(FITS(first(filenames))[1])
    return p.use_units ? flux * PHOENIX_FLUXUNITS : flux
end

wave(p::PHOENIX) = p.use_units ? p.wave * PHOENIX_WAVEUNITS : p.wave

function params(p::PHOENIX)
    params = select(p.entries, Not(:filename))
    return convert(Matrix, params)
end
