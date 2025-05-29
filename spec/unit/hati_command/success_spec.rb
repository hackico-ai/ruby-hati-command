# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HatiCommand::Success do
  subject(:success_instance) { described_class.new(value) }

  let(:value) { 'success_value' }

  describe '#initialize' do
    it { is_expected.to have_attributes(value: value) }
  end

  describe '#result' do
    it { expect(success_instance.result).to eq(success_instance) }
  end

  describe '#success' do
    it { expect(success_instance.success).to eq(value) }
  end

  describe '#success?' do
    it { expect(success_instance.success?).to be true }
  end

  describe '#failure' do
    it { expect(success_instance.failure).to be_nil }
  end

  describe '#failure?' do
    it { expect(success_instance.failure?).to be false }
  end
end
