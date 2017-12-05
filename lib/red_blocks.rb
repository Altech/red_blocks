module RedBlocks
  class << self
    attr_accessor :config

    def config
      @config ||= RedBlocks::Config.new(
        client_proc: -> { RedBlocks.client },
        key_namespace: 'RB',
        intermediate_set_lifetime: 30,
        blank_id: 0,
      )
    end

    def client
      if self.config.cache_client
        @cln ||= config.client_proc.call
      else
        config.client_proc.call
      end
    end
  end
end

require "red_blocks/config"

require "red_blocks/cache_policy"
require "red_blocks/set_optimizer"
require "red_blocks/set_utils"
require "red_blocks/paginator"

require "red_blocks/operations"
require "red_blocks/expression"
require "red_blocks/composed_expression"

require "red_blocks/domain_error"

require "red_blocks/set"
require "red_blocks/composed_set"
require "red_blocks/union_set"
require "red_blocks/intersection_set"
require "red_blocks/subtraction_set"
require "red_blocks/unit_set"
require "red_blocks/enum_set"
require "red_blocks/instant_set"
