# Doubly linked list
# Imports from Base have been done already.

export List, ListNode

type ListNode{T} <: AbstractNode{T}
    prev::ListNode{T}
    next::ListNode{T}
    data::T
    ListNode()=(x=new(); x.prev=x; x.next=x; x)
    ListNode(p, n, d)=new(p, n, d)
end

# Doubly linked list.
type List{T} <: AbstractList{T}
    node::ListNode{T}
    List()=new(ListNode{T}())
end

# Singly linked list

type SListNode{T} <: AbstractNode{T}
    next::SListNode{T}
    data::T
    SListNode()=(x=new(); x.next=x; x)
    SListNode(n::SListNode{T}, d::T)=new(n, d)
end


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

start{T}(l::AbstractList{T})=l.node.next
done{T}(l::AbstractList{T}, n::AbstractNode{T})=(n==l.node) next{T}(l::AbstractList{T}, n::AbstractNode{T})=(n.data, n.next)

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
isempty{T}(l::AbstractList{T})=(l.node.next==l.node)

function empty!{T}(l::AbstractList{T})
    l.node.next=l.node
end

function length{T}(l::AbstractList{T})
    cnt=0
    for n in l
        cnt+=1
    end
    cnt
end

# This is supposed to be an integer index, but
# we return the node as an index.
function endof{T}(l::AbstractList{T})
    node=l.node.next
    while node.next!=l.node
        node=node.next
    end
    node
end
function endof{T}(l::List{T})
    l.node.prev
end



#### Iterable Collections

function in{T}(item::T, l::AbstractList{T})
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
function indexin{T}(a, l::AbstractList{T})
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

first{T}(l::AbstractList{T})=l.node.next.data

function last{T}(l::AbstractList{T})
    l.node.prev.data::T
end


#### Indexable Collections

# Treat the node as an index. It is also what
# is used for the state in iterators.
getindex{T}(l::List{T}, n::AbstractNode{T})=n.data
function setindex!{T}(l::List{T}, n::AbstractNode{T}, d::T)
    n.data=d
end


#### Dequeues

# Breaking interface expectation to push multiple items
# so that we can return an index of the pushed item.
# Use append! for multiple items.
function push!{T}(l::AbstractList{T}, item::T)
    lnode=endof(l)
    lnode.next=SListNode{T}(lnode.next, item)
    lnode.next
end
function push!{T}(l::List{T}, item::T)
    toadd=ListNode{T}(l.node.prev, l.node, item)
    l.node.prev.next=toadd
    l.node.prev=toadd
    toadd
end

function pop!{T}(l::AbstractList{T})
    node=l.node::SListNode{T}
    while node.next.next!=l.node
        node=node.next::SListNode{T}
    end
    d=node.next.data
    node.next=node.next.next
    d
end
function pop!{T}(l::List{T})
    d=l.node.prev.data
    l.node.prev.prev.next=l.node
    l.node.prev=l.node.prev.prev
    d
end

# Breaking interface expectation because:
# Returns an index to the item instead of the collection.
# Takes only one value at a time. Use prepend! for multiple.
function unshift!{T}(l::AbstractList{T}, d)
    l.node.next=SListNode{T}(l.node.next, d)
    l.node.next
end
function unshift!{T}(l::List{T}, d)
    toadd=ListNode{T}(l.node, l.node.next, d)
    l.node.next.prev=toadd
    l.node.next=toadd
    toadd
end

function shift!{T}(l::AbstractList{T})
    x=l.node.next.data
    l.node.next.next.prev=l.node
    l.node.next=l.node.next.next
    x
end

# Insert-after.
function insert!{T}(l::AbstractList{T}, n::AbstractNode{T}, d::T)
    n.next=typeof(n)(n.next, d)
end
function insert!{T}(l::List{T}, n::ListNode{T}, d::T)
    toadd=ListNode{T}(n.prev, n, d)
    n.prev.next=toadd
    n.prev=toadd
    toadd
end

# Linear in the number of elements.
# Second argument is the state from an iterator.
function deleteat!{T}(l::AbstractList{T}, n::AbstractNode{T})
    prev=l.node
    while prev.next!=n
        prev=prev.next
    end
    prev.next=n.next
    l
end
function deleteat!{T}(l::List{T}, n::ListNode{T})
    n.prev.next=n.next
    n.next.prev=n.prev
    l
end

# Removal of a node, returning the value at that node.
function splice!{T}(l::AbstractList{T}, n::AbstractNode{T})
    prev=l.node
    while prev.next!=n
        prev=prev.next
    end
    prev.next=n.next
    n.data
end

function splice!{T}(l::List{T}, n::ListNode{T})
    n.prev.next=n.next
    n.next.prev=n.prev
    n.data
end

# Replacement of a node.
function splice!{T}(l::AbstractList{T}, n::AbstractNode{T}, d::T)
    (d, n.data)=(n.data, d)
    d
end

function append!{T}(l::AbstractList{T}, items)
    lnode=endof(l)
    for i in items
        lnode.next=SListNode{T}(lnode.next, i)
        lnode=lnode.next
    end
end
function append!{T}(l::List{T}, items)
    for i in items
        push!(l, i)
    end
end

function prepend!{T}(l::AbstractList{T}, items)
    for i in reverse(items)
        unshift!(l, i)
    end
    l
end
function prepend!{T}(l::List{T}, items)
    node=l.node # Invariant: Add after the node "node."
    for i in items
        toadd=ListNode{T}(node, node.next, i)
        node.next.prev=toadd
        node.next=toadd
        node=toadd
    end
    l
end


# Adding find, to find the iterator to a given value.
function find{T}(l::AbstractList{T}, d::T)
    find(l, l.node, d)
end
function find{T}(l::AbstractList{T}, n::AbstractNode{T}, d::T)
    n=n.next
    while n!=l.node && n.data!=d
        n=n.next
    end
    if n==l.node
        return(nothing)
    end
    n
end
