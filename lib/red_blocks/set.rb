module RedBlocks
  class Set
    include SetUtils
    include SetOptimizer

    def update!(get_result = self.get)
      entries = normalize_entries(validate_entries!(get_result))
      removed_ids = self.ids(paginator: Paginator.all, update_if_disabled: false) - entries.map(&:last)
      RedBlocks.client.pipelined do |pipeline|
        pipeline.zrem(key, removed_ids) if removed_ids.size > 0
        pipeline.zadd(key, entries)
        pipeline.expire(key, expiration_time)
      end
      nil
    end

    def update_if_disabled!
      update! if disabled?
    end

    def disabled?(ttl = RedBlocks.client.ttl(key))
      ttl < RedBlocks.config.intermediate_set_lifetime
    end

    def expiration_time
      RedBlocks.config.intermediate_set_lifetime + cache_time
    end

    def ids(paginator: Paginator.new, with_scores: false, with_expressions: false, update_if_disabled: true)
      update_if_disabled! if update_if_disabled
      res = RedBlocks.client.zrevrange(key, paginator.head, paginator.tail, with_scores: with_scores)
      res
        .map { |id, _score|
          if with_scores || with_expressions
            res = [id.to_i]
            res << _score if with_scores
            res << expression(id) if with_expressions
            res
          else
            id.to_i
          end
        }.select{ |id, _, _|
        id !=  RedBlocks.config.blank_id
      }
    end

    def size(update_if_disabled: true)
      update_if_disabled! if update_if_disabled
      RedBlocks.client.zcard(key) - 1 # Discount the blank entry.
    end

    def key
      joined_key([RedBlocks.config.key_namespace, self.class.key_prefix, key_suffix])
    end

    def self.key_pattern
      joined_key([RedBlocks.config.key_namespace, key_prefix, '*'])
    end

    # # Overridable to sub-classes.
    # ------------------------------------------------------

    private

    # @return [String] A key prefix. This is intended to distinct sets on class-level.
    #  So it uses class name by default. It uses name without module to save memory.
    def self.key_prefix
      self.name
    end

    # @return [String] A key suffix. This is intended to distinct sets on instance-level.
    #   So it will use some instance variable.
    def key_suffix
      raise NotImplementedError
    end

    public

    # @return [Array, Array<Array>] A list of ids, or a zippped list of ids and scores.
    # @example
    #   [1, 3, 5]
    # @example
    #   [[1, 3.4], [5, 2.3]]
    def get
      raise NotImplementedError
    end

    # @return [Integer] Cache time in seconds.
    def cache_time
      RedBlocks::CachePolicy.none
    end

    # @return [Numeric] A scale factor for score calculaton on intersection or union.
    def weight
      @weight || 1
    end

    attr_writer :weight

    def label
      nil
    end

    # Used in debug mode (with_expressions option)
    def expression(id)
      score = self.disabled? ? nil : (RedBlocks.client.zscore(key, id) || 0)
      Expression.new(key, score: score, label: label, weight: weight)
    end
  end
end
