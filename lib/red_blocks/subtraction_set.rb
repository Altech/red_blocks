module RedBlocks
  class SubtractionSet < RedBlocks::Set
    attr_accessor :set1, :set2
    attr_writer :cache_time

    def initialize(set1, set2, cache_time: nil)
      unless [set1, set2].all? { |set| set.is_a?(RedBlocks::Set) }
        raise TypeError.new("set1 and set2 must be a Array<RedBlocks::Set>, but got the following list: #{sets.map(&:class).join(', ')}")
      end

      @set1 = set1
      @set2 = set2
      @cache_time = cache_time
    end

    def key_suffix
      joined_key(sets.map(&:key).sort, sep: '|', wrap: true)
    end

    def update!
      disabled_sets.each(&:update!)
      # [Note] The following operation will be faster if we use Redis script.
      RedBlocks.client.zunionstore(key, [set1.key])
      RedBlocks.client.zrem(key, set2.ids(paginator: RedBlocks::Paginator.all))
      RedBlocks.client.expire(key, expiration_time)
    end

    def cache_time
      @cache_time || super
    end

    def expression(id)
      set1.expression(id)
    end

    def sets
      [set1, set2]
    end

    private

    def disabled_sets
      ttls = RedBlocks.client.pipelined do |pipeline|
        sets.each { |set| pipeline.ttl(set.key) }
      end
      sets.zip(ttls).select do |set, ttl|
        set.disabled?(ttl)
      end.map(&:first)
    end
  end
end
