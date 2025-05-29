# frozen_string_literal: true

# @module HatiCommand
# Provides command handling functionalities and result objects.
module HatiCommand
  # @class Result
  # Base class for the Result pattern implementation.
  # This class serves as the foundation for Success and Failure result types,
  # providing common functionality and a consistent interface for handling
  # operation outcomes.
  #
  # The Result pattern helps in handling operation outcomes in a type-safe way,
  # making it explicit whether an operation succeeded or failed, and carrying
  # additional context like error messages and metadata.
  #
  # @abstract Subclass and override {#to_sym} to implement a concrete result type
  #
  # @example Basic usage
  #   result = HatiCommand::Result.new("Operation output")
  #   result.value  # => "Operation output"
  #
  # @example With error and metadata
  #   result = HatiCommand::Result.new(
  #     "Operation output",
  #     err: "Warning: partial completion",
  #     meta: { duration_ms: 150 }
  #   )
  #
  # @example Using trace information
  #   result = HatiCommand::Result.new("Output", trace: caller(1..1))
  #   result.trace  # => ["path/to/file.rb:42:in `method_name'"]
  #
  # @see HatiCommand::Success
  # @see HatiCommand::Failure
  #
  # @!attribute [r] value
  #   @return [Object] The wrapped value representing the operation's output
  #
  # @!attribute [r] meta
  #   @return [Hash] Additional metadata associated with the result
  #
  # @!attribute [rw] trace
  #   @return [Array<String>, nil] Execution trace information for debugging
  class Result
    attr_reader :value, :meta
    attr_accessor :trace

    # Initializes a new Result instance with a value and optional context.
    #
    # @param value [Object] The value to be wrapped in the result
    # @param err [String, nil] Optional error message or error object
    # @param meta [Hash] Optional metadata for additional context
    # @param trace [Array<String>, nil] Optional execution trace for debugging
    #
    # @example Basic initialization
    #   result = Result.new("Success")
    #
    # @example With full context
    #   result = Result.new(
    #     "Partial success",
    #     err: "Some records failed",
    #     meta: { processed: 10, failed: 2 },
    #     trace: caller
    #   )
    def initialize(value, err: nil, meta: {}, trace: nil)
      @value = value
      @err = err
      @meta = meta
      @trace = trace
    end

    # Returns self to provide a consistent interface across result types.
    # This method ensures that all result objects can be treated uniformly
    # when chaining operations.
    #
    # @return [HatiCommand::Result] The result instance itself
    # @api public
    def result
      self
    end

    # Returns the error associated with this result.
    # This can be used to check for warnings or errors even in successful results.
    #
    # @return [String, nil] The error message or object, if any
    # @raise [StandardError] If accessing the error triggers an error condition
    # @api public
    # @example
    #   result = Result.new("Value", err: "Warning message")
    #   result.error  # => "Warning message"
    def error
      @err
    end

    # Returns the symbolic representation of this result type.
    # This is an abstract method that should be overridden by concrete result types.
    #
    # @return [Symbol] Returns :undefined for the base class
    # @abstract Subclasses must override this method
    # @api public
    # @example
    #   Result.new("value").to_sym  # => :undefined
    def to_sym
      :undefined
    end
  end
end
