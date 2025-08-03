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
const D = [(0, 92, 92, 0)]
const C = [
      (1, 88, 58, 24),
(2, 70, 6, 22),
(3, 57, 59, 23),
(4, 0, 98, 5),
(5, 61, 38, 11),
(6, 65, 22, 23),
(7, 91, 52, 26),
(8, 59, 2, 9),
(9, 3, 54, 23),
(10, 95, 38, 9),
(11, 80, 28, 14),
(12, 66, 42, 16),
(13, 79, 74, 12),
(14, 99, 25, 2),
(15, 20, 43, 2),
(16, 40, 3, 6),
(17, 50, 42, 20),
(18, 97, 0, 26),
(19, 21, 19, 12),
(20, 36, 21, 15),
(21, 100, 61, 13),
(22, 11, 85, 26),
(23, 69, 35, 17),
(24, 69, 22, 7),
(25, 29, 35, 12),
(26, 14, 9, 4),
(27, 50, 33, 4),
(28, 89, 17, 20),
(29, 57, 44, 10),
(30, 60, 25, 9),
(31, 48, 42, 2),
(32, 17, 93, 9),
(33, 21, 50, 1),
(34, 77, 18, 2),
(35, 2, 4, 2),
(36, 63, 83, 12),
(37, 68, 6, 14),
(38, 41, 95, 23),
(39, 48, 54, 21),
(40, 98, 73, 13),
(41, 26, 38, 13),
(42, 69, 76, 23),
(43, 40, 1, 3),
(44, 65, 41, 6),
(45, 14, 86, 23),
(46, 32, 39, 11),
(47, 14, 24, 2),
(48, 96, 5, 7),
(49, 82, 98, 13),
(50, 23, 85, 10),
(51, 63, 69, 3),
(52, 87, 19, 6),
(53, 56, 75, 13),
(54, 15, 63, 2),
(55, 10, 45, 14),
(56, 7, 30, 7),
(57, 31, 11, 21),
(58, 36, 93, 7),
(59, 50, 31, 22),
(60, 49, 52, 13),
(61, 39, 10, 22),
(62, 76, 40, 18),
(63, 83, 34, 22),
(64, 33, 51, 6),
(65, 0, 15, 2),
(66, 52, 82, 11),
(67, 52, 82, 5),
(68, 46, 6, 9),
(69, 3, 26, 9),
(70, 46, 80, 5),
(71, 94, 30, 12),
(72, 26, 76, 2),
(73, 75, 92, 12),
(74, 57, 51, 19),
(75, 34, 21, 6),
(76, 28, 80, 14),
(77, 59, 66, 2),
(78, 51, 16, 2),
(79, 87, 11, 24)
]
const V = [
      (1, 100),
       (2, 100),
        (3, 100),
        (4, 100),
        (5, 100),
        (6, 100),
        (7, 100),
        (8, 100),
        (9, 100),
        (10, 100)
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
    n = 75000 # number of iterations
    t = 1e-15

    S_c, S_b = vns_sa(s₀, ls, N, ls_params, T₀, r, n, t, f)

    initial_best_solution = S_b[1]
    final_best_solution = S_b[end]

    println("Final best solution: ", f(final_best_solution))
    @time vns_sa(s₀, ls, N, ls_params, T₀, r, n, t, f)
    @bprofile vns_sa(s₀, ls, N, ls_params, T₀, r, n, t, f)

    #visualize convergence
    iterations = 1:75000
    plot(iterations, [f(s) for s in S_c], label="Current Solution", xlabel="Iteration", ylabel="Objective Value", title="VNS-SA Convergence"
    , legend=:topright, grid=true, linewidth=2, color=:blue, markershape=:circle, markersize=3
    )

    plot!(iterations, [f(s) for s in S_b], label="Best Solution", color=:red, linewidth=2, markershape=:square, markersize=3)
    


