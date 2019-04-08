export MAE

function mean_abs_error(data::Vector)
    data = collect(Iterators.flatten(map(x -> vec(abs.(x[1]-x[2])), data)))
    score = sum(data) / length(data)
    println("MAE:")
    display(score)
    println()
end
