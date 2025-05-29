# frozen_string_literal: true

# @module HatiCommand
# Provides command handling functionalities and result objects.
module HatiCommand
  # @class Success
  # Represents a successful result in the Result pattern.
  # This class is used to wrap successful operation values and provide a consistent interface
  # for handling both successful and failed operations.
  #
  # The Success class is part of the Result pattern implementation, working alongside
  # the Failure class to provide a type-safe way to handle operation outcomes.
  #
  # @example Basic usage
  #   success = HatiCommand::Success.new("Operation completed")
  #   success.success?  # => true
  #   success.failure?  # => false
  #
  # @example With metadata
  #   success = HatiCommand::Success.new(
  #     { id: 123, name: "Example" },
  #     meta: { duration_ms: 50 }
  #   )
  #   success.success  # => { id: 123, name: "Example" }
  #
  # @example Pattern matching
  #   case result
  #   when HatiCommand::Success
  #     process_data(result.success)
  #   end
  #
  # @see HatiCommand::Failure
  # @see HatiCommand::Result
  class Success < Result
    # Returns the success value wrapped by this Success instance.
    # This method provides access to the actual value or result
    # that was produced by the successful operation.
    #
    # @return [Object] The wrapped success value
    # @example
    #   success = Success.new("Operation output")
    #   success.success  # => "Operation output"
    def success
      value
    end

    # Indicates that this is a success result.
    # This method is part of the Result pattern interface and always
    # returns true for Success instances.
    #
    # @return [Boolean] Always returns true
    # @example
    #   success = Success.new("Result")
    #   success.success?  # => true
    def success?
      true
    end

    # Returns nil since a Success has no failure value.
    # This method is part of the Result pattern interface and always
    # returns nil for Success instances.
    #
    # @return [nil] Always returns nil
    # @example
    #   success = Success.new("Result")
    #   success.failure  # => nil
    def failure
      nil
    end

    # Indicates that this is not a failure result.
    # This method is part of the Result pattern interface and always
    # returns false for Success instances.
    #
    # @return [Boolean] Always returns false
    # @example
    #   success = Success.new("Result")
    #   success.failure?  # => false
    def failure?
      false
    end

    # Returns the symbolic representation of this result type.
    # Useful for pattern matching and result type checking.
    #
    # @return [Symbol] Always returns :success
    # @api public
    # @example
    #   success = Success.new("Result")
    #   success.to_sym  # => :success
    def to_sym
      :success
    end
  end
end
