function mult(x, y)

    result = 0

    for i in 1:y
        result += x
        println("$i\t$x * $i\t= $result")
    end

    println("\n$x * $y = $result\n")
    return result
end

function mult2(x, y)
    if y==1
        println("mult2($x, $y)\t = $x\n")
        return x
    else 
        println("mult2($x, $y)\t = $x + mult2($x, $(y-1))")
        return x + mult2(x, y - 1)
    end
end