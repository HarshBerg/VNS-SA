function cbrtguessandcheck(x)

    counter = 1

    for guess ∈ 0:abs(x)
        if guess^3 > abs(x)
            println("\n$x is not a perfect cube.")
            break
        end
        if guess^3 != abs(x)
            println(counter, "\tGuess = $guess\tGuess cubed = $(guess^3)")
            counter += 1
        else
            if x < 0
                guess = -guess
            end
            println(counter, "\tGuess = $guess\tGuess cubed = $(guess^3)")
            println("\nThe cube root of $x is $guess")
            break
        end
    end
end

#approximate solution
"""
Test function
"""
function cbrtapproxsolutions(x)

    guess = 0.0
    counter = 1
    increment = 0.01
    sensitivity = 0.1
    while abs(guess^3 - x) >= sensitivity && abs(guess^3) <= abs(x)
        println(counter, "\tGuess = $guess\tGuess cubed = $(guess^3)")
        guess += increment  
        counter += 1
    end

    println(counter, "\tGuess = $guess\tGuess cubed = $(guess^3)")
    guess = round(guess, digits=2)
    x < 0 ? guess = -guess : guess = guess
    println("\nThe cube root of $x is approximately $guess")
end 

#binary search solution
function cbrtbinarysearch(x)

    low = 0.0
    high = abs(x)
    guess = (high + low) / 2.0
    counter = 1
    sensitivity = 0.01

    while abs(guess^3 - x) >= sensitivity 
        println(counter, "\tGuess = $guess\tGuess cubed = $(guess^3)")
        if abs(guess^3) < abs(x)
            low = guess
        else
            high = guess
        end
        guess = (high + low) / 2.0
        counter += 1
    end

    println(counter, "\tGuess = $guess\tGuess cubed = $(guess^3)")
    guess = round(guess, digits=3)
    println("\nThe cube root of $x is approximately $guess")
end


# TODO:
@code_warntype
@time
@profile

using BenchmarkTools
@btime

# Julia Project