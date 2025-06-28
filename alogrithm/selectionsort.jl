
function selectionsort!(data::AbstractVector)
    println("Initial:\t", data)
    len = length(data)
    for i in 1:(len-1)
        localmin, index = findmin(data[(i + 1):end])
        if localmin < data[i]
            data[i], data[index + i] = localmin, data[i]
        end
        println("sort $i:\t", data)
    end
    return data
end

v = [9, 1]
selectionsort!(v)


