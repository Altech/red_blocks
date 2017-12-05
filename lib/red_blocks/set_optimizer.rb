module RedBlocks
  module SetOptimizer
    # Remove intersection set(and union set) that has one set.
    # i.e. `IntersectionSet.new([some_set])` is always equal
    # to `some_set`. So we can remove it.
    def unset
      case self
      when RedBlocks::ComposedSet
        if self.sets.size == 1
          self.sets.first
        else
          new_set = self.dup
          new_set.sets = self.sets.map { |set| set.unset }
          new_set
        end
      when RedBlocks::Set
        self
      else
        raise TypeError.new("Expected a set but got #{self}")
      end
    end
  end
end
