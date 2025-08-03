using Random
using StatsBase
using BenchmarkTools
using Plots

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
const D = [(0, 30, 40, 0)]
const C = [
      (1, 37, 52, 7), 
      (2, 49, 49, 30), 
      (3, 52, 64, 16), 
      (4, 20, 26, 9), 
      (5, 40, 30, 21), 
      (6, 21, 47, 15), 
      (7, 17, 63, 19), 
      (8, 31, 62, 23), 
      (9, 52, 33, 11), 
      (10, 51, 21, 5), 
      (11, 42, 41, 19), 
      (12, 31, 32, 29), 
      (13, 5, 25, 23), 
      (14, 12, 42, 21), 
      (15, 36, 16, 10), 
      (16, 52, 41, 15), 
      (17, 27, 23, 3), 
      (18, 17, 33, 41), 
      (19, 13, 13, 9), 
      (20, 57, 58, 28), 
      (21, 62, 42, 8), 
      (22, 42, 57, 8), 
      (23, 16, 57, 16), 
      (24, 8, 52, 10), 
      (25, 7, 38, 28), 
      (26, 27, 68, 7), 
      (27, 30, 48, 15), 
      (28, 43, 67, 14), 
      (29, 58, 48, 6), 
      (30, 58, 27, 19), 
      (31, 37, 69, 11), 
      (32, 38, 46, 12), 
      (33, 46, 10, 23), 
      (34, 61, 33, 26), 
      (35, 62, 63, 17), 
      (36, 63, 69, 6), 
      (37, 32, 22, 9), 
      (38, 45, 35, 15), 
      (39, 59, 15, 14), 
      (40, 5, 6, 7), 
      (41, 10, 17, 27), 
      (42, 21, 10, 13), 
      (43, 5, 64, 11), 
      (44, 30, 15, 16), 
      (45, 39, 10, 10), 
      (46, 32, 39, 5), 
      (47, 25, 32, 25), 
      (48, 25, 55, 17), 
      (49, 48, 28, 18), 
      (50, 56, 37, 10)
]
const V = [
      (1, 160),
      (2, 160),
      (3, 160),
      (4, 160),
      (5, 160)
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
    n = 1000 # number of iterations
    t = 1e-15

    S_c, S_b = vns_sa(s₀, ls, N, ls_params, T₀, r, n, t, f)

    initial_best_solution = S_b[1]
    final_best_solution = S_b[end]

    println("Final best solution: ", f(final_best_solution))
    @time vns_sa(s₀, ls, N, ls_params, T₀, r, n, t, f)
    @bprofile vns_sa(s₀, ls, N, ls_params, T₀, r, n, t, f)

    #visualize convergence
    iterations = 1:1000
    plot(iterations, [f(s) for s in S_c], label="Current Solution", xlabel="Iteration", ylabel="Objective Value", title="VNS-SA Convergence"
    , legend=:topright, grid=true, linewidth=2, color=:blue, markershape=:circle, markersize=3
    )

    plot!(iterations, [f(s) for s in S_b], label="Best Solution", color=:red, linewidth=2, markershape=:square, markersize=3)
    