const n::Int32 = 100_000_000

const a::Float32 = 2.718

using Random

Random.seed!(1)

x = rand(Float32, n)    
y = rand(Float32, n)

@time z = a .* x .+ y
