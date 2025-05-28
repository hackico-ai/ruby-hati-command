# frozen_string_literal: true

# Module for adding callable functionality
module Callee
  def self.included(base)
    base.extend(ClassMethods)
  end

  # Class methods for Callee
  module ClassMethods
    # Calls the instance method `call` on a new instance of the class.
    #
    # @param args [Array] arguments to be passed to the instance method
    # @return [Object] the result of the instance method call
    def call(...)
      obj = new

      yield(obj) if block_given?

      obj.call(...)
    end
  end
end
