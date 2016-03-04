module PackRb
  class SubCommands
    module Inspect
      def inspect_tpl(opts)
        base_cmd = opts[:base_cmd]
        "#{base_cmd} inspect"
      end
    end
  end
end
