using LinkedLists
using Base.Test

@time @testset "Singly-Linked Lists" begin include("testslist.jl") end
@time @testset "Doubly-Linked Lists" begin include("testlist.jl") end
