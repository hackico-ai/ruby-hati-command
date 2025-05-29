# frozen_string_literal: true

require 'spec_helper'

# WIP: performance extensions
RSpec.describe HatiCommand::Callee do
  subject(:callee_klass) { described_class }

  let(:whoami) { 'My Name is Callee' }

  describe '.whoami' do
    it 'returns the class name' do
      expect(callee_klass.whoami).to eq(whoami)
    end
  end
end
