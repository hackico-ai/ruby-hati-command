# frozen_string_literal: true

module HatiCommand
  module Errors
    # Custom error class for FailFast scenario in HatiCommand
    class FailFastError < BaseError
      def default_message
        'Halt Execution'
      end
    end
  end
end
