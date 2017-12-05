module RedBlocks
  class Expression
    attr_accessor :score, :weight, :label, :key

    def initialize(key, score: nil, weight: 1, label: nil)
      @score = score
      @weight = weight
      @key   = key
      @label = label
    end

    def label
      @label || key
    end

    def to_s
      socre_str = score ? '%0.4f' % (score * weight) : '?'
      "#{socre_str}[#{label}]"
    end
  end
end
