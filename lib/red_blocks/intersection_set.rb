module RedBlocks
  class IntersectionSet < ComposedSet
    private

    def compose_sets!(pipeline)
      sets = @sets.to_a
      if sets.size > 0
        pipeline.zinterstore(key, sets.map(&:key), weights: sets.map(&:weight), aggregate: score_func)
      else
        pipeline.del(key)
        pipeline.zadd(key, normalize_entries([]))
      end
    end
  end
end
