module RedBlocks
  class InstantSet < RedBlocks::Set
    attr_reader :value, :suffix

    RAND_MAX = 100_000_000

    def initialize(value)
      unless value.is_a?(Array)
        raise TypeError.new("Expect value as Array, but got #{ids_or_ids_with_scores.class}")
      end

      @value = value
      @suffix = rand(RAND_MAX)
    end

    def cache_time
      0
    end

    def get
      value
    end

    def key_suffix
      suffix
    end
  end
end
