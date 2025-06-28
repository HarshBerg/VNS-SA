n = 100_000_000

a = 2.718

using Random

Random.seed!(1)

x = rand(n)

y = rand(n)

z = []

@time for i in 1:name
    temp = a * x[i] + y[i]
    push!(z, temp)
end
