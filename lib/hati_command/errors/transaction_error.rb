# frozen_string_literal: true

module HatiCommand
  module Errors
    # Custom error class for Transaction issue scenarios in HatiCommand
    class TransactionError < BaseError
      def default_message
        'Transaction Error has been triggerd'
      end
    end
  end
end
