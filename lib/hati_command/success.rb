# frozen_string_literal: true

module HatiCommand
  # This class represents a successful result.
  #
  # @example
  #   success_result = HatiCommand::Success.new("Operation completed successfully")
  #   success_result.success # => "Operation completed successfully"
  #   success_result.success? # => true
  #   success_result.failure # => nil
  #   success_result.failure? # => false
  class Success < Result
    # Returns the value associated with the success.
    #
    # @return [Object] the value of the success
    def success
      value
    end

    # Indicates whether the result is a success.
    #
    # @return [Boolean] true since this is a success
    def success?
      true
    end

    # Returns nil as there is no failure value in a success.
    #
    # @return [nil]
    def failure
      nil
    end

    # Indicates whether the result is a failure.
    #
    # @return [Boolean] false since this is a success
    def failure?
      false
    end

    def to_sym
      :success
    end
  end
end
