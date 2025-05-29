# frozen_string_literal: true

module HatiCommand
  # This class represents a result.
  #
  # @example
  #   result = HatiCommand::Result.new("Success", err: nil, meta: { key: "value" })
  #   result.value # => "Success"
  #   result.error # => nil
  #   result.meta # => { key: "value" }
  #
  # @!attribute [r] value
  #   @return [Object] the value associated with the result
  #
  # @!attribute [r] err
  #   @return [String, nil] an optional error message associated with the result
  #
  # @!attribute [r] meta
  #   @return [Hash] optional metadata associated with the result
  class Result
    attr_reader :value, :meta
    attr_accessor :trace

    # Initializes a new Result instance.
    #
    # @param value [Object] the value to be wrapped in the result
    # @param err [String, nil] an optional error message
    # @param meta [Hash] optional metadata
    # @param trace [Array] optional trace
    def initialize(value, err: nil, meta: {}, trace: nil)
      @value = value
      @err = err
      @meta = meta
      @trace = trace
    end

    # Returns the result instance itself.
    #
    # @return [HatiCommand::Result] the result instance
    def result
      self
    end

    # Returns the error message associated with the result.
    #
    # @return [String, nil] the error message
    # @raise [StandardError] if there is an error message
    def error
      @err
    end

    def to_sym
      :undefined
    end
  end
end
