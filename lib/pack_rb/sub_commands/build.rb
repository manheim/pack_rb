module PackRb
  class SubCommands
    module Build
      def build(opts)
        base_cmd = opts[:base_cmd]

        "#{base_cmd} build"
      end
    end
  end
end
