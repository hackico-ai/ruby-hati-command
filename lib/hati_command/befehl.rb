# frozen_string_literal: true

require_relative '../hati_command'

# HatiCommand module provides command handling functionalities.
module HatiCommand
  # ClassMethods module provides class methods for the Befehl module.
  module Befehl
    # @param args [Array] arguments to be passed to the instance method
    # @return [Object] the result of the instance method call

    class << self
      attr_reader :command_config

      def call(...)
        obj = new
        yield(obj) if block_given?
        obj.call(...)
      rescue HatiCommand::Errors::FailFastError => e
        handle_fail_fast_error(e)
      rescue StandardError => e
        handle_standard_error(e)
      end

      def handle_fail_fast_error(error)
        error.err_obj.tap { |err| err.trace = error.backtrace[1] }
      end

      def handle_standard_error(error)
        internal_err = command_config[:unexpected_err]
        raise error unless internal_err

        err = internal_err.is_a?(TrueClass) ? error : internal_err
        HatiCommand::Failure.new(error, err: err, trace: error.backtrace.first)
      end

      def command(&block)
        @command_config ||= {}
        instance_eval(&block) if block_given?
      end

      def failure(value)
        @command_config[:failure] = value
      end

      def fail_fast(value)
        @command_config[:fail_fast] = value
      end

      def unexpected_err(value)
        @command_config[:unexpected_err] = value
      end
    end

    private_class_method :handle_fail_fast_error, :handle_standard_error
  end
end
