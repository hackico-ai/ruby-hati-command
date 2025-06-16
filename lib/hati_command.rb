# frozen_string_literal: true

require 'hati_command/version'
# errors
require 'hati_command/errors/base_error'
require 'hati_command/errors/configuration_error'
require 'hati_command/errors/fail_fast_error'
require 'hati_command/errors/transaction_error'
# result
require 'hati_command/result'
require 'hati_command/success'
require 'hati_command/failure'
# core
require 'hati_command/callee'
require 'hati_command/befehl'
# cmd
require 'hati_command/cmd'
