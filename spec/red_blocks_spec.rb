require "spec_helper"

describe RedBlocks do
  it "has a version number" do
    expect(RedBlocks::VERSION).not_to be nil
  end

  it 'has a config' do
    expect(RedBlocks.config).to be_a(RedBlocks::Config)
  end

  it 'returns mocked client' do
    expect(RedBlocks.client).to be_a(MockRedis)
  end
end
