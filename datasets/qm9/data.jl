mutable struct QM9
    data::Vector
end

Base.length(qm9::QM9) = length(qm9.data)

function Base.getindex(qm9::QM9, indexes::Vector{Int})
    data = qm9.data[indexes]
    as = map(x -> x.a, data)
    dims_a = length.(as)
    a = cat(as..., dims=1)
    a = reshape(a, 1, length(a)) |> todevice

    xs = map(x -> x.x, data)
    x = cat(xs..., dims=2) |> todevice

    ys = map(x -> x.y, data)
    y = cat(ys..., dims=2) |> todevice

    (a=Var(a), x=Var(x), y=Var(y))
end

function readxyz(filename::String)
    lines = open(readlines, filename)
    buffer = String[]
    data = []
    for line in lines
        push!(buffer, line)
        if isempty(line)
            push!(data, parsexyz(buffer))
            empty!(buffer)
        end
    end
    data
end

function parsexyz(lines::Vector{String})
    atom2id = Dict("H"=>1, "C"=>2, "N"=>3, "O"=>4, "F"=>5)
    natoms = parse(Int, lines[1])
    props = split(lines[2], "\t", keepempty=false)
    y = [parse(Float64,props[i]) for i=3:length(props)]
    x = Float64[]
    a = Int[]
    for i = 3:3+natoms-1
        items = Vector{String}(split(lines[i],"\t",keepempty=false))
        atom = atom2id[items[1]]
        push!(a, atom)
        for k = 2:length(items)
            if occursin("*^", items[k])
                p = split(items[k], "*^")
                v = parse(Float64,p[1]) ^ parse(Int,p[2])
            else
                v = parse(Float64,items[k])
            end
            push!(x, v)
        end
    end
    x = reshape(x, 4, length(x)÷4)
    (a=a, x=x, y=y)
end

function readxyzs(dir::String)
    lines = String[]
    for file in readdir(dir)
        path = "$dir/$file"
        println(file)
        @assert endswith(path, ".xyz")
        append!(lines, open(readlines,path))
        push!(lines, "")
    end
    open("qm9.xyz","w") do io
        for line in lines
            println(io, line)
        end
    end
end
