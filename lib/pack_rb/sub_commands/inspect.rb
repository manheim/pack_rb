module PackRb
  class SubCommands
    module Inspect
      def inspect_tpl(opts)
        base_cmd = opts[:base_cmd]
        tpl      = opts[:tpl]

        cmd_arr = [base_cmd, 'inspect']

        execute(cmd: cmd_arr.join(' '), tpl: tpl)
      end
    end
  end
end
