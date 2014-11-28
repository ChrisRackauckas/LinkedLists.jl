# Lists

List collections for Julia

This package provides a singly linked list and a doubly linked list
implementation, as Julia collections. Singly linked lists are
supported with `cons`, `car`, and `cdr`, but not as a standard
collection. Doubly linked lists are included in the samples but,
again, not as a collection.

## List

`List` is a doubly linked list. Deletions happen in constant time.

*List{T}()*

Creates a list containing items of type T.

*show{T}(io::IO, l::List{T})*

Write a representation of every list element to the given IO stream.

*start{T}(l::List{T})*

Return the initial state of an iterator over items in the list.

*done{T}(l::List{T}, n::ListNode{T})*

Returns whether iteration over items is complete.

## SList

`SList` is a singly linked list over items of a given type.
Appending to the end of this list takes an order of the number of
the items in the list.

*SList{T}()*

Creates a singly linked list of items of type T.


[![Build Status](https://travis-ci.org/adolgert/Lists.jl.svg?branch=master)](https://travis-ci.org/adolgert/Lists.jl)

