module PackRb
  class SubCommands
    module Validate
      def validate(opts)
        base_cmd = opts[:base_cmd]
        "#{base_cmd} validate"
      end
    end
  end
end
