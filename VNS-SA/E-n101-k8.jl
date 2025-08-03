using Random
using StatsBase
using BenchmarkTools
using Plots
using Profile
Random.seed!(1234) # Set a random seed for reproducibility

function vns_sa(s₀, ls, N, X, Tₒ, r, n, t, f)
    # s₀: initial solution
    # ls: local search function
    # N: number of iterations
    # X: neighborhood size
    # T: initial temperature
    # r: cooling rate
    # n: number of iterations for local search
    # t: time limit for the algorithm
    # f: objective function

    s = s₀
    s_b = s
    S_c = [deepcopy(s₀)]
    S_b = [deepcopy(s_b)]

    T = Tₒ
    i = 1
    k = length(N)
    e = Inf

    converged = false
    while !converged 
        j = 1
        while j <= k
            N_j = N[j]
            s_n = N_j(s)
            s_n = ls(s_n, N_j, X)

            if f(s_n) < f(s)
                s = deepcopy(s_n)
                j = 1
            else 
                l = rand()
                if l < exp(-(f(s_n) - f(s)) / T)
                    s = deepcopy(s_n)
                end
                j += 1
            end

            if f(s) < f(s_b)
                e = f(s_b) - f(s)
                s_b = deepcopy(s)
            end
        end

        push!(S_c, deepcopy(s))
        push!(S_b, deepcopy(s_b))

        T *= r
        i += 1
        if i >= n || e <= t 
            converged = true
        end
    end
    return S_c, S_b
end                
const D = [(0, 35, 35, 0)]
const C = [
    (1, 41, 49, 10),
(2, 35, 17, 7),
(3, 55, 45, 13),
(4, 55, 20, 19),
(5, 15, 30, 26),
(6, 25, 30, 3),
(7, 20, 50, 5),
(8, 10, 43, 9),
(9, 55, 60, 16),
(10, 30, 60, 16),
(11, 20, 65, 12),
(12, 50, 35, 19),
(13, 30, 25, 23),
(14, 15, 10, 20),
(15, 30, 5, 8),
(16, 10, 20, 19),
(17, 5, 30, 2),
(18, 20, 40, 12),
(19, 15, 60, 17),
(20, 45, 65, 9),
(21, 45, 20, 11),
(22, 45, 10, 18),
(23, 55, 5, 29),
(24, 65, 35, 3),
(25, 65, 20, 6),
(26, 45, 30, 17),
(27, 35, 40, 16),
(28, 41, 37, 16),
(29, 64, 42, 9),
(30, 40, 60, 21),
(31, 31, 52, 27),
(32, 35, 69, 23),
(33, 53, 52, 11),
(34, 65, 55, 14),
(35, 63, 65, 8),
(36, 2, 60, 5),
(37, 20, 20, 8),
(38, 5, 5, 16),
(39, 60, 12, 31),
(40, 40, 25, 9),
(41, 42, 7, 5),
(42, 24, 12, 5),
(43, 23, 3, 7),
(44, 11, 14, 18),
(45, 6, 38, 16),
(46, 2, 48, 1),
(47, 8, 56, 27),
(48, 13, 52, 36),
(49, 6, 68, 30),
(50, 47, 47, 13),
(51, 49, 58, 10),
(52, 27, 43, 9),
(53, 37, 31, 14),
(54, 57, 29, 18),
(55, 63, 23, 2),
(56, 53, 12, 6),
(57, 32, 12, 7),
(58, 36, 26, 18),
(59, 21, 24, 28),
(60, 17, 34, 3),
(61, 12, 24, 13),
(62, 24, 58, 19),
(63, 27, 69, 10),
(64, 15, 77, 9),
(65, 62, 77, 20),
(66, 49, 73, 25),
(67, 67, 5, 25),
(68, 56, 39, 36),
(69, 37, 47, 6),
(70, 37, 56, 5),
(71, 57, 68, 15),
(72, 47, 16, 25),
(73, 44, 17, 9),
(74, 46, 13, 8),
(75, 49, 11, 18),
(76, 49, 42, 13),
(77, 53, 43, 14),
(78, 61, 52, 3),
(79, 57, 48, 23),
(80, 56, 37, 6),
(81, 55, 54, 26),
(82, 15, 47, 16),
(83, 14, 37, 11),
(84, 11, 31, 7),
(85, 16, 22, 41),
(86, 4, 18, 35),
(87, 28, 18, 26),
(88, 26, 52, 9),
(89, 26, 35, 15),
(90, 31, 67, 3),
(91, 15, 19, 1),
(92, 22, 22, 2),
(93, 18, 24, 22),
(94, 26, 27, 27),
(95, 25, 24, 20),
(96, 22, 27, 11),
(97, 25, 21, 12),
(98, 19, 21, 10),
(99, 20, 26, 9),
(100, 18, 18, 17)
]
const V = [
      (1, 200),
      (2, 200),
      (3, 200),
      (4, 200),
      (5, 200),
      (6, 200),
      (7, 200),
      (8, 200)
]
#= Global variable D,C, and V should be defined before calling vns_sa
Should be arrays of arrays e.g.(Vector{Vector{Float64}}) 1-indexed =#

function f(s)
    z = 0.0
    d = D[1] 

    for (k, R) in enumerate(s)
        if isempty(R)
            continue
        end

        n = C[R[1]]
        z += √((d[2] - n[2])^2 + (d[3] - n[3])^2)


        for i in 1:length(R)-1
            m = C[R[i+1]]
            z += √((n[2] - m[2])^2 + (n[3] - m[3])^2)
            n = m
        end
        z += √((n[2] - d[2])^2 + (n[3] - d[3])^2)

        # PENALTY
        v = V[k]
        q_v = v[2]
        w = sum(C[i][4] for i in s[k])
        p = max(0, w - q_v)
        z += p * 100
    end

    return z
end

# Neighborhood functions

# N1 Move
function N1(s)
    s_n = deepcopy(s)

    i, j = sample(1:length(V), 2, replace=false)
    if isempty(s_n[i])
        return s_n
    end

    # pick a random customer to remove
    k_from = rand(1:length(s_n[i]))
    c = s_n[i][k_from]
    deleteat!(s_n[i], k_from)

    #pick a random route to insert the customer
    k_to = rand(1:(length(s_n[j]) + 1))
    insert!(s_n[j], k_to, c)

    return s_n
end

# N2 Swap

function N2(s)
    s_n = deepcopy(s)

    i, j = sample(1:length(V), 2, replace=false)
    
    # no route is empty
    if isempty(s_n[i]) || isempty(s_n[j])
        return s_n
    end

    # pick a random customer to swap from each route
    a = rand(1:length(s_n[i]))
    b = rand(1:length(s_n[j]))

    # swap the customers
    s_n[i][a], s_n[j][b] = s_n[j][b], s_n[i][a]
    return s_n
end

# N3 2-opt within a route

function N3(s)
    s_n = deepcopy(s)
    # Find routes with more than 4 customers
    valid_routes = [k for (k, R) in enumerate(s_n) if length(R) >= 4]
    if isempty(valid_routes)
        return s_n
    end

    # Randomly select a route to apply 2-opt
    i = rand(valid_routes)
    R = s_n[i]

    #get two distinct cutting points
    a, b = sort(sample(1:length(R), 2, replace=false))

    # reverse the segment

    reverse!(R, a, b)
    s_n[i] = R
    return s_n
end

N = [N1, N2, N3] # Neighborhood functions
# Local search function
function ls(s, N, X)
    n_iter = get(X, :n, 50)
    for _ in 1:n_iter
        s_n = N(s)
        if f(s_n) < f(s)
            s = deepcopy(s_n)
        end
    end
    return s
end

# Initial solution function
function initial_solution()

    s₀ =[Int[] for _ in 1:length(V)] #empty vector for vehicles

    for (i, c) in enumerate(C)
        q_c = c[4] # get the demand

        for (j, v) in enumerate(V) #first vehicle for this customer
            q_v = v[2] # capacity of the vehicle
            w = isempty(s₀[j]) ? 0 : sum([C[k][4] for k in s₀[j]]) # current load of the vehicle

            if w + q_c <= q_v
                push!(s₀[j], i) # add customer to the vehicle
                break
            end
        end
    end
    println("objective function value: ", f(s₀))
    return s₀
end   
s₀ = initial_solution() # initial solution

    # using the VNS-SA algorithm
    ls_params = Dict(:n => 50) # local search parameters
    T₀ = 0.05 * f(s₀) / log(2) # initial temperature
    r = 0.995 # cooling rate
    n = 100000 # number of iterations
    t = 1e-15

    S_c, S_b = vns_sa(s₀, ls, N, ls_params, T₀, r, n, t, f)

    initial_best_solution = S_b[1]
    final_best_solution = S_b[end]

    println("Final best solution: ", f(final_best_solution))
    @time vns_sa(s₀, ls, N, ls_params, T₀, r, n, t, f)
    @bprofile vns_sa(s₀, ls, N, ls_params, T₀, r, n, t, f)

    #visualize convergence
    iterations = 1:100000
    plot(iterations, [f(s) for s in S_c], label="Current Solution", xlabel="Iteration", ylabel="Objective Value", title="VNS-SA Convergence"
    , legend=:topright, grid=true, linewidth=2, color=:blue, markershape=:circle, markersize=3
    )

    plot!(iterations, [f(s) for s in S_b], label="Best Solution", color=:red, linewidth=2, markershape=:square, markersize=3)
    


