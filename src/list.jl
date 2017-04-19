type ListNode{T} <: AbstractNode{T}
    prev::ListNode{T}
    next::ListNode{T}
    data::T
    ListNode()=(x=new(); x.prev=x; x.next=x; x)
    ListNode(p, n, d)=new(p, n, d)
end
ListNode{T}(p, n, d::T)=ListNode{T}(p, n, d)

# Doubly linked list.
type List{T} <: AbstractList{T}
    node::ListNode{T}
    List()=new(ListNode{T}())
end

type SListNode{T} <: AbstractNode{T}
    next::SListNode{T}
    data::T
    SListNode()=(x=new(); x.next=x; x)
    SListNode(n::SListNode{T}, d::T)=new(n, d)
end
SListNode{T}(n::SListNode{T}, d::T)=SListNode{T}(n, d)

# Singly-linked list
type SList{T} <: AbstractList{T}
    # node is always the last element. Points to the first element.
    node::SListNode{T}
    SList()=new(SListNode{T}())
end


function show{T}(io::IO, l::AbstractList{T})
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

start(l::AbstractList)=l.node.next
done(l::AbstractList, n::AbstractNode)=(n==l.node)
next(l::AbstractList, n::AbstractNode)=(n.data, n.next)

immutable ListIndexIterator{L}
    l::L
end

# Returns an iterator over indices.
# Use getindex, setindex! to find the item at this index.
eachindex(l::AbstractList)=ListIndexIterator(l)
start(liter::ListIndexIterator)=liter.l.node.next
done(liter::ListIndexIterator, n::AbstractNode)=(n==liter.l.node)
next(liter::ListIndexIterator, n::AbstractNode)=(n, n.next)


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
function endof(l::AbstractList)
    node=l.node.next
    while node.next!=l.node
        node=node.next
    end
    node
end
function endof(l::List)
    l.node.prev
end



#### Iterable Collections

function in(item, l::AbstractList)
    for node in l
        if isequal(node.data, item)
            return true
        end
    end
    false
end

eltype{T}(l::AbstractList{T})=T

# Highest index in list for each value in a that is
# a member of the list.
function indexin(a, l::AbstractList)
    highest=zeros(Int, length(a))
    for (lidx, d) in enumerate(l)
        for (xidx, x) in enumerate(a)
            if isequal(x, d)
                highest[xidx]=lidx
                break
            end
        end
    end
    highest
end

first(l::AbstractList)=l.node.next.data

function last(l::AbstractList)
    lastd=l.node.data
    for d in l
        lastd=d
    end
    lastd
end
function last(l::List)
    l.node.prev.data
end


#### Indexable Collections

# Treat the node as an index. It is also what
# is used for the state in iterators.
getindex(l::AbstractList, n::AbstractNode)=n.data
function setindex!(l::List, n::AbstractNode, d)
    n.data=d
end


#### Dequeues

# Breaking interface expectation to push multiple items
# so that we can return an index of the pushed item.
# Use append! for multiple items.
function push!(l::AbstractList, item)
    lnode=endof(l)
    lnode.next=SListNode(lnode.next, item)
    lnode.next
end
function push!(l::List, item)
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
function pop!(l::List)
    d=l.node.prev.data
    l.node.prev.prev.next=l.node
    l.node.prev=l.node.prev.prev
    d
end

# Breaking interface expectation because:
# Returns an index to the item instead of the collection.
# Takes only one value at a time. Use prepend! for multiple.
function unshift!(l::AbstractList, d)
    l.node.next=SListNode(l.node.next, d)
    l.node.next
end
function unshift!(l::List, d)
    toadd=ListNode(l.node, l.node.next, d)
    l.node.next.prev=toadd
    l.node.next=toadd
    toadd
end

function shift!(l::AbstractList)
    x=l.node.next.data
    l.node.next.next.prev=l.node
    l.node.next=l.node.next.next
    x
end
function shift!(l::SList)
    d=l.node.next.data
    l.node.next=l.node.next.next
    d
end

# Insert-after.
function insert!(l::AbstractList, n::AbstractNode, d)
    n.next=typeof(n)(n.next, d)
end
function insert!(l::List, n::ListNode, d)
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
function deleteat!(l::List, n::ListNode)
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

function splice!(l::List, n::ListNode)
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
    lnode=endof(l)
    for i in items
        lnode.next=SListNode(lnode.next, i)
        lnode=lnode.next
    end
end
function append!(l::List, items)
    for i in items
        push!(l, i)
    end
end

function prepend!(l::AbstractList, items)
    for i in reverse(items)
        unshift!(l, i)
    end
    l
end
function prepend!(l::List, items)
    node=l.node # Invariant: Add after the node "node."
    for i in items
        toadd=ListNode(node, node.next, i)
        node.next.prev=toadd
        node.next=toadd
        node=toadd
    end
    l
end


# Adding find, to find the iterator to a given value.
function find(l::AbstractList, d)
    find(l, l.node, d)
end
function find(l::AbstractList, n::AbstractNode, d)
    n=n.next
    while n!=l.node && n.data!=d
        n=n.next
    end
    if n==l.node
        return(nothing)
    end
    n
end
