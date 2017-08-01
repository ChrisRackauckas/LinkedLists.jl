# LinkedLists.jl

[![Build Status](https://travis-ci.org/ChrisRackauckas/Lists.jl.svg?branch=master)](https://travis-ci.org/ChrisRackauckas/Lists.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/y21avwoiq01g9ps6?svg=true)](https://ci.appveyor.com/project/ChrisRackauckas/lists-jl)
[![Coverage Status](https://coveralls.io/repos/github/ChrisRackauckas/Lists.jl/badge.svg?branch=master)](https://coveralls.io/github/ChrisRackauckas/Lists.jl?branch=master)

**LinkedList collections for Julia**

This package provides a singly linked list and a doubly linked list
implementation, as Julia collections. Singly linked lists are
supported with `cons`, `car`, and `cdr`, but not as a standard
collection. Doubly linked lists are included in the samples but,
again, not as a collection. This doesn't do anything fancy
like create an array of nodes. Maybe it should.

## LinkedList

`LinkedList` is a doubly linked list. Deletions happen in constant time.
If code contains an index to an item in the list, then
removing other items in the list won't invalidate that index.

Usage:
```julia
a = LinkedList{Int}()    # Create a list of the given type.
isempty(l)         # Test whether there are any items.
empty!(l)          # Remove all items.
length(l)          # The number of entries. An O(n) operation.
2 in l             # Test whether the given item is an entry in the list. O(n).
eltype(l)          # Returns the item type, here Int.
indexin(a, l)      # Highest index in list for each value of a that is member.
first(l)           # First item in the list.
last(l)            # Last item in the list, the item value.
push!(l, d)        # Add item d to end of list. Returns index of item.
pop!(l, d)         # Remove and return item at end of list.
unshift!(l, d)     # Add item to start of list. Return index of item.
shift!(l)          # Remove first item and return value.
append!(l, items)  # Add items to end of list.
prepend!(l, items) # Add items to start of list.
```

There can be an index into the list. It is a reference to a list
node but can be treated as an opaque index.
```julia
getindex(l, index)     # Returns value of item at this index.
setindex!(l, index, d) # Sets item value at this index.
endof(l)               # Returns index of last node. An O(n) operation.
insert!(l, index, d)   # Insert item at index, pushing values back. Return index.
deleteat!(l, index)    # Delete item at index. Return list.
splice!(l, index)      # Remove value at index, returning data value.
splice!(l, index, d)   # Replace item at index with data value.
find(l, d)             # Find first occurrence of item in list. Return its index.
find(l, index, d)      # Find first occurrence of d after the given index.
```

There are two kinds of iterators for `LinkedList`. One access items.
The other loops over indices.
```julia
l = LinkedList{Int}()
prepend!(l, [2, 4, 6])
for item::Int in l
    println(item)
end

for index in eachindex(l)
    item=getindex(l, index)
    println(item)
end

```

## SLinkedList

`SLinkedList` is a singly linked list over items of a given type.
Appending to the end of this list takes an order of the number of
the items in the list.

Usage:
```julia
a = SLinkedList{Int}()    # Create a list of the given type.
isempty(l)         # Test whether there are any items.
empty!(l)          # Remove all items.
eltype(l)          # Returns the item type, here Int.
first(l)           # First item in the list.
unshift!(l, d)     # Add item to start of list. Return index of item.
shift!(l)          # Remove first item and return value.
prepend!(l, items) # Add items to start of list.
```

There can be an index into the list. It is a reference to a list
node but can be treated as an opaque index.
```julia
getindex(l, index)     # Returns value of item at this index.
setindex!(l, index, d) # Sets item value at this index.
insert!(l, index, d)   # Inserts *after* the given index. Returns index.
```

The following methods are O(n) for singly linked lists.
They are included for completeness, but needing these is an indication
that using a doubly linked list, or Vector, might be a better choice.
```julia
length(l)          # The number of entries.
2 in l             # Test whether the given item is an entry in the list.
indexin(a, l)      # Highest index in list for each value of a that is member.
last(l)            # Last item in the list, the item value.
push!(l, d)        # Add item d to end of list. Returns index of item.
pop!(l, d)         # Remove and return item at end of list.
append!(l, items)  # Add items to end of list.
endof(l)               # Returns index of last node.
deleteat!(l, index)    # Delete item at index. Return list.
splice!(l, index)      # Remove value at index, returning data value.
splice!(l, index, d)   # Replace item at index with data value.
find(l, d)             # Find first occurrence of item in list. Return its index.
find(l, index, d)      # Find first occurrence of d after the given index.
```

As with `LinkedList`, there are two kinds of iterators for `SLinkedList`. One access items.
The other loops over indices.
```julia
l = SLinkedList{Int}()
prepend!(l, [2, 4, 6])
for item::Int in l
    println(item)
end

for index in eachindex(l)
    item=getindex(l, index)
    println(item)
end

```

## Implementation Notes

The code comments each time a method for these classes
differs from interfaces described for collections in
the manual. All differences stem from an assumption
that the index to a collection will be an integer.

If you have comments, or especially if I have the wrong idea
about how to write good code in Julia, please send me an email.

## Credit

Lots of credit goes to @adolgert as this library was adapted from his code.
