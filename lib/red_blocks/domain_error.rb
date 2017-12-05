module RedBlocks
  class DomainError < StandardError
    def initialize(value, domain)
      @value = value
      @domain = domain
    end

    def message
      "Input `#{@value.inspect}` is out of the domain `#{@domain.inspect}`"
    end
  end
end


