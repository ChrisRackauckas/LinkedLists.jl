using LinkedLists

function consistent(l::LinkedList)
    node=l.node
    while node.next!=l.node
        @assert(node.next.prev==node)
        @assert(node.prev.next==node)
        node=node.next
    end
end

function walkthrough_list()
    l=LinkedList{Int}()
    @assert(isempty(l))
    @assert(length(l)==0)
    vals=[3,2,7,7,9]

    prepend!(l, vals)
    consistent(l)

    println(l)
    println(vals)
    compare(vals, l)
    compare_iterator(vals, l)

    @assert(!isempty(l))
    show(l)

    pushfirst!(vals, 8)
    pushfirst!(l, 8)
    compare(vals, l)
    consistent(l)

    @assert(length(l)==6)

    @assert(indextoposition(findall(x -> x∈[2,3], l) ,l) == findall(x -> x∈[2,3], vals))
    @assert(indextoposition(indexin([2,3,12], l),l) == indexin([2,3,12], vals))

    @assert(unique(l)==unique(vals))

    @assert(getindex(l, lastindex(l))==9)

    @assert(!in(13, l))
    @assert(in(2, l))
    @assert(eltype(l)==Int)
    @assert(first(l)==8)
    @assert(last(l)==9)
    show(l)
    println()
    push!(l, 11)
    consistent(l)
    @assert(pop!(l)==11)
    compare(vals, l)
    consistent(l)
    @assert(popfirst!(l)==8)
    popfirst!(vals)
    compare(vals, l)
    consistent(l)

    two=findfirst(x -> x==2 ,l)
    insert!(l, two, 6)
    insert!(vals, 2, 6)
    consistent(l)
    println(l)
    println(vals)
    compare(vals, l)
    deleteat!(l, two)
    deleteat!(vals, 3)
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

walkthrough_list()
