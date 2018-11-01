using LinkedLists

function compare(array, list)
    # Iterate over items in container.
    for (ridx, d) in enumerate(list)
        @assert(d==array[ridx])
    end
end

function compare_iterator(array, list)
    # Iterate over indices of container, which are nodes.
    for (ridx, iter) in enumerate(eachindex(list))
        @assert(getindex(list, iter)==array[ridx])
    end
end

function walkthrough()
    l=SLinkedList{Int}()
    @assert(isempty(l))
    @assert(length(l)==0)
    vals=[3,2,7,7,9]

    prepend!(l, vals)
    println(l)
    println(vals)
    compare(vals, l)
    compare_iterator(vals, l)

    @assert(!isempty(l))
    show(l)

    pushfirst!(vals, 8)
    pushfirst!(l, 8)
    compare(vals, l)

    @assert(length(l)==6)

    @assert(indextoposition(findall(x -> x∈[2,3], l) ,l) == findall(x -> x∈[2,3], vals))
    @assert(indextoposition(indexin([2,3,12], l), l) == indexin([2,3,12], vals))

    @assert(unique(l)==unique(vals))

    @assert(getindex(l, lastindex(l))==9)

    @assert(!in(13, l))
    @assert(in(2, l))
    @assert(2 in l)
    @assert(eltype(l)==Int)
    @assert(first(l)==8)
    @assert(last(l)==9)
    show(l)
    push!(l, 11)
    println(l)
    println(vals)
    @assert(pop!(l)==11)
    @assert(popfirst!(l)==8)
    popfirst!(vals)

    two=findfirst(x -> x==2, l)
    insert!(l, two, 6)
    insert!(vals, 3, 6)
    compare(vals, l)
    deleteat!(l, two)
    deleteat!(vals, 2)
    compare(vals, l)
    splice!(l, findfirst(x -> x==9, l))
    deleteat!(vals, 5)
    compare(vals, l)
    splice!(l, findfirst(x -> x==6, l), 12)
    vals[2]=12
    compare(vals, l)
    append!(l, [23, 24])
    append!(vals, [23, 24])
    compare(vals, l)
    prepend!(l, [17, 16])
    prepend!(vals, [17, 16])
    println(l)
    println(vals)
    compare(vals, l)
end

walkthrough()
