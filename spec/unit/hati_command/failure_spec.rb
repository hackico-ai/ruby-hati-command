# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HatiCommand::Failure do
  subject(:failure_instance) { described_class.new(value) }

  let(:value) { 'error_value' }

  describe '#initialize' do
    it { is_expected.to have_attributes(value: value) }
  end

  describe '#failure' do
    it { expect(failure_instance.failure).to eq(value) }
  end

  describe '#failure?' do
    it { is_expected.to be_failure }
  end

  describe '#success' do
    it { expect(failure_instance.success).to be_nil }
  end

  describe '#success?' do
    it { expect(failure_instance.success?).to be false }
  end
end
