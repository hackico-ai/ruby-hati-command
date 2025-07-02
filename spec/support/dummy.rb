# frozen_string_literal: true

# NOTE: helper names follow convention 'support_<module_name>_<helper_name>'

module Dummy
  def support_dummy_befehl(name)
    stub_const(name, Class.new do 
      extend HatiCommand::Befehl
    end)
  end

  def support_dummy_cmd(name)
    stub_const(name, Class.new do
      include HatiCommand::Cmd

      command do
        fail_fast 'Base Fail Fast Message'
      end
    end)
  end

  def support_dummy_error(name)
    stub_const(name, Class.new(StandardError))
  end
end
