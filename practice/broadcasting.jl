n = 100000000

a = 2.718
using Random
Random.seed!(1)
x = rand(n)
y = rand(n)

@which a * x
@which x + y

@time z = a .* x .+ y
