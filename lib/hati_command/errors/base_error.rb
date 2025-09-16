# frozen_string_literal: true

module HatiCommand
  module Errors
    # Custom BaseError class for command issues scenarios in HatiCommand
    #
    # @example Raising a BaseError with a message
    #   raise HatiCommand::Error::BaseError, "Operation failed"
    class BaseError < StandardError
      DEFAULT_MSG = 'Default message: Oooops! Something went wrong. Please check the logs.'

      attr_reader :failure_obj

      # @param message [String] The error message
      # @param failure_obj [Object] An optional Error || Failure DTO
      def initialize(message = nil, failure_obj: nil)
        msg = build_msg + (message || default_message)
        super(msg)
        @failure_obj = failure_obj
      end

      def error_klass
        self.class.name
      end

      def build_msg
        "[#{error_klass}] "
      end

      def default_message
        DEFAULT_MSG
      end
    end
  end
end
