export readsdf

function readxyz(filename::String)
    freqs = map(x -> parse(Float32,x), split(lines[end-2],"\t"))
    smiles = lines[end-1]
    inchi = lines[end]
end

function readsdf(filename::String)
    lines = open(readlines, filename)
    buffer = String[]
    mols = Molecule[]
    for line in lines
        push!(buffer, line)
        if line == raw"$$$$"
            mol = parsemol(buffer)
            push!(mols, mol)
            empty!(buffer)
        end
    end
    mols
end

function parsemol(lines::Vector{String})
    line = lines[4]
    natoms = parse(Int, line[1:3])
    nbonds = parse(Int, line[4:6])

    atoms = Atom[]
    for i = 5:5+natoms-1
        line = lines[i]
        x = parse(Float64, line[1:10])
        y = parse(Float64, line[11:20])
        z = parse(Float64, line[21:30])
        symbol = strip(line[32:34])
        push!(atoms, Atom(symbol,x,y,z))
    end

    bonds = Bond[]
    k = 5 + natoms
    for i = k:k+nbonds-1
        line = lines[i]
        id1 = parse(Int, line[1:3])
        id2 = parse(Int, line[4:6])
        type = parse(Int, line[7:9])
        stereo = parse(Int, line[10:12])
        push!(bonds, Bond(id1,id2,type,stereo))
    end
    Molecule(atoms, bonds)
end
