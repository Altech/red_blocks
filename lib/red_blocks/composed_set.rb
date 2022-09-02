module RedBlocks
  class ComposedSet < RedBlocks::Set
    attr_accessor :sets, :score_func
    attr_writer :cache_time

    SCORE_AGGREGATORS = [:sum, :min, :max]

    def initialize(sets, score_func: :sum, cache_time: nil)
      if sets.size&.zero? # Accepts enumerator, which can return nil for size.
        raise ArgumentError.new("Passed sets are blank.")
      end
      unless SCORE_AGGREGATORS.include?(score_func)
        raise ArgumentError.new("`#{score_func.inspect}` is not valid aggregator. Avaiable aggregator is #{SCORE_AGGREGATORS.join(', ')}")
      end
      unless sets.all? { |set| set.is_a?(RedBlocks::Set) }
        raise TypeError.new("sets must be a Array<RedBlocks::Set>, but got the following list: #{sets.map(&:class).join(', ')}")
      end

      @sets = sets
      @score_func = score_func
      @cache_time = cache_time
    end

    def key_suffix
      joined_key(@sets.map(&:key).sort, sep: '|', wrap: true)
    end

    def update!
      disabled_sets.each(&:update!)
      RedBlocks.client.pipelined do
        compose_sets!
        RedBlocks.client.expire(key, expiration_time)
      end
    end

    def cache_time
      @cache_time || super
    end

    def expression(id)
      ComposedExpression.new(key, operator: score_func, operands: sets.map {|s| s.expression(id)}, label: label, weight: weight)
    end

    private

    def compose_sets!
      raise NotImplementedError
    end

    def disabled_sets
      ttls = RedBlocks.client.pipelined do
        @sets.each { |set| RedBlocks.client.ttl(set.key) }
      end
      @sets.zip(ttls).select do |set, ttl|
        set.disabled?(ttl)
      end.map(&:first)
    end
  end
end
