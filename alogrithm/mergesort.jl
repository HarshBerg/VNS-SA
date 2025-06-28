function mergesort!(data::AbstractVector)
    println("split:\t", data)
    merged = copy(data)

    index = right_index = left_index = 1

    middle = length(data) ÷ 2
    print(middle)
    left = mergesort!(data[1:middle])
    right = mergesort!(data[(middle + 1):end])

    if left_index == 1
        merged[index:end] = left[left_index:end]
    else
        merged[index:end] = right[right_index:end]
    end
#=
    while left_index <= length(left) && right_index <= length(right)
        if left[left_index] <= right[right_index]
            merged[index] = left[left_index]
            left_index += 1
        else
            merged[index] = right[right_index]
            right_index += 1
        end
        index += 1 
    end
=#
    println("merge:\t", merged)
    return merged
end

v = [9, 1]
mergesort!(copy(v))
#@code_warntype mergesort!(copy(v))