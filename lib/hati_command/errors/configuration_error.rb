# frozen_string_literal: true

module HatiCommand
  module Errors
    # Custom error class for configuration issues scenarios in HatiCommand
    class ConfigurationError < BaseError
      def default_message
        'Invalid configurations'
      end
    end
  end
end
