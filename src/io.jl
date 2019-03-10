export readsdf

function readsdf(filename::String)
    lines = open(readlines, filename)
    for line in lines

    end


    lines = filter(!isempty, lines)
    natoms = parse(Int, lines[1])
    split(lines[2], "\t")
    for i = 3:length(lines)-3
        items = split(lines[i], "\t")
        atom = items[1]
        x = parse(Float32, items[2])
        y = parse(Float32, items[3])
        z = parse(Float32, items[4])
        e = parse(Float32, items[5])
    end
    freqs = map(x -> parse(Float32,x), split(lines[end-2],"\t"))
    smiles = lines[end-1]
    inchi = lines[end]
    Molecule(natoms, [], smiles, inchi)
end

function parsemol(lines::Vector{String})
    items = split(lines[4], ' ', keepempty=false)
    natoms = parse(Int, items[1])
    nbonds = parse(Int, items[2])
    # Atom block
    for i = 5:5+natoms-1
        items = split(lines[i], ' ', keepempty=false)
        x = parse(Float64, items[1])
        y = parse(Float64, items[2])
        z = parse(Float64, items[3])
        atom = items[4]
    end
    # Bond block
    k = 5+ntoms
    for i = k:k+nbonds-1
        items = split(lines[i], ' ', keepempty=false)
        id1 = parse(Int, items[1])
        id2 = parse(Int, items[2])
        bondtype = parse(Int, items[3])
        
    end
end
