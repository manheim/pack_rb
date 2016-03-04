require 'open3'

require 'pack_rb/sub_commands/build'
require 'pack_rb/sub_commands/inspect'
require 'pack_rb/sub_commands/validate'

module PackRb
  class SubCommands
    include PackRb::SubCommands::Build
    include PackRb::SubCommands::Inspect
    include PackRb::SubCommands::Validate

    def execute(opts)
      cmd = opts[:cmd]
      tpl = opts[:tpl]

      Open3.capture3(cmd, stdin_data: tpl)
    end
  end
end
