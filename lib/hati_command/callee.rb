# frozen_string_literal: true

# @module HatiCommand
# Provides command handling functionalities and callable patterns.
module HatiCommand
  # @module Callee
  # Module for adding callable functionality to a class.
  # This module implements the callable pattern, allowing classes to be called like functions
  # while maintaining object-oriented principles.
  #
  # @example
  #   class MyCallable
  #     include HatiCommand::Callee
  #
  #     def call(input)
  #       # Process input
  #       input.upcase
  #     end
  #   end
  #
  #   # Can be used as:
  #   result = MyCallable.call("hello")  # => "HELLO"
  #
  #   # Or with a block:
  #   MyCallable.call("hello") do |instance|
  #     instance.configure(some: :option)
  #   end
  module Callee
    # Extends the including class with callable functionality
    # @param base [Class] The class including this module
    # @return [void]
    # @api private
    def self.included(base)
      base.extend(CalleeClassMethods)
    end

    # Returns the identity of the module
    # @note This is a work in progress method
    # @return [String] The module's identity string
    # @api public
    def self.whoami
      'My Name is Callee'
    end

    # @module CalleeClassMethods
    # Class methods that are extended to classes including Callee.
    # Provides the callable interface at the class level.
    module CalleeClassMethods
      # Creates a new instance and calls its `call` method with the given arguments.
      # This method implements the callable pattern, allowing the class to be used
      # like a function while maintaining object-oriented principles.
      #
      # @param args [Array] Arguments to be passed to the instance's call method
      # @yield [Object] Optional block that yields the new instance before calling
      # @yieldparam instance [Object] The newly created instance
      # @return [Object] The result of the instance method call
      # @example Without block
      #   MyCallable.call(arg1, arg2)
      # @example With configuration block
      #   MyCallable.call(input) do |instance|
      #     instance.configure(option: value)
      #   end
      def call(...)
        obj = new

        yield(obj) if block_given?

        obj.call(...)
      end
    end
  end
end
