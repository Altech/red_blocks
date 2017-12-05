module RedBlocks
  module SetUtils
    def self.included(base)
      base.extend(ClassMethods)
    end

    class InvalidEntriesError < StandardError
      def initialize(entries, key)
        @entries = entries
        @key = key
      end
      attr_reader :entries, :key

      def message
        "Invalid entry: `#{entries.inspect}` for key = #{self.key}"
      end
    end

    module ClassMethods
      def joined_key(array, sep: ':', wrap: false)
        array.map { |key| wrap ? "[#{key}]" : key.to_s }.join(sep)
      end
    end

    def joined_key(*args); self.class.joined_key(*args) end

    def normalize_entries(entries)
      blank_entry = [-RedBlocks.config.infinity, RedBlocks.config.blank_id]
      if entries.first.is_a?(Array)
        entries.map{ |id, score| [score, id] } + [blank_entry]
      else
        entries.map {|id| [0, id] } + [blank_entry]
      end
    end

    def validate_entries!(entries)
      case entries
      when Array
        entry = entries[0]
        case entry
        when Integer
          entries
        when Array
          if !validate_array_entry(entry)
            raise InvalidEntriesError.new(entries, key)
          else
            entries
          end
        when NilClass
          entries
        else
          raise InvalidEntriesError.new(entries, key)
        end
      else
        raise InvalidEntriesError.new(entries, key)
      end
    end

    def validate_array_entry(entry)
      is_pair = entry.size == 2
      id, score = entry
      is_pair && id.is_a?(Integer) && (score.is_a?(Numeric) && !score.to_f.nan?)
    end
  end
end
