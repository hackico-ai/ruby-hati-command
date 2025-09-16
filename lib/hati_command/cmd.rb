# frozen_string_literal: true

# @module HatiCommand
# Provides command handling functionalities with a focus on Railway-oriented programming.
# This module implements the Railway pattern for better error handling and command flow control.
module HatiCommand
  # @module Cmd
  # Dev-friendly extension of the Befehl core module with Railway track API.
  # This module provides a Railway-oriented programming interface for handling success and failure states
  # in a functional way, making it easier to chain operations and handle errors gracefully.
  #
  # @example
  #   class MyCommand
  #     include HatiCommand::Cmd
  #
  #     def call(input)
  #       if valid?(input)
  #         Success(input)
  #       else
  #         Failure("Invalid input")
  #       end
  #     end
  #   end
  module Cmd
    # Includes the module in the base class and sets up necessary configurations
    # @param base [Class] The class including this module
    # @return [void]
    def self.included(base)
      base.extend(HatiCommand::Befehl)
      base.private_class_method :new
    end

    # Returns the identity of the module
    # @note This is a work in progress method
    # @return [String] The module's identity string
    # @api public
    def self.whoami
      'My Name is Cmd'
    end

    # Creates a Success monad representing a successful operation
    # @param value [Object, nil] The value to wrap in the Success monad
    # @param err [Object, nil] Optional error object
    # @param meta [Hash] Additional metadata for the success state
    # @return [HatiCommand::Success] A Success monad containing the result
    # @example
    #   Success("Operation completed", meta: { time: Time.now })
    def Success(value = nil, err: nil, meta: {}) # rubocop:disable Naming/MethodName
      HatiCommand::Success.new(value, err: err, meta: meta)
    end

    # Creates a Failure monad representing a failed operation
    # @param value [Object, nil] The value to wrap in the Failure monad
    # @param err [Object, nil] Optional error object (falls back to configured default)
    # @param meta [Hash] Additional metadata for the failure state
    # @return [HatiCommand::Failure] A Failure monad containing the error details
    # @example
    #   Failure("Operation failed", err: StandardError.new, meta: { reason: "invalid_input" })
    def Failure(value = nil, err: nil, meta: {}) # rubocop:disable Naming/MethodName
      default_err = self.class.command_config[:failure]
      HatiCommand::Failure.new(value, err: err || default_err, meta: meta)
    end

    # Creates a Failure monad and immediately raises a FailFastError
    # @param value [Object, nil] The value to wrap in the Failure monad
    # @param err [Object, nil] Optional error object (falls back to configured defaults)
    # @param meta [Hash] Additional metadata for the failure state
    # @param _opts [Hash] Additional options (currently unused)
    # @raise [HatiCommand::Errors::FailFastError] Always raises with the created Failure monad
    # @example
    #   Failure!("Critical error", err: FatalError.new)
    def Failure!(value = nil, err: nil, meta: {}, **_opts) # rubocop:disable Naming/MethodName
      default_error = self.class.command_config[:fail_fast] || self.class.command_config[:failure]
      error = err || default_error

      failure_obj = HatiCommand::Failure.new(value, err: error, meta: meta)
      raise HatiCommand::Errors::FailFastError.new('Fail Fast Triggered', failure_obj: failure_obj)
    end
  end
end
