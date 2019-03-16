using Merlin

mutable struct NN <: Functor
    atomembeds::Var
    l_h
    l_out
end

function NN(atomembeds::Matrix{T}, outsize::Int) where T
    atomembeds = parameter(atomembeds)
    hsize = 100
    l_h = Linear(T, size(atomembeds,1), hsize)
    l_out = Linear(T, hsize, outsize)
    NN(atomembeds, l_h, l_out)
end

function (nn::NN)(x::NamedTuple)
    a = nn.wordembeds(x.a)
    x = x.x
    h = concat(1, a, x)
    h = nn.l_h(h)
    h = relu(h)
    h = average(h, x.dims_a)
    h = nn.l_out(h)
    if Merlin.istraining()
        loss = softmax_crossentropy(x.t, o)
    else
    end
end
