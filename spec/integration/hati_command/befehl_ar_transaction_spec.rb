# frozen_string_literal: true

require 'spec_helper'
require 'support/active_record'

RSpec.describe HatiCommand::Befehl do
  let(:ar_model) { 'Widget' }
  let(:befehl_klass) { support_dummy_befehl('DummyBefehl') }
  let(:ar_command) { 'MyDummyExecBefehl' }

  describe 'ActiveRecord transaction wrapping' do
    before do
      stub_const(ar_model, Class.new(ActiveRecord::Base))

      stub_const(
        ar_command,
        Class.new(befehl_klass) do
          command { ar_transaction :call }

          def call(message)
            Widget.create!(name: message)
            raise ActiveRecord::Rollback if message == :fail

            HatiCommand::Success.new(message)
          end
        end
      )
    end

    it 'commits the transaction on success' do
      expect { MyDummyExecBefehl.call('Widget1') }.to change(Widget, :count).by(1)
    end

    it 'rolls back the transaction on failure' do
      expect do
        MyDummyExecBefehl.call(:fail)
      rescue StandardError
        nil
      end.not_to change(Widget, :count)
    end
  end
end
