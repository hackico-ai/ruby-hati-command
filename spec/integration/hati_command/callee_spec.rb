# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HatiCommand::Callee do
  let(:callee_klass) { support_dummy_calle('DummyCallee') }

  describe '.call' do
    let(:result) { callee_klass.call('Success!') }

    it 'returns success' do
      expect(result.value).to eq('Success!')
    end
  end
end
