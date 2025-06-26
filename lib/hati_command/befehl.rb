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
      # @module namespace as alias
      ERR = HatiCommand::Errors

      # Configures a command block with specific settings
      # @yield [void] The configuration block
      # @return [Hash] The command configuration
      # @example
      #   command do
      #     failure :my_failure_handler
      #     fail_fast true
      #   end
      def command(&block)
        instance_eval(&block) if block_given?
      end

      # @return [Hash] The current command configuration settings
      def command_config
        __command_config
      end

      # Sets the result inference behavior for the command.
      # @param value [Boolean] Indicates whether to enable result inference.
      # @return [void]
      def result_inference(value)
        command_config[:result_inference] = value
      end

      # Sets the failure handler for the command
      # @param value [Symbol, Proc] The failure handler to be used
      # @return [void]
      def failure(value)
        command_config[:failure] = value
      end

      # Sets the fail-fast behavior for the command
      # @param value [Boolean] Whether to enable fail-fast behavior
      # @return [void]
      def fail_fast(value)
        command_config[:fail_fast] = value
      end

      # Sets the unexpected error handler for the command
      # @param value [Symbol, Proc, Boolean] The error handler to be used
      # @return [void]
      def unexpected_err(value)
        command_config[:unexpected_err] = value
      end

      # This method checks if a caller method has been set; if not, it defaults to `:call`.
      # @return [Symbol] The name of the method to call.
      def call_as(value = :call)
        command_config[:call_as] = value

        singleton_class.send(:alias_method, value, :call)
      end

      # WIP: experimental
      # TODO: set of methods
      def ar_transaction(*cmd_methods, returnable: true)
        has_ar_defined = defined?(ActiveRecord::Base) && ActiveRecord::Base.respond_to?(:transaction)
        raise ERR::ConfigurationError, 'No ActiveRecord defined' unless has_ar_defined

        has_valid_mthds = cmd_methods.any? { |value| value.is_a?(Symbol) }
        raise ERR::ConfigurationError, 'Invalid types. Accepts Array[Symbol]' unless has_valid_mthds

        command_config[:ar_transaction] = {
          methods: cmd_methods,
          returnable: returnable
        }

        dynamic_module = Module.new do
          cmd_methods.each do |method_name|
            define_method(method_name) do |*args, **kwargs, &block|
              rez = ActiveRecord::Base.transaction do
                result = super(*args, **kwargs, &block)

                # Rollbacks to prevent partial transaction state
                if returnable && !result.is_a?(HatiCommand::Result)
                  raise ERR::ConfigurationError, 'This command configuration requires explicit return from transaction'
                end

                # Allows explicit partial commit
                if result.failure?
                  raise ERR::TransactionError.new('Transaction brake has been triggered', failure_obj: result.value)
                end

                result
              end

              rez
            rescue ERR::TransactionError => e
              # TODO: process trace corectly (line of code)
              HatiCommand::Failure.new(e.failure_obj, err: e.message, trace: e.backtrace&.first)
            # Every other error including FailFast goes to main caller method
            rescue ActiveRecord::ActiveRecordError => e
              # TODO: process trace
              HatiCommand::Failure.new(e, err: e.message, trace: e.backtrace&.first)
            end
          end
        end

        prepend dynamic_module
      end

      # Executes the command with the given arguments.
      #
      # This method creates a new instance of the command class, yields it to an optional block,
      # and then calls the instance method with the provided arguments. It handles the result
      # of the command execution, returning a success or failure result based on the outcome.
      #
      # @param args [Array] Arguments to be passed to the instance method.
      # @yield [Object] Optional block that yields the new instance for additional configuration.
      # @return [HatiCommand::Result, Object] The result of the command, wrapped in a Result object if applicable.
      # @raise [HatiCommand::Errors::FailFastError] If a fail-fast condition is triggered.
      # @raise [StandardError] If an unexpected error occurs and no handler is configured.
      def call(*args, __command_reciever: nil, **kwargs, &block)
        result = caller_result(*args, __command_reciever: __command_reciever, **kwargs, &block)

        return result unless command_config[:result_inference]
        return result if result.is_a?(HatiCommand::Result)

        HatiCommand::Success.new(result)
      rescue ERR::FailFastError => e
        handle_fail_fast_error(e)
      rescue StandardError => e
        handle_standard_error(e)
      end

      # TODO: think on opts to hide reciever
      def caller_result(*args, __command_reciever: nil, **kwargs, &block)
        # expecting pre-configured reciever if given
        if __command_reciever
          obj = __command_reciever
        else
          obj = new
          yield(obj) if !obj && block_given?
        end

        # TODO: add error if no instance method to call
        obj.send(command_config[:call_as] || :call, *args, **kwargs, &block)
      end

      module_function

      # @return [Hash] The current command configuration settings
      # @api private
      def __command_config
        @__command_config ||= {}
      end

      # Handles fail-fast errors during command execution
      # @param error [HatiCommand::Errors::FailFastError] The fail-fast error to handle
      # @return [HatiCommand::Failure] A failure object containing error details
      # @api private
      def handle_fail_fast_error(error)
        failure_obj = error.failure_obj
        return HatiCommand::Failure.new(error, trace: error.backtrace.first) unless failure_obj

        failure_obj.tap { |err| err.trace = error.backtrace[1] }
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

      def execute_with_transaction_handling?
        has_ar_defined = defined?(ActiveRecord::Base) && ActiveRecord::Base.respond_to?(:transaction)

        !!(command_config.dig(:ar_transaction, :methods) && has_ar_defined)
      end
    end
  end
end
