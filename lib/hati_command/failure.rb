# frozen_string_literal: true

module HatiCommand
  # This class represents a failure result.
  #
  # @example
  #   failure_result = HatiCommand::Failure.new("An error occurred")
  #   failure_result.failure # => "An error occurred"
  #   failure_result.failure? # => true
  #   failure_result.success # => nil
  #   failure_result.success? # => false
  class Failure < Result
    # Returns the value associated with the failure.
    #
    # @return [Object] the value of the failure
    def failure
      value
    end

    # Indicates whether the result is a failure.
    #
    # @return [Boolean] true if this is a failure, false otherwise
    def failure?
      true
    end

    # Returns nil as there is no success value in a failure.
    #
    # @return [nil]
    def success
      nil
    end

    # Indicates whether the result is a success.
    #
    # @return [Boolean] false since this is a failure
    def success?
      false
    end

    def to_sym
      :failure
    end
  end
end
