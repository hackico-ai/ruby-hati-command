# frozen_string_literal: true

require 'spec_helper'

# WIP: performance extensions
RSpec.describe HatiCommand::Cmd do
  subject(:cmd_klass) { described_class }

  let(:whoami) { 'My Name is Cmd' }

  describe '.whoami' do
    it 'returns the class name' do
      expect(cmd_klass.whoami).to eq(whoami)
    end
  end
end
