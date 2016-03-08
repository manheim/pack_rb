module PackRb
  class SubCommands
    module Validate
      def validate(opts)
        base_cmd = opts[:base_cmd]
        tpl      = opts[:tpl]

        cmd_arr = [base_cmd, 'validate']

        execute(cmd: cmd_arr.join(' '), tpl: tpl)
      end
    end
  end
end
