using CodecZlib

function main(dir::String)
    data = []
    for file in readdir(dir)
        endswith(file,".xyz") || continue
        x = readdata(joinpath(dir,file))
    end
end

function readdata(filename::String)
    lines = open(readlines, filename)
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

main(".data/dsgdb9nsd.xyz")
