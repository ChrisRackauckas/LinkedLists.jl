mutable struct ListNode{T} <: AbstractNode{T}
    prev::ListNode{T}
    next::ListNode{T}
    data::T
    ListNode{T}() where T =(x=new(); x.prev=x; x.next=x; x)
    ListNode{T}(p, n, d) where T =new(p, n, d)
end
ListNode(p, n, d::T) where T =ListNode{T}(p, n, d)

# Doubly linked list.
mutable struct LinkedList{T} <: AbstractList{T}
    node::ListNode{T}
    LinkedList{T}() where T =new(ListNode{T}())
end

mutable struct SListNode{T} <: AbstractNode{T}
    next::SListNode{T}
    data::T
    SListNode{T}() where T =(x=new(); x.next=x; x)
    SListNode{T}(n::SListNode{T}, d::T) where T =new(n, d)
end
SListNode(n::SListNode{T}, d::T) where T =SListNode{T}(n, d)

# Singly-linked list
mutable struct SLinkedList{T} <: AbstractList{T}
    # node is always the last element. Points to the first element.
    node::SListNode{T}
    SLinkedList{T}() where T =new(SListNode{T}())
end


function show(io::IO, l::AbstractList{T}) where T
    print(io, "$(typeof(l)){", string(T), "}(")
    middle=false
    for item in l
        if middle
            print(io, ", ")
        end
        show(io, item)
        middle=true
    end
    print(io, ")")
end


# The section titles work through sections of the manual.
#### Iteration

isdone(l::AbstractList, n::AbstractNode)=(n==l.node)
iterate(l::AbstractList, n::AbstractNode=l.node.next)= n==l.node ? nothing : (n.data, n.next)

struct ListIndexIterator{L}
    l::L
end

# Returns an iterator over indices.
# Use getindex, setindex! to find the item at this index.
keys(l::AbstractList)=ListIndexIterator(l)
length(l::ListIndexIterator) = length(l.l)
iterate(liter::ListIndexIterator, n::AbstractNode=liter.l.node.next)= n==liter.l.node ? nothing : (n, n.next)


#### General Collections
isempty(l::AbstractList)=(l.node.next==l.node)

function empty!(l::AbstractList)
    l.node.next=l.node
end

function length(l::AbstractList)
    cnt=0
    for n in l
        cnt+=1
    end
    cnt
end

# This is supposed to be an integer index, but
# we return the node as an index.
function lastindex(l::AbstractList)
    node=l.node.next
    while node.next!=l.node
        node=node.next
    end
    node
end
function lastindex(l::LinkedList)
    l.node.prev
end



#### Iterable Collections

function in(item, l::AbstractList)
    miss=false
    for e in l
        if e == item
            return true
        elseif e === missing
            miss=true
        end
    end
    miss ? missing : false
end

eltype(l::AbstractList{T}) where T = T

# Highest index in list for each value in a that is
# a member of the list.
function indexin(a, l::AbstractList)
    highest::Vector{Union{Nothing,T} where T<:AbstractNode}  = fill(nothing, length(a))
    for (node, data) in pairs(l)
        for (xidx, x) in enumerate(a)
            if isequal(x, data)
                highest[xidx]=node
                break
            end
        end
    end
    return highest
end

first(l::AbstractList)=l.node.next.data

"""
    last(l::AbstractList)

Traverse the list and return the value stored in the last node.
It is `O(n)` because of the traversal.
Fallback used for single-linked lists (`SLinkedList`).
"""
function last(l::AbstractList)
    lastd=l.node.data
    for d in l
        lastd=d
    end
    lastd
end

"""
    last(l::LinkedList)

Returns the value stored in the last node in `O(1)` time.
Does not make use of `lastindex`.
"""
function last(l::LinkedList)
    l.node.prev.data
end


#### Indexable Collections

# Treat the node as an index. It is also what
# is used for the state in iterators.
getindex(l::AbstractList, n::AbstractNode)=n.data
function setindex!(l::LinkedList, n::AbstractNode, d)
    n.data=d
end


#### Dequeues

# Breaking interface expectation to push multiple items
# so that we can return an index of the pushed item.
# Use append! for multiple items.
function push!(l::AbstractList, item)
    lnode=lastindex(l)
    lnode.next=SListNode(lnode.next, item)
    lnode.next
end
function push!(l::LinkedList, item)
    toadd=ListNode(l.node.prev, l.node, item)
    l.node.prev.next=toadd
    l.node.prev=toadd
    toadd
end

function pop!(l::AbstractList)
    node=l.node
    while node.next.next!=l.node
        node=node.next
    end
    d=node.next.data
    node.next=node.next.next
    d
end
function pop!(l::LinkedList)
    d=l.node.prev.data
    l.node.prev.prev.next=l.node
    l.node.prev=l.node.prev.prev
    d
end

# Breaking interface expectation because:
# Returns an index to the item instead of the collection.
# Takes only one value at a time. Use prepend! for multiple.
function pushfirst!(l::AbstractList, d)
    l.node.next=SListNode(l.node.next, d)
    l.node.next
end
function pushfirst!(l::LinkedList, d)
    toadd=ListNode(l.node, l.node.next, d)
    l.node.next.prev=toadd
    l.node.next=toadd
    toadd
end

function popfirst!(l::AbstractList)
    x=l.node.next.data
    l.node.next.next.prev=l.node
    l.node.next=l.node.next.next
    x
end
function popfirst!(l::SLinkedList)
    d=l.node.next.data
    l.node.next=l.node.next.next
    d
end

# Insert-after.
function insert!(l::AbstractList, n::AbstractNode, d)
    n.next=typeof(n)(n.next, d)
end
function insert!(l::LinkedList, n::ListNode, d)
    toadd=ListNode(n.prev, n, d)
    n.prev.next=toadd
    n.prev=toadd
    toadd
end

# Linear in the number of elements.
# Second argument is the state from an iterator.
function deleteat!(l::AbstractList, n::AbstractNode)
    prev=l.node
    while prev.next!=n
        prev=prev.next
    end
    prev.next=n.next
    l
end
function deleteat!(l::LinkedList, n::ListNode)
    n.prev.next=n.next
    n.next.prev=n.prev
    l
end

# Removal of a node, returning the value at that node.
function splice!(l::AbstractList, n::AbstractNode)
    prev=l.node
    while prev.next!=n
        prev=prev.next
    end
    prev.next=n.next
    n.data
end

function splice!(l::LinkedList, n::ListNode)
    n.prev.next=n.next
    n.next.prev=n.prev
    n.data
end

# Replacement of a node.
function splice!(l::AbstractList, n::AbstractNode, d)
    (d, n.data)=(n.data, d)
    d
end

function append!(l::AbstractList, items)
    lnode=lastindex(l)
    for i in items
        lnode.next=SListNode(lnode.next, i)
        lnode=lnode.next
    end
end
function append!(l::LinkedList, items)
    for i in items
        push!(l, i)
    end
end

function prepend!(l::AbstractList, items)
    for i in reverse(items)
        pushfirst!(l, i)
    end
    l
end
function prepend!(l::LinkedList, items)
    node=l.node # Invariant: Add after the node "node."
    for i in items
        toadd=ListNode(node, node.next, i)
        node.next.prev=toadd
        node.next=toadd
        node=toadd
    end
    l
end

#find the index (node) of the first element of l for which predicate returns true
function findfirst(predicate, l::AbstractList)
    for n in ListIndexIterator
        if predicate(n.data) return n end
    end
    return(nothing)
end

# returns the position of a node in a list
function indextoposition(n::AbstractNode, l::AbstractList)
    for (i, node) in enumerate(ListIndexIterator(l))
        if node === n return i end
    end
    return nothing
end
indextoposition(a::Vector, l::AbstractList) = map(x -> indextoposition(x,l) , a)
indextoposition(::Nothing, _) = nothing
function positiontoindex(i::Int, l::AbstractList)
    if i <= length(l)
        ii = 0
        for j in keys(l)
            ii += 1
            if ii === i
                return j
            end
        end
    else
        error("list is shorter than $i")
    end
end
positiontoindex(v::Vector, l::AbstractList) = map(x -> positiontoindex(x, l), v)
positiontoindex(::Nothing, _) = nothing

# getindex (positiontoindex will error if idx is invalid)
Base.getindex(lst::AbstractList, idx::Int) = lst[positiontoindex(idx, lst)]
