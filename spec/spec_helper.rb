# frozen_string_literal: true

require 'bundler/setup'
require 'hati_command'

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  Dir[File.join('./spec/support/**/*.rb')].each { |f| require f }
  config.include Dummy
end
