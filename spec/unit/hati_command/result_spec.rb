# frozen_string_literal: true

require 'rspec'

RSpec.describe HatiCommand::Result do
  let(:value) { 'test_value' }

  describe '#initialize' do
    it { expect(described_class.new(value).value).to eq(value) }
  end

  describe '#result' do
    it 'returns result object' do
      result = described_class.new(value)

      expect(result.result).to eq(result)
    end
  end

  describe '#error' do
    it 'returns error' do
      result = described_class.new(value, err: 'test_message')

      expect(result.error).to eq('test_message')
    end
  end

  describe '#meta' do
    it 'returns meta' do
      result = described_class.new(value, meta: { 'test_meta' => 'test_value' })

      expect(result.meta).to eq({ 'test_meta' => 'test_value' })
    end
  end
end
