module RedBlocks
  class EnumSet < RedBlocks::Set
    attr_reader :value

    def initialize(value)
      unless self.class.available_values.include?(value)
        raise RedBlocks::OutOfDomainError.new(value, self.class.available_values)
      end
      @value = value
    end

    # Match string such as `#<User:0x007fa3323a2b90>`
    ADDRESSED_OBJECT_REGEXP = /^#<(.+):0x\w+>$/

    def key_suffix
      suffix = @value.to_s
      if suffix =~ ADDRESSED_OBJECT_REGEXP
        raise <<MSG
The key suffix may include random address #{suffix.inspect}.
You must override `key_suffix` explicitly, or use `value` which implements deterministic `to_s`.
MSG
      end
      suffix
    end

    def self.warmup!
      available_values.each do |value|
        self.new(value).update!
      end
    end

    def self.available_values
      raise NotImplementedError
    end
  end
end
