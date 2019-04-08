export CIF

mutable struct CIF
    volume::Float64
    a::Float64
    b::Float64
    c::Float64
end

mutable struct CIF
    comments::Vector{String}

end

function readcif(filename::String)
    lines = open(readlines, filename)
    for line in lines
        if line[1] == '#' # comment

        end
        items = split(line, " ", keepempty=false)
        if startswith(line, "data_")
            data = line[6:end]
        elseif items[1] == "loop_"

        elseif items[1] == "_cell_length_a"
            x.a = parse(Float64, items[2])
        elseif items[1] == "_cell_length_b"
            x.b = parse(Float64, items[2])
        elseif items[1] == "_cell_length_c"
            x.c = parse(Float64, items[2])
        elseif items[1] == "_cell_angle_alpha"
            x.α = parse(Float64, items[2])
        elseif items[1] == "_cell_angle_beta"
            x.β = parse(Float64, items[2])
        elseif items[1] == "_cell_angle_gamma"
            x.γ = parse(Float64, items[2])
        elseif items[1] == "_cell_volume"
            x.volume = parse(Float64, items[2])
        elseif "# Dielectric constant, electronic:"
        else

        end
    end
end

function parseaaa(lines::Vector{String})
    for i = 1:7
        @assert startswith(lines[i], " _atom_site")
    end
    for i = 8:length(lines)
        line = strip(lines[i])
        isempty(line) && continue
        items = split(line, " ", keepempty=false)
        atom = items[1]
        x = parse(Float64, items[4])
        y = parse(Float64, items[5])
        z = parse(Float64, items[6])
        
    end
end
