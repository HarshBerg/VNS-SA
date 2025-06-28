function fib(x)
    f1, f2 = (0, 1)
    println("\nF_0 = 0")
    
    for i in 1:x
        f1, f2 = (f2, f1 + f2)
        println("F_$i = $f1")
    end

    println("\nF sub $x is $f1\n")
    return f1
end

function fib2(x)
    if x < 2
        println("B_$x = $x")
        return x
    else
        println("F_$x = F_$(x-1) + F_$(x-2)")
        fib2(x - 1) + fib2(x - 2)
    end
end