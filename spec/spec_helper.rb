# frozen_string_literal: true

require 'bundler/setup'
require 'hati_command'

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # performance
  exclude_support_files = ['active_record']

  Dir[File.join('./spec/support/**/*.rb')].each do |support_file|
    next if exclude_support_files.include?(support_file)

    require support_file
  end

  config.include Dummy
end
