module RedBlocks
  class ComposedExpression < Expression
    attr_accessor :operands, :operator

    def initialize(key, operator:,  operands:, weight: 1, label: nil)
      super(key, weight: weight, label: label)
      @operator = operator
      @operands = operands
    end

    def to_s
      operands_str = operands
        .select { |exp| exp.is_a?(ComposedExpression) || exp.score.nil? || exp.score != 0 }
        .map { |exp| exp.to_s }
      case operator
      when :sum
        str = operands_str.join(' + ')
        str = "(#{str}) * #{weight}" if weight != 1
        str
      else
        str = "#{operator.to_s}(#{operands_str.join(', ')})"
        str = "#{str} * #{weight}" if weight != 1
        str
      end
    end
  end
end
