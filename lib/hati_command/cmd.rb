# frozen_string_literal: true

# HatiCommand module provides command handling functionalities.
module HatiCommand
  # Dev-friendly extension of the Befehl core module with Railway track API.
  module Cmd
    def self.included(base)
      base.extend(HatiCommand::Befehl)
      base.private_class_method :new
    end

    # WIP: I know what you did last summer =)
    def self.whoami
      'My Name is Cmd'
    end

    def Success(value = nil, err: nil, meta: {}) # rubocop:disable Naming/MethodName
      HatiCommand::Success.new(value, err: err, meta: meta)
    end

    def Failure(value = nil, err: nil, meta: {}) # rubocop:disable Naming/MethodName
      default_err = self.class.command_config[:failure]
      HatiCommand::Failure.new(value, err: err || default_err, meta: meta)
    end

    def Failure!(value = nil, err: nil, meta: {}, **_opts) # rubocop:disable Naming/MethodName
      default_error = self.class.command_config[:fail_fast] || self.class.command_config[:failure]
      error = err || default_error

      err_obj = HatiCommand::Failure.new(value, err: error, meta: meta)
      raise HatiCommand::Errors::FailFastError.new('Fail Fast Triggered', err_obj: err_obj)
    end
  end
end
