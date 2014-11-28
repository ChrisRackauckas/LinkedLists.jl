# Doubly linked list
# Imports from Base have been done already.

export List, ListNode

type ListNode{T}
    prev::ListNode{T}
    next::ListNode{T}
    data::T
    ListNode()=(x=new(); x.prev=x; x.next=x; x)
    ListNode(p, n, d)=new(p, n, d)
end


# Doubly linked list.
type List{T}
    node::ListNode{T}
    List()=new(ListNode{T}())
end


function show{T}(io::IO, l::List{T})
    print(io, "List{", string(T), "}(")
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

start{T}(l::List{T})=l.node.next
done{T}(l::List{T}, n::ListNode{T})=(n==l.node)
next{T}(l::List{T}, n::ListNode{T})=(n.data, n.next)

immutable type ListIndexIterator{T}
    l::List{T}
end

# Returns an iterator over indices.
# Use getindex, setindex! to find the item at this index.
indexed{T}(l::List{T})=ListIndexIterator{T}(l)
start{T}(liter::ListIndexIterator{T})=liter.l.node.next
done{T}(liter::ListIndexIterator{T}, n::ListNode{T})=(n==liter.l.node)
next{T}(liter::ListIndexIterator{T}, n::ListNode{T})=(n, n.next)


#### General Collections
isempty{T}(l::List{T})=(l.node.next==l.node)

function empty!{T}(l::List{T})
    l.node.next=l.node
end

function length{T}(l::List{T})
    cnt=0
    for n in l
        cnt+=1
    end
    cnt
end

# This is supposed to be an integer index, but
# we return the node as an index.
function endof{T}(l::List{T})
    l.node.prev
end



#### Iterable Collections

function in{T}(item::T, l::List{T})
    for node in l
        if isequal(node.data, item)
            return true
        end
    end
    false
end

eltype{T}(l::List{T})=T

# Highest index in list for each value in a that is
# a member of the list.
function indexin{T}(a, l::List{T})
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

first{T}(l::List{T})=l.node.next.data

function last{T}(l::List{T})
    l.node.prev.data::T
end


#### Indexable Collections

# Treat the node as an index. It is also what
# is used for the state in iterators.
getindex{T}(l::List{T}, n::ListNode{T})=n.data
function setindex!{T}(l::List{T}, n::ListNode{T}, d::T)
    n.data=d
end


#### Dequeues

# Breaking interface expectation to push multiple items
# so that we can return an index of the pushed item.
# Use append! for multiple items.
function push!{T}(l::List{T}, item::T)
    toadd=ListNode{T}(l.node.prev, l.node, item)
    l.node.prev.next=toadd
    l.node.prev=toadd
    toadd
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
function unshift!{T}(l::List{T}, d)
    toadd=ListNode{T}(l.node, l.node.next, d)
    l.node.next.prev=toadd
    l.node.next=toadd
    toadd
end

function shift!{T}(l::List{T})
    x=l.node.next.data
    l.node.next.next.prev=l.node
    l.node.next=l.node.next.next
    x
end

# Insert
function insert!{T}(l::List{T}, n::ListNode{T}, d::T)
    toadd=ListNode{T}(n.prev, n, d)
    n.prev.next=toadd
    n.prev=toadd
    toadd
end

# Linear in the number of elements.
# Second argument is the state from an iterator.
function deleteat!{T}(l::List{T}, n::ListNode{T})
    n.prev.next=n.next
    n.next.prev=n.prev
    l
end

# Removal of a node, returning the value at that node.
function splice!{T}(l::List{T}, n::ListNode{T})
    n.prev.next=n.next
    n.next.prev=n.prev
    n.data
end

# Replacement of a node.
function splice!{T}(l::List{T}, n::ListNode{T}, d::T)
    (d, n.data)=(n.data, d)
    d
end

function append!{T}(l::List{T}, items)
    for i in items
        push!(l, i)
    end
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
function find{T}(l::List{T}, d::T)
    find(l, l.node, d)
end

function find{T}(l::List{T}, n::ListNode{T}, d::T)
    n=n.next
    while n!=l.node && n.data!=d
        n=n.next
    end
    if n==l.node
        return(nothing)
    end
    n
end
