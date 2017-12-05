module RedBlocks
  class Paginator
    DEFAULT_PER     = 10
    DEFAULT_PAGE    = 1

    attr_reader :head, :tail, :per, :page

    def initialize(per: DEFAULT_PER, page: DEFAULT_PAGE, head: nil, tail: nil)
      if head && tail
        unless head >= 0 && tail >= 0 && head <= tail
          raise ArgumentError.new("head and tail is out of range (head=#{head}, tail=#{tail})")
        end

        @head = head
        @tail = tail
        return
      end

      @per     = per.to_i
      @page    = page.to_i

      @head = @per * (@page - 1)
      @tail = @head + @per - 1
    end

    def size
      @per || (@tail - @head + 1)
    end

    class All
      def head; 0  end
      def tail; -1 end
    end

    def self.all
      All.new
    end
  end
end
