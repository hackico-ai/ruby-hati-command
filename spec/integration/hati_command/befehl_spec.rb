# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HatiCommand::Befehl do
  let(:befehl_klass) { support_dummy_befehl('DummyBefehl') }

  before do
    stub_const(
      'MyDummyBefehl',
      Class.new(befehl_klass) do
        command do
          fail_fast 'Default Fail Fast message provided'
          unexpected_err true
          result_inference true
        end

        def call(message, fail_fast: false, unexpected_err: false, result_inference: false)
          raise HatiCommand::Errors::FailFastError.new('Fail Fast Triggered') if fail_fast # rubocop:disable Style/RaiseArgs
          raise StandardError if unexpected_err

          result_inference ? message : HatiCommand::Success.new(message)
        end
      end
    )
  end

  describe '.call' do
    let(:result) { MyDummyBefehl.call('Success!') }

    it 'returns success' do
      aggregate_failures 'result' do
        expect(result).to be_a(HatiCommand::Success)
        expect(result.value).to eq('Success!')
        expect(result.error).to be_nil
      end
    end

    context 'when fail_fast is true' do
      let(:result) { MyDummyBefehl.call('This is a fail fast message', fail_fast: true) }

      it 'returns failure' do
        aggregate_failures 'result' do
          expect(result).to be_a(HatiCommand::Failure)
          expect(result.value).to be_a(HatiCommand::Errors::FailFastError)
        end
      end
    end

    context 'when unexpected_err is true' do
      let(:result) { MyDummyBefehl.call('This is a unexpected error message', unexpected_err: true) }

      it 'returns failure' do
        aggregate_failures 'result' do
          expect(result).to be_a(HatiCommand::Failure)
          expect(result.error).to be_a(StandardError)
        end
      end
    end

    context 'when result_inference is true' do
      let(:result) { MyDummyBefehl.call('This is a result inference message', result_inference: true) }

      it 'returns success' do
        expect(result).to be_a(HatiCommand::Success)
      end
    end
  end

  describe 'call configuration' do
    before do
      stub_const(
        'MyDummyExecBefehl',
        Class.new(befehl_klass) do
          command do
            call_as :execute
          end

          def execute(message)
            HatiCommand::Success.new(message)
          end
        end
      )
    end

    describe '.execute' do
      let(:rez_msg) { 'This is a result inference message' }
      let(:result) { MyDummyExecBefehl.execute(rez_msg) }

      it 'returns success' do
        aggregate_failures do
          expect(result).to be_a(HatiCommand::Success)
          expect(result.value).to eq(rez_msg)
        end
      end
    end
  end
end
