# frozen_string_literal: true

# @module HatiCommand
# Provides command handling functionalities and result objects.
module HatiCommand
  # @class Failure
  # Represents a failure result in the Result pattern.
  # This class is used to wrap failure values and provide a consistent interface
  # for handling both successful and failed operations.
  #
  # The Failure class is part of the Result pattern implementation, working alongside
  # the Success class to provide a type-safe way to handle operation outcomes.
  #
  # @example Basic usage
  #   failure = HatiCommand::Failure.new("Operation failed")
  #   failure.failure?  # => true
  #   failure.success?  # => false
  #
  # @example With error and metadata
  #   error = StandardError.new("Database connection failed")
  #   failure = HatiCommand::Failure.new(
  #     "Could not save record",
  #     err: error,
  #     meta: { attempted_at: Time.now }
  #   )
  #
  # @example Pattern matching
  #   case result
  #   when HatiCommand::Failure
  #     handle_error(result.failure)
  #   end
  #
  # @see HatiCommand::Success
  # @see HatiCommand::Result
  class Failure < Result
    # Returns the failure value wrapped by this Failure instance.
    # This method provides access to the actual error value or message
    # that describes why the operation failed.
    #
    # @return [Object] The wrapped failure value
    # @example
    #   failure = Failure.new("Database error")
    #   failure.failure  # => "Database error"
    def failure
      value
    end

    # Indicates that this is a failure result.
    # This method is part of the Result pattern interface and always
    # returns true for Failure instances.
    #
    # @return [Boolean] Always returns true
    # @example
    #   failure = Failure.new("Error")
    #   failure.failure?  # => true
    def failure?
      true
    end

    # Returns nil since a Failure has no success value.
    # This method is part of the Result pattern interface and always
    # returns nil for Failure instances.
    #
    # @return [nil] Always returns nil
    # @example
    #   failure = Failure.new("Error")
    #   failure.success  # => nil
    def success
      nil
    end

    # Indicates that this is not a success result.
    # This method is part of the Result pattern interface and always
    # returns false for Failure instances.
    #
    # @return [Boolean] Always returns false
    # @example
    #   failure = Failure.new("Error")
    #   failure.success?  # => false
    def success?
      false
    end

    # Returns the symbolic representation of this result type.
    # Useful for pattern matching and result type checking.
    #
    # @return [Symbol] Always returns :failure
    # @api public
    # @example
    #   failure = Failure.new("Error")
    #   failure.to_sym  # => :failure
    def to_sym
      :failure
    end
  end
end
