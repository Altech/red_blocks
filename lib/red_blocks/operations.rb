# Operations for development.
# Please be careful with using in prduction.
module RedBlocks::Operations
  def self.delete(set_or_pattern)
    keys = self.keys(set_or_pattern)
    RedBlocks.client.pipelined do |pipeline|
      keys.each do |key|
        pipeline.del(key)
      end
    end
  end

  def self.keys(set_or_pattern)
    if set_or_pattern.is_a?(Class) && set_or_pattern <= RedBlocks::Set
      pattern = set_or_pattern.key_pattern
    elsif set_or_pattern.is_a?(String)
      pattern = set_or_pattern
    else
      raise ArgumentError.new("Unexpected pattern(#{set_or_pattern.inspect})")
    end
    scan_keys(pattern)
  end

  def self.delete_intermediate(set, threshold: RedBlocks::CachePolicy.none)
    case set
    when RedBlocks::ComposedSet
      if set.cache_time <= threshold
        RedBlocks.client.del(set.key)
      end

      set.sets.each do |internal_set|
        delete_intermediate(internal_set, threshold: threshold)
      end
    when RedBlocks::Set
      if set.cache_time <= threshold
        RedBlocks.client.del(set.key)
      end
    else
      raise TypeError.new("Expect RedBlocks::Set, but got #{set.class.name}")
    end
  end

  private

  def self.scan_keys(pattern)
    result = []
    while true
      cursor, keys = RedBlocks.client.scan(cursor, match: pattern, count: 1000)
      result += keys
      return result if cursor == "0"
    end
  end
end
