# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HatiCommand::Errors::TransactionError do
  subject(:error_klass) { described_class }

  it 'inherits from BaseError' do
    expect(error_klass).to be < HatiCommand::Errors::BaseError
  end

  it 'has the correct default message' do
    error = error_klass.new

    expect(error.message).to eq("[#{error_klass}] #{error.default_message}")
  end
end
