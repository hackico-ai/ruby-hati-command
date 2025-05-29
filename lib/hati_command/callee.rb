# frozen_string_literal: true

# Module for adding callable functionality
module HatiCommand
  # Module for adding callable functionality to a class
  module Callee
    def self.included(base)
      base.extend(CalleeClassMethods)
    end

    # WIP: I know what you did last summer =)
    def self.whoami
      'My Name is Callee'
    end

    # Class methods for Callee
    module CalleeClassMethods
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
end
