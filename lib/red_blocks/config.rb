module RedBlocks
  class Config
    # Proc which returns Redis client.
    attr_reader :client_proc
    attr_reader :cache_client

    # The key prefix for Redis.
    attr_reader :key_namespace

    # It is guaranteed that all set exist in 30 seconds at least.
    # This means that all transaction must be completed in the time.
    attr_reader :intermediate_set_lifetime

    # Used to represent a "blank" set.
    # So you cannot use 0 in real id.
    attr_reader :blank_id

    # For test. See spec_helper.rb
    attr_reader :infinity

    def initialize(client_proc:, cache_client: false, key_namespace:, intermediate_set_lifetime:, blank_id:, infinity: Float::INFINITY)
      @key_namespace = key_namespace
      @intermediate_set_lifetime = intermediate_set_lifetime
      @blank_id = blank_id
      @client_proc = client_proc
      @cache_client = cache_client
      @infinity = infinity
    end
  end
end
