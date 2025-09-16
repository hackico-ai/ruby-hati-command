# frozen_string_literal: true

require 'active_record'

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
