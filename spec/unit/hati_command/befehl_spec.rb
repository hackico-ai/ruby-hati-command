# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HatiCommand::Befehl do
  describe 'command configurations' do
    before do
      stub_const('BefehlClass', Class.new do
        extend HatiCommand::Befehl::BefehlClassMethods

        command do
          call_as :execute
          fail_fast 'Befehl Fail Fast Message'
          failure 'Befehl Failure Message'
          unexpected_err 'Befehl Unexpected Error'
          result_inference true
        end
      end)
    end

    let(:befehl_klass) { BefehlClass }
    let(:configs) { befehl_klass.command_config }

    describe '.fail_fast' do
      it 'sets the fail_fast config' do
        expect(befehl_klass.command_config[:fail_fast]).to eq('Befehl Fail Fast Message')
      end
    end

    describe '.unexpected_err' do
      it 'sets the unexpected_err config' do
        expect(befehl_klass.command_config[:unexpected_err]).to eq('Befehl Unexpected Error')
      end
    end

    describe '.failure' do
      it 'sets the failure config' do
        expect(befehl_klass.command_config[:failure]).to eq('Befehl Failure Message')
      end
    end

    describe '.result_inference' do
      it 'sets the result_inference config' do
        expect(befehl_klass.command_config[:result_inference]).to be(true)
      end
    end

    describe '.command_config' do
      it 'returns the configurations' do
        aggregate_failures 'of command options' do
          expect(configs[:fail_fast]).to eq('Befehl Fail Fast Message')
          expect(configs[:failure]).to eq('Befehl Failure Message')
          expect(configs[:unexpected_err]).to eq('Befehl Unexpected Error')
          expect(configs[:result_inference]).to be(true)
          expect(configs[:call_as]).to be(:execute)
        end
      end
    end
  end
end
