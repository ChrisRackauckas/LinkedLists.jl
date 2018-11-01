module LinkedLists

import Base: isempty, empty!, length, first, last, iterate, isdone
import Base: eltype, pushfirst!, popfirst!, deleteat!
import Base: show, println, indexin, lastindex, push!, pop!, insert!, splice!, keys
import Base: in , append!, prepend!
import Base: getindex, setindex!

abstract type AbstractList{T} end
abstract type AbstractNode{T} end

include("list.jl")

export LinkedList, ListNode

export AbstractList, AbstractNode

export SLinkedList, SListNode, indextoposition, positiontoindex

end # module
