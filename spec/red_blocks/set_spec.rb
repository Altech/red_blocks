require "spec_helper"

describe RedBlocks::Set do
  describe '#get' do
    it 'is not implemented' do
      expect { RedBlocks::Set.new.get }.to raise_error(NotImplementedError)
    end
  end

  describe '#key_suffix' do
    it 'is not implemented' do
      expect { RedBlocks::Set.new.send(:key_suffix) }.to raise_error(NotImplementedError)
    end
  end

  let(:set_subclass) {
    Class.new(RedBlocks::Set) do
      def key_suffix
        'unit'
      end
    end
  }

  let(:set) {
    set_subclass.new
  }

  before do
    stub_const("TestSet", set_subclass)
    RedBlocks.client.del(set.key)
  end

  describe '#update!' do

    it 'stores ids without scores' do
      get_result = [1,2,3]
      allow(set).to receive(:get).and_return(get_result)

      set.update!

      expect(RedBlocks.client.zrange(set.key, 0, -1)).to eq([RedBlocks.config.blank_id, 1, 2, 3].map(&:to_s))
    end

    it 'stores ids with score' do
      get_result = [[1, 0.5] , [3, 4.0], [2, 0.2]]
      allow(set).to receive(:get).and_return(get_result)

      set.update!

      expect(RedBlocks.client.zrange(set.key, 0, -1)).to eq([RedBlocks.config.blank_id, 2, 1, 3].map(&:to_s))
    end

    it 'doens\'t expires before expiration time' do
      get_result = [1,2,3]
      allow(set).to receive(:get).and_return(get_result)

      set.update!
      expect(set.disabled?).to eq(false)
    end

    # xit 'expires after expiration time' do
    #   get_result = [1,2,3]
    #   allow(set).to receive(:get).and_return(get_result)

    #   set.update!
    #   sleep 20 # 15 + some time.
    #   expect(set.disabled?).to eq(true)
    # end

    it 'updates only the difference'
  end

  describe '#update_if_disabled!' do
    it 'updates if disabled' do
      allow(set).to receive(:disabled?).and_return(true)
      expect(set).to receive(:update!)
      set.update_if_disabled!
    end

    it 'doesn\'t updates if not disabled' do
      allow(set).to receive(:disabled?).and_return(false)
      expect(set).not_to receive(:update!)
      set.update_if_disabled!
    end
  end

  describe '#disabled?' do
    it 'returns true if the time to live is smaller than intermediate lifetime' do
      allow(RedBlocks.client).to receive(:ttl).and_return(RedBlocks.config.intermediate_set_lifetime - 1)
      expect(set.disabled?).to eq(true)
    end

    it 'returns false if the time to live is grater than intermediate lifetime' do
      allow(RedBlocks.client).to receive(:ttl).and_return(RedBlocks.config.intermediate_set_lifetime + 1)
      expect(set.disabled?).to eq(false)
    end
  end

  describe '#cache_time' do
    it 'doesn\'t cache by default' do
      expect(set.cache_time).to eq(RedBlocks::CachePolicy.none)
    end
  end

  describe '#expiration_time' do
    it 'adds intermediate sets life time' do
      expect(set.expiration_time).to eq(RedBlocks.config.intermediate_set_lifetime)
    end
  end

  describe '#ids' do
    let(:get_result) {
      [[1, 0.5] , [3, 4.0], [2, 0.2]]
    }
    before do
      allow(set).to receive(:get).and_return(get_result)
    end

    it 'updates if instructed' do
      expect(set).to receive(:update_if_disabled!)
      set.ids(update_if_disabled: true)
    end

    it 'returns ids' do
      expect(set.ids).to eq([3, 1, 2])
    end

    it 'returns ids with scores if instructed' do
      sorted_get_result = get_result.sort_by(&:last).reverse
      expect(set.ids(with_scores: true)).to eq(sorted_get_result)
    end

    it 'paginates' do
      paginator = double(:paginator)
      allow(paginator).to receive(:head).and_return(1)
      allow(paginator).to receive(:tail).and_return(2)

      expect(set.ids(paginator: paginator)).to eq([1, 2])
    end
  end

  describe '#size' do
    it 'updates if instructed' do
      expect(set).to receive(:update_if_disabled!)
      set.size(update_if_disabled: true)
    end

    it 'returns size' do
      allow(set).to receive(:get).and_return([1, 2, 3])
      expect(set.size).to eq(3)
    end
  end

  describe '#key'

  describe '#weight'
end
