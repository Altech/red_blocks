require "spec_helper"

describe RedBlocks::ComposedSet do
  let(:key1) { 'RB:Bar:1' }

  let(:key2) { 'RB:Foo:2' }

  let(:klass1) do
    Class.new(RedBlocks::Set) do
      def key; 'RB:Bar:1' end
      def cache_time; 30 end
      def get; [[1, 0.5] , [3, 4.0], [2, 0.2]] end
    end
  end

  let(:klass2) do
    Class.new(RedBlocks::Set) do
      def key; 'RB:Foo:2' end
      def cache_time; 30 end
      def get; [[3, 0.0], [2, 4.0]] end
    end
  end

  describe '#initialize' do
    it 'accepts array of set' do
      RedBlocks::ComposedSet.new([klass1.new, klass2.new])
    end

    it 'doesn\'t accept empty array' do
      expect { RedBlocks::ComposedSet.new([]) }.to raise_error(ArgumentError)
    end

    it 'accepts enumerator' do
      enum = Enumerator.new{|y|
        y << klass1.new
        y << klass2.new
      }
      RedBlocks::ComposedSet.new(enum)
    end

    it 'accepts enumerator which generates none' do
      enum = Enumerator.new{|y|
      }
      RedBlocks::ComposedSet.new(enum)
    end

    it 'has cache_time option' do
      set = RedBlocks::ComposedSet.new([klass1.new], cache_time: 30 * 60)
      expect(set.cache_time).to eq(30 * 60)
    end

    it 'has score_func option' do
      set = RedBlocks::ComposedSet.new([klass1.new], score_func: :min)
      expect(set.score_func).to eq(:min)
    end
  end

  let(:set) {
    RedBlocks::ComposedSet.new([klass1.new, klass2.new])
  }

  describe '#key' do
    it 'returns joined string' do
      expect(set.key).to eq('RBTEST:RedBlocks::ComposedSet:[RB:Bar:1]|[RB:Foo:2]')
    end
  end

  describe '#disabled_sets' do
    it 'returns all disabled sets' do
      RedBlocks.client.del(key1)
      RedBlocks.client.del(key2)
      expect(set.send(:disabled_sets).size).to eq(2)
      expect(set.send(:disabled_sets)).to eq(set.sets)

      set.sets.each do |set|
        set.update!
      end

      expect(set.send(:disabled_sets).size).to eq(0)
    end
  end
end
