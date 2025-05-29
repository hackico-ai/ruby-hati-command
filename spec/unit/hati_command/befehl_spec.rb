# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HatiCommand::Befehl do
  before do
    stub_const('BefehlClass', Class.new do
      extend HatiCommand::Befehl::BefehlClassMethods

      command do
        fail_fast 'Befehl Fail Fast Message'
        failure   'Befehl Failure Message'
        unexpected_err 'Befehl Unexpected Error'
      end
    end)
  end

  let(:befehl_klass) { BefehlClass }

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

  describe '.command_config' do
    it 'returns the command config' do
      expect(befehl_klass.command_config).to eq(
        fail_fast: 'Befehl Fail Fast Message',
        failure: 'Befehl Failure Message',
        unexpected_err: 'Befehl Unexpected Error'
      )
    end
  end
end
