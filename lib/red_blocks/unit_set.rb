module RedBlocks
  class UnitSet < RedBlocks::Set
    def key_suffix
      'Unit'
    end

    def self.warmup!
      self.new.update!
    end
  end
end
