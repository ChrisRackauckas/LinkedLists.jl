__precompile__()

module LinkedLists

import Base: isempty, empty!, length, last, start, next, done
import Base: contains, eltype, unshift!, shift!, deleteat!
import Base: show, println, indexin, endof, push!, pop!, insert!, splice!, eachindex
import Base: find, append!, prepend!
import Base: getindex, setindex!

abstract type AbstractList{T} end
abstract type AbstractNode{T} end

include("list.jl")

export LinkedList, ListNode

export AbstractList, AbstractNode

export SLinkedList, SListNode, eachindex

end # module
