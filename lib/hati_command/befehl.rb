# frozen_string_literal: true

# HatiCommand module provides command handling functionalities.
module HatiCommand
  # Core module for command handling.
  module Befehl
    def self.extended(base)
      base.extend(BefehlClassMethods)
      def base.inherited(subclass)
        super
        subclass.instance_variable_set(:@__command_config, @__command_config.dup)
      end
    end

    # BefehlClassMethods module provides class methods for command handling.
    module BefehlClassMethods
      def command(&block)
        @__command_config ||= {}
        instance_eval(&block) if block_given?
      end

      def command_config
        @__command_config
      end

      def failure(value)
        @__command_config[:failure] = value
      end

      def fail_fast(value)
        @__command_config[:fail_fast] = value
      end

      def unexpected_err(value)
        @__command_config[:unexpected_err] = value
      end

      # @param args [Array] arguments to be passed to the instance method
      # @return [Object] the result of the instance method call
      def call(...)
        obj = new
        yield(obj) if block_given?
        obj.call(...)
      rescue HatiCommand::Errors::FailFastError => e
        handle_fail_fast_error(e)
      rescue StandardError => e
        handle_standard_error(e)
      end

      module_function

      def handle_fail_fast_error(error)
        err_obj = error.err_obj
        return HatiCommand::Failure.new(error, trace: error.backtrace.first) unless err_obj

        err_obj.tap { |err| err.trace = error.backtrace[1] }
      end

      def handle_standard_error(error)
        internal_err = command_config[:unexpected_err]
        raise error unless internal_err

        err = internal_err.is_a?(TrueClass) ? error : internal_err
        HatiCommand::Failure.new(error, err: err, trace: error.backtrace.first)
      end
    end
  end
end
