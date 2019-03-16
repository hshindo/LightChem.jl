export Atom, Bond, Molecule
export natoms, nbonds

struct Atom
    symbol::String
    x::Float64
    y::Float64
    z::Float64
end

struct Bond
    i::Int
    j::Int
    type::Int
    stereo::Int
end

struct Molecule
    atoms::Vector{Atom}
    bonds::Vector{Bond}
end

natoms(m::Molecule) = length(m.atoms)
nbonds(m::Molecule) = length(m.bonds)

function mols2h5(filename::String, mols::Vector{Molecule})
    atom1 = String[]
    atom2 = Float64[]
    for m in mols
        for atom in m.atoms
            push!(atom1, atom.symbol)
        end
    end
end
