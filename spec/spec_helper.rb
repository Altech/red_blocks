$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "red_blocks"

require 'redis'
require 'mock_redis'

RedBlocks.config = RedBlocks::Config.new(
  client_proc: -> { MockRedis.new }, # Replace to `RedBlocks.client` if you want to test on a real Redis.
  cache_client: true,
  key_namespace: 'RBTEST',
  intermediate_set_lifetime: 30,
  blank_id: 0,
  infinity: 10000000 # MockRedis doesn't support infinity as score of sorted set.
)

require 'pry'
