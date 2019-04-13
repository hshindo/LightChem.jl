export mean_abs_error

function mean_abs_error(ys::Vector, zs::Vector, transformer=nothing)
    data = collect(Iterators.flatten(map(x -> vec(abs.(x[1]-x[2])), data)))
    score = sum(data) / length(data)
end

function mean_squared_error()
end

function mae(data::Vector, trans)
    data1 = collect(Iterators.flatten(map(x -> vec(x[1]), data)))
    data1 = reshape(data1, 1, length(data1))
    data1 = trans(data1)
    data2 = collect(Iterators.flatten(map(x -> vec(x[2]), data)))
    data2 = reshape(data2, 1, length(data2))
    data2 = trans(data2)
    data = abs.(data1 - data2)

    # data = collect(Iterators.flatten(map(x -> vec(abs.(x[1]-x[2])), data)))
    score = sum(data) / length(data)
    println("MAE:")
    display(score)
    println()
end
