# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HatiCommand::Errors::FailFastError do
  subject(:errors_klass) { described_class }

  describe '#initialize' do
    context 'when only a message is provided' do
      subject(:error) { errors_klass.new(error_message) }

      let(:error_message) { 'Test error message' }

      it 'sets the error message' do
        expect(error.message).to eq(error_message)
      end

      it 'sets err_obj to nil' do
        expect(error.err_obj).to be_nil
      end
    end

    context 'when both message and err_obj are provided' do
      subject(:error) { errors_klass.new(error_message, err_obj: original_error) }

      let(:error_message) { 'Test error message' }
      let(:original_error) { StandardError.new('Original error') }

      it 'sets the error message' do
        expect(error.message).to eq(error_message)
      end

      it 'sets the err_obj' do
        expect(error.err_obj).to eq(original_error)
      end
    end
  end

  describe '#err_obj' do
    it 'is readable' do
      error = errors_klass.new('Test')

      expect(error).to respond_to(:err_obj)
    end
  end
end
