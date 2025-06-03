# frozen_string_literal: true

# @module HatiCommand
# Provides command handling functionalities for creating and managing commands.
# This module serves as the main namespace for all command-related operations.
module HatiCommand
  # @module Befehl
  # Core module for command handling that provides the base functionality for creating commands.
  # This module is designed to be extended by classes that need command handling capabilities.
  module Befehl
    # Extends the base class with command handling functionality
    # @param base [Class] the class that is extending this module
    # @return [void]
    def self.extended(base)
      base.extend(BefehlClassMethods)
      def base.inherited(subclass)
        super
        subclass.instance_variable_set(:@__command_config, @__command_config.dup)
      end
    end

    # @module BefehlClassMethods
    # Provides class methods for command configuration and execution.
    # These methods are automatically added to any class that extends Befehl.
    module BefehlClassMethods
      # Configures a command block with specific settings
      # @yield [void] The configuration block
      # @return [Hash] The command configuration
      # @example
      #   command do
      #     failure :my_failure_handler
      #     fail_fast true
      #   end
      def command(&block)
        @__command_config ||= {}
        instance_eval(&block) if block_given?
      end

      # Retrieves the current command configuration
      # @return [Hash] The current command configuration settings
      def command_config
        @__command_config
      end

      def result_inference(value)
        @__command_config[:result_inference] = value
      end

      # Sets the failure handler for the command
      # @param value [Symbol, Proc] The failure handler to be used
      # @return [void]
      def failure(value)
        @__command_config[:failure] = value
      end

      # Sets the fail-fast behavior for the command
      # @param value [Boolean] Whether to enable fail-fast behavior
      # @return [void]
      def fail_fast(value)
        @__command_config[:fail_fast] = value
      end

      # Sets the unexpected error handler for the command
      # @param value [Symbol, Proc, Boolean] The error handler to be used
      # @return [void]
      def unexpected_err(value)
        @__command_config[:unexpected_err] = value
      end

      # Executes the command with the given arguments
      # @param args [Array] Arguments to be passed to the instance method
      # @yield [Object] Optional block that yields the new instance
      # @return [Object] The result of the command execution
      # @raise [StandardError] If an unexpected error occurs and no handler is configured
      def call(...)
        obj = new
        yield(obj) if block_given?

        result = obj.call(...)
        return result unless result_inference
        return result if result.is_a?(HatiCommand::Result)

        Success(result)
      rescue HatiCommand::Errors::FailFastError => e
        handle_fail_fast_error(e)
      rescue StandardError => e
        handle_standard_error(e)
      end

      module_function

      # Handles fail-fast errors during command execution
      # @param error [HatiCommand::Errors::FailFastError] The fail-fast error to handle
      # @return [HatiCommand::Failure] A failure object containing error details
      # @api private
      def handle_fail_fast_error(error)
        err_obj = error.err_obj
        return HatiCommand::Failure.new(error, trace: error.backtrace.first) unless err_obj

        err_obj.tap { |err| err.trace = error.backtrace[1] }
      end

      # Handles standard errors during command execution
      # @param error [StandardError] The error to handle
      # @return [HatiCommand::Failure] A failure object containing error details
      # @raise [StandardError] If no unexpected error handler is configured
      # @api private
      def handle_standard_error(error)
        internal_err = command_config[:unexpected_err]
        raise error unless internal_err

        err = internal_err.is_a?(TrueClass) ? error : internal_err
        HatiCommand::Failure.new(error, err: err, trace: error.backtrace.first)
      end
    end
  end
end
