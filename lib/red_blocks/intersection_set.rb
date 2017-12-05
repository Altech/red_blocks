module RedBlocks
  class IntersectionSet < ComposedSet
    private

    def compose_sets!
      sets = @sets.to_a
      if sets.size > 0
        RedBlocks.client.zinterstore(key, sets.map(&:key), weights: sets.map(&:weight), aggregate: score_func)
      else
        RedBlocks.client.pipelined do
          RedBlocks.client.del(key)
          RedBlocks.client.zadd(key, normalize_entries([]))
        end
      end
    end
  end
end
