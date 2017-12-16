# RedBlocks [![Build Status](https://travis-ci.org/Altech/red_blocks.svg?branch=master)](https://travis-ci.org/Altech/red_blocks)

## What is this?

This gem provides some set classes based on Redis sorted set.
So a set may have scores for each elements.

By using them, it is possible to implement fast ranking system, search system, or filtering system based on coherent cache management of Redis.

## Example

Please suppose that there are some tagged documents and we want to provide search system.
A user can full-text search, and filter by the tags.

For example, to implement the following query:

- serach by the word of "cache mangement"
- And filter by the tag of "new" or "starred"

We construct the follwoing set:

```rb
keyword_set = KeywordSet.new("Ruby") # Each elements have score based on full-text serach.
tagged_set_1 = TaggedSet.new(:new)
tagged_set_2 = TaggedSet.new(:starred)

set = IntersectionSet.new([
  keyword_set,
  UnionSet.new([tagged_set_1, tagged_set_2]),
], cache_time: 3.minutes)
set.ids #=> [3, 4, 8, 9, 1]
```

The result is order by the score of keyword set, because each scores of elements are summed on intersection, or union by default.

This is a simple example, and it is possible to apply this pattern to construct more complex system which has small latency.
For example, if you want to personalize the result, you have to prepare a personalized ranking and use it as a base set.

In general, there are some advantages by using RedBlocks.

- aggregate the result of each service by sorted set operations.
- flatten the latency of each service(e.g. full-text search service, recommendation service) by Redis cache.
- get rid of the cost of Redis key management from programmer.
- get rid of manual checking whether the cache exists or not from programmer.
- possible to construct such systems in object-oridented style.

## Installation

```rb
gem 'red_blocks'
```

## Classes

TODO: document

The latter half of the [slide](https://speakerdeck.com/altech/redblocks) describes the classes of RedBlocks (in japanese).
