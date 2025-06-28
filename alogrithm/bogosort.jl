function bogosort!(data::AbstractVector)
    counter = 1
    println("sort $counter:\t$data")
    while !issorted(data)
        shuffle!(data)
        counter += 1
        println("sort $counter:\t$data")
    end
    return data 
end 