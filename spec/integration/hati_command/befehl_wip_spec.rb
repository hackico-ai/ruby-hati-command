# frozen_string_literal: true

require 'spec_helper'
require 'active_record'
# require_relative 'support/active_record'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

ActiveRecord::Schema.define do
  create_table :widgets, force: true do |t|
    t.string :name
    t.timestamps
  end
end

class Widget < ActiveRecord::Base; end

RSpec.describe HatiCommand::Befehl do
  let(:befehl_klass) { support_dummy_befehl('DummyBefehl') }

  describe 'ActiveRecord transaction wrapping' do
    before do
      stub_const(
        'MyDummyExecBefehl',
        Class.new(befehl_klass) do
          command do
            ar_transaction :call
          end

          def call(message)
            raise ActiveRecord::Rollback if message == 'fail'

            Widget.create!(name: message)
            HatiCommand::Success.new(message)
          end
        end
      )
    end

    it 'commits the transaction on success' do
      expect { MyDummyExecBefehl.call('Widget1') }.to change { Widget.count }.by(1)
    end

    it 'rolls back the transaction on failure' do
      expect do
        MyDummyExecBefehl.call('fail')
      rescue StandardError
        nil
      end.not_to(change { Widget.count })
    end
  end
end
