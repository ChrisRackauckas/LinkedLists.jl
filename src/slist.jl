# Singly linked list
import Base: isempty, empty!, length, last, start, next, done
import Base: contains, eltype, unshift!, shift!, deleteat!
import Base: show, println, indexin, endof, push!, pop!, insert!, splice!
import Base: find, append!, prepend!
export SList, SListNode, indexed

type SListNode{T}
    next::SListNode{T}
    data::T
    SListNode()=(x=new(); x.next=x; x)
    SListNode(n::SListNode{T}, d::T)=new(n, d)
end


# Singly-linked list
type SList{T}
    # node is always the last element. Points to the first element.
    node::SListNode{T}
    SList()=new(SListNode{T}())
end

function show{T}(io::IO, l::SList{T})
    print(io, "SList{", string(T), "}(")
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

start{T}(l::SList{T})=l.node.next
done{T}(l::SList{T}, n::SListNode{T})=(n==l.node)
next{T}(l::SList{T}, n::SListNode{T})=(n.data, n.next)

immutable type SListIndexIterator{T}
    l::SList{T}
end

# Returns an iterator over indices.
# Use getindex, setindex! to find the item at this index.
indexed{T}(l::SList{T})=SListIndexIterator{T}(l)
start{T}(liter::SListIndexIterator{T})=liter.l.node.next
done{T}(liter::SListIndexIterator{T}, n::SListNode{T})=(n==liter.l.node)
next{T}(liter::SListIndexIterator{T}, n::SListNode{T})=(n, n.next)


#### General Collections
isempty{T}(l::SList{T})=(l.node.next==l.node)

function empty!{T}(l::SList{T})
    l.node.next=l.node
end

function length{T}(l::SList{T})
    cnt=0
    for n in l
        cnt+=1
    end
    cnt
end

# This is supposed to be an integer index, but
# we return the node as an index.
function endof{T}(l::SList{T})
    node=l.node.next::SListNode{T}
    while node.next!=l.node
        node=node.next::SListNode{T}
    end
    node
end

#### Iterable Collections

function in{T}(item::T, l::SList{T})
    for node in l
        if isequal(node.data, item)
            return true
        end
    end
    false
end

eltype{T}(l::SList{T})=T

# Highest index in list for each value in a that is
# a member of the list.
function indexin{T}(a, l::SList{T})
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


first{T}(l::SList{T})=l.node.next.data

function last{T}(l::SList{T})
    lastd=l.node.data::T
    for d in l
        lastd=d::T
    end
    lastd
end


#### Indexable Collections

# Treat the node as an index. It is also what
# is used for the state in iterators.
getindex{T}(l::SList{T}, n::SListNode{T})=n.data
function setindex!{T}(l::SList{T}, n::SListNode{T}, d::T)
    n.data=d
end

#### Dequeues

# Breaking interface expectation to push multiple items
# so that we can return an index of the pushed item.
# Use append! for multiple items.
function push!{T}(l::SList{T}, item::T)
    lnode=endof(l)
    lnode.next=SListNode{T}(lnode.next, item)
    lnode.next
end

function pop!{T}(l::SList{T})
    node=l.node::SListNode{T}
    while node.next.next!=l.node
        node=node.next::SListNode{T}
    end
    d=node.next.data
    node.next=node.next.next
    d
end

# Breaking interface expectation because:
# Returns an index to the item instead of the collection.
# Takes only one value at a time. Use prepend! for multiple.
function unshift!{T}(l::SList{T}, d)
    l.node.next=SListNode{T}(l.node.next, d)
    l.node.next
end

function shift!{T}(l::SList{T})
    d=l.node.next.data
    l.node.next=l.node.next.next
    d
end

# Insert-after.
function insert!{T}(l::SList{T}, n::SListNode{T}, d::T)
    n.next=SListNode{T}(n.next, d)
end

# Linear in the number of elements.
# Second argument is the state from an iterator.
function deleteat!{T}(l::SList{T}, n::SListNode{T})
    prev=l.node
    while prev.next!=n
        prev=prev.next
    end
    prev.next=n.next
    l
end

function splice!{T}(l::SList{T}, n::SListNode{T})
    prev=l.node
    while prev.next!=n
        prev=prev.next
    end
    prev.next=n.next
    n.data
end

function splice!{T}(l::SList{T}, n::SListNode{T}, d::T)
    (d, n.data)=(n.data, d)
    d
end

function append!{T}(l::SList{T}, items)
    lnode=endof(l)
    for i in items
        lnode.next=SListNode{T}(lnode.next, i)
        lnode=lnode.next
    end
end

function prepend!{T}(l::SList{T}, items)
    for i in reverse(items)
        unshift!(l, i)
    end
    l
end

# Adding find, to find the iterator to a given value.
function find{T}(l::SList{T}, d::T)
    find(l, l.node, d)
end

function find{T}(l::SList{T}, n::SListNode{T}, d::T)
    n=n.next
    while n!=l.node && n.data!=d
        n=n.next
    end
    if n==l.node
        return(nothing)
    end
    n
end

