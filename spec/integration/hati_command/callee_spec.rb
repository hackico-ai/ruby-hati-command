# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HatiCommand::Callee do
  context 'when run command' do
    before do
      stub_const('DummyCallee', Class.new do
        include HatiCommand::Callee
  
        def call(rez)
          HatiCommand::Success.new(rez)
        end
      end)
    end
  
    let(:callee_klass) { DummyCallee }

    describe '.call' do
      let(:result) { callee_klass.call('Success!') }

      it 'returns success' do
        expect(result.value).to eq('Success!')
      end
    end
  end

  context 'when call is configured' do
    before do
      stub_const('DummyExecutee', Class.new do
        include HatiCommand::Callee

        call_as :execute

        def execute(rez)
          HatiCommand::Success.new(rez)
        end
      end)
    end

    let(:callee_klass) { DummyExecutee }

    describe '.execute' do
      let(:result) { DummyExecutee.execute('Success!') }

      it 'returns success' do
        expect(result.value).to eq('Success!')
      end
    end
  end
end
