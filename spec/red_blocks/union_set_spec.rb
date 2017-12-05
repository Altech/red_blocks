require "spec_helper"

describe RedBlocks::UnionSet do
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
      def get; [[3, 0.0], [2, 4.0], [9, -4.0]] end
    end
  end

  let(:set) {
    RedBlocks::UnionSet.new([klass1.new, klass2.new])
  }

  let(:blank_set) {
    enum = Enumerator.new { |y| }
    RedBlocks::UnionSet.new(enum)
  }

  before do
    RedBlocks.client.del(key1)
    RedBlocks.client.del(key2)
  end

  describe '#update!' do
    it 'executes zunionstore' do
      expect(RedBlocks.client).to receive(:zunionstore)

      set.update!
    end

    it 'stores proper data' do
      set.update!

      expect(RedBlocks.client.zrevrange(set.key, 0, -1)).to eq(['2', '3', '1', '9', RedBlocks.config.blank_id.to_s])
    end

    it 'stores on sum aggregator' do
      set.score_func = :sum
      set.update!

      expect(RedBlocks.client.zrevrange(set.key, 0, -1, with_scores: true)).to eq([["2", 4.2], ["3", 4.0], ["1", 0.5], ["9", -4.0], [RedBlocks.config.blank_id.to_s, -2 *RedBlocks.config.infinity]])
    end

    it 'stores on min aggregator' do
      set.score_func = :min
      set.update!

      expect(RedBlocks.client.zrevrange(set.key, 0, -1, with_scores: true)).to eq([["1", 0.5], ["2", 0.2], ["3", 0.0], ["9", -4.0], [RedBlocks.config.blank_id.to_s, -RedBlocks.config.infinity]])
    end

    it 'stores on max aggregator' do
      set.score_func = :max
      set.update!

      expect(RedBlocks.client.zrevrange(set.key, 0, -1, with_scores: true)).to eq([["3", 4.0], ["2", 4.0], ["1", 0.5], ["9", -4.0], [RedBlocks.config.blank_id.to_s, -RedBlocks.config.infinity]])
    end

    it 'stores blank data' do
      blank_set.update!

      expect(RedBlocks.client.zrevrange(blank_set.key, 0, -1, with_scores: true)).to eq([[RedBlocks.config.blank_id.to_s, -RedBlocks.config.infinity]])
    end
  end

  describe '#ids' do
    it 'returns all disabled sets' do
      RedBlocks.client.del(key1)
      RedBlocks.client.del(key2)
      expect(set.send(:disabled_sets).size).to eq(2)

      set.sets.each do |set|
        set.update!
      end

      expect(set.send(:disabled_sets).size).to eq(0)
    end
  end
end
