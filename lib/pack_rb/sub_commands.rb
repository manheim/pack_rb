require 'pack_rb/executor'
require 'pack_rb/sub_commands/build'
require 'pack_rb/sub_commands/inspect'
require 'pack_rb/sub_commands/validate'

module PackRb
  class SubCommands
    include PackRb::SubCommands::Build
    include PackRb::SubCommands::Inspect
    include PackRb::SubCommands::Validate

    def initialize(opts = {})
      if opts[:stream_output]
        STDOUT.sync = true
        STDERR.sync = true
      end
    end

    # Execute a Packer command via {PackRb::Executor.run_cmd_stream_output}
    #
    # @param opts [Hash] options passed to the Packer class
    #
    # @return [Array] - stdout_and_err [String], exit code [Fixnum]
    def execute(opts)
      cmd = opts[:cmd]
      tpl = opts[:tpl]

      PackRb::Executor.run_cmd_stream_output("#{cmd} -", tpl)
    end
  end
end
