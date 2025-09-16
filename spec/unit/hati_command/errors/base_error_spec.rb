# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HatiCommand::Errors::BaseError do
  subject(:error_klass) { described_class }

  describe '#initialize' do
    it 'initializes with a message' do
      error = error_klass.new('Operation failed')

      expect(error.message).to eq("[#{error_klass}] Operation failed")
    end

    it 'initializes with a failure object' do
      failure_obj = StandardError.new('Booom!')
      error = error_klass.new('Operation failed', failure_obj: failure_obj)

      expect(error.instance_variable_get(:@failure_obj)).to eq(failure_obj)
    end

    it 'uses the default message if no message is provided' do
      error = error_klass.new

      expect(error.message).to eq("[#{error_klass}] #{error_klass::DEFAULT_MSG}")
    end
  end

  describe '#error_klass' do
    it 'returns the class name' do
      error = error_klass.new

      expect(error.error_klass).to eq(error_klass.name)
    end
  end

  describe '#build_msg' do
    it 'builds the message correctly' do
      error = error_klass.new('Test message')

      expect(error.build_msg).to eq("[#{error_klass}] ")
    end
  end
end
