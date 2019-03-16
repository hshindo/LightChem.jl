using Random

mutable struct Model
    config
    nn
end

function Model(config::Dict)
    T = Float32
    atomembeds = Uniform(-0.01,0.01)(T, 30, 5)
    dataset = readxyz(config["train_file"])
    n = length(dataset)
    r = randperm(n)
    m = trunc(Int, n*0.1)
    devdata = dataset[r[1:m]]
    testdata = dataset[r[m+1:2m]]
    traindata = dataset[r[2m+1:end]]
    nn = NN(atomembeds)

    @info "# Train:\t$(length(traindata))"
    @info "# Dev:\t$(length(devdata))"
    @info "# Test:\t$(length(testdata))"
    m = Model(config, nn)
    train!(m, traindata, devdata, testdata)
    m
end

function train!(model::Model, traindata, devdata, testdata)
    config = model.config
    Merlin.setdevice(config["device"])
    opt = SGD()
    nn = todevice(model.nn)
    batchsize = config["batchsize"]
    maxdev, maxtest = (), ()

    for epoch = 1:config["nepochs"]
        println("Epoch:\t$epoch")
        opt.rate = config["learning_rate"] / (1 + 0.05*(epoch-1))

        loss = minimize!(nn, traindata, opt, batchsize=batchsize, shuffle=true)
        loss /= length(traindata)
        println("Loss:\t$loss")

        #=
        println("-----Test data-----")
        res = evaluate(nn, testdata, batchsize=100)
        testscore = fscore_sent(res)
        println("-----Dev data-----")
        res = evaluate(nn, devdata, batchsize=100)
        devscore = fscore_sent(res)
        if isempty(maxdev) || devscore.f > maxdev.f
            maxdev = devscore
            maxtest = testscore
        end
        println("-----Final test-----")
        println(maxdev)
        println(maxtest)
        =#
        println()
    end
end

function fscore(golds::Vector{T}, preds::Vector{T}) where T
    set = intersect(Set(golds), Set(preds))
    count = length(set)
    prec = round(count/length(preds), digits=5)
    recall = round(count/length(golds), digits=5)
    fval = round(2*recall*prec/(recall+prec), digits=5)
    println("Prec:\t$prec")
    println("Recall:\t$recall")
    println("Fscore:\t$fval")
end

function bioes_decode(ids::Vector{Int}, tagdict::Dict{String,Int})
    id2tag = Array{String}(undef, length(tagdict))
    for (k,v) in tagdict
        id2tag[v] = k
    end

    spans = Tuple{Int,Int,String}[]
    bpos = 0
    for i = 1:length(ids)
        tag = id2tag[ids[i]]
        tag == "O" && continue
        startswith(tag,"B") && (bpos = i)
        startswith(tag,"S") && (bpos = i)
        nexttag = i == length(ids) ? "O" : id2tag[ids[i+1]]
        if (startswith(tag,"S") || startswith(tag,"E")) && bpos > 0
            tag = id2tag[ids[bpos]]
            basetag = length(tag) > 2 ? tag[3:end] : ""
            push!(spans, (bpos,i,basetag))
            bpos = 0
        end
    end
    spans
end
