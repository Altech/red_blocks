require "spec_helper"

describe RedBlocks::InstantSet do
  describe '#get' do
    context 'when value is ids' do
      let(:value) { [1,2,3,4,5] }

      it 'return value' do
        expect(RedBlocks::InstantSet.new(value).get).to eq value
      end
    end

    context 'when value is id_with_scores' do
      let(:value) { [[1, 1], [2,2]] }

      it 'return value' do
        expect(RedBlocks::InstantSet.new(value).get).to eq value
      end
    end
  end

  describe '#key_suffix' do
    context 'when value is ids' do
      let(:instant_set1) { RedBlocks::InstantSet.new([1,2,3]) }
      let(:instant_set2) { RedBlocks::InstantSet.new([1,2,3,4]) }

      it 'return value' do
        expect(instant_set1.key_suffix).not_to eq instant_set2.key_suffix
      end
    end

    context 'when value is id_with_scores' do
      let(:value) { [[1, 1], [2, 2], [3, 3]] }
      let(:instant_set1) { RedBlocks::InstantSet.new([[1, 1], [2, 2], [3, 3]]) }
      let(:instant_set2) { RedBlocks::InstantSet.new([[1, 0], [2, 2], [3, 3]]) }

      it 'return value' do
        expect(instant_set1.key_suffix).not_to eq instant_set2.key_suffix
      end
    end
  end
end
