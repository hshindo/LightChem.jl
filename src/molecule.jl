export Atom, Bond, Molecule
export complete, removeHs, natoms, nbonds
export readsdf, writesdf
using Printf

struct Atom
    symbol::String
    x::Float64
    y::Float64
    z::Float64
end

Atom(symbol) = Atom(symbol, 0.0, 0.0, 0.0)

struct Bond
    i::Int
    j::Int
    type::Int
    stereo::Int
end

Bond(i, j) = Bond(i, j, 0, 0)

struct Molecule
    name::String
    atoms::Vector{Atom}
    bonds::Vector{Bond}
    props::Dict
end

Molecule(name::String, atoms, bonds) = Molecule(name, atoms, bonds, Dict())
# Molecule(atoms) = Molecule(atoms, Bond[])

Base.getindex(mol::Molecule, key) = mol.props[key]
Base.setindex!(mol::Molecule, value, key) = mol.props[key] = value

natoms(m::Molecule) = length(m.atoms)
nbonds(m::Molecule) = length(m.bonds)

function complete(mol::Molecule)
    dict = Dict((b.i,b.j) => b for b in mol.bonds)
    bonds = [mol.bonds...]
    for i = 1:natoms(mol)
        for j = i+1:natoms(mol)
            if !haskey(dict, (i,j))
                push!(bonds, Bond(i,j))
            end
        end
    end
    Molecule(mil.name, mol.atoms, bonds)
end

function removeHs(mol::Molecule)
    dict = Dict()
    atoms = Atom[]
    for i = 1:natoms(mol)
        a = mol.atoms[i]
        a.symbol == "H" && continue
        dict[i] = length(dict) + 1
        push!(atoms, a)
    end
    bonds = Bond[]
    for b in mol.bonds
        haskey(dict,b.i) || continue
        i = dict[b.i]
        haskey(dict,b.j) || continue
        j = dict[b.j]
        push!(bonds, Bond(i,j,b.type,b.stereo))
    end
    @assert !isempty(atoms)
    Molecule(atoms, bonds)
end

function secondorder(mol::Molecule)
    neighbors = [Int[] for _=1:natoms(mol)]
    for b in mol.bonds
        @assert b.i != b.j
        push!(neighbors[b.i], b.j)
        push!(neighbors[b.j], b.i)
    end
    bonds = Bond[]
    for i = 1:natoms(mol)
        ns = neighbors[i]
        set = Set(ns)
        for j in ns
            push!(set, neighbors[j]...)
            for k in neighbors[j]
                push!(set, neighbors[k]...)
                #for l in neighbors[k]
                #    push!(set, neighbors[l]...)
                #    for m in neighbors[l]
                #        push!(set, neighbors[m]...)
                #    end
                #end
            end
        end
        ks = filter(k -> i < k, collect(set))
        for k in ks
            push!(bonds, Bond(i,k,0,0))
        end
    end
    Molecule(mol.atoms, bonds)
end

function readsdf(filename::String)
    lines = open(readlines, filename)
    buffer = String[]
    mols = Molecule[]
    for line in lines
        if line == raw"$$$$"
            mol = parsemol(buffer)
            push!(mols, mol)
            buffer = String[]
        else
            push!(buffer, line)
        end
    end
    mols
end

function writesdf(filename::String, mols::Vector{Molecule})
    open(filename, "w") do io
        for m in mols
            println(io, m.name)
            println(io, "LightChem")
            println(io, "")
            @printf(io, "%03s%03s%03s\n", natoms(m), nbonds(m), 0)
            for a in m.atoms
                @printf(io, "%10s%10s%10s %-03s\n", a.x, a.y, a.z, a.symbol)
            end
            for b in m.bonds
                @printf(io, "%03s%03s%03s%03s%03s%03s%03s%03s\n", b.i, b.j, b.type, b.stereo, 0, 0, 0, 0)
            end
            println(io, "M  END")
            for (k,v) in m.props
                println(io, "> <$k>")
                println(io, v)
                println(io, "")
            end
        end
    end
end

function parsemol(lines::Vector{String})
    name = lines[1]
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
    props = Dict{String,Any}()
    k = findnext(x -> x == "M  END", lines, k+nbonds) + 1
    for i = k:length(lines)
        line = lines[i]
        @assert line[1] == '<'
        s = findnext("<", line, 3)
        e = findnext(">", line, s+1)
        key = line[s+1:e-1]
        val = lines[i+1]
        props[key] = val
    end
    Molecule(name, atoms, bonds, props)
end

function mols2h5(filename::String, mols::Vector{Molecule})
    atom1 = String[]
    atom2 = Float64[]
    for m in mols
        for atom in m.atoms
            push!(atom1, atom.symbol)
        end
    end
end
