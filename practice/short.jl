n = 100_000_000

a = 2.718

using Random

Random.seed!(1)

x = rand(n)

y = rand(n)

function axpy(a, x, y)
    z = []
    for i ∈ 1:length(x)
        temp = a * x[i] + y[i]
        push!(z, temp)
    end
    return z
end
@time z = axpy(a, x, y)

@code_warntype axpy(a, x, y)

function f(x)
    y = string(x + 3.14)
    return y
end
f(3)
@code_warntype f(3)