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

      out, err, status = Open3.capture3("#{cmd} -", stdin_data: tpl)

      if status.exitstatus != 0
        puts out if out
        puts err if err
      end
    end
  end
end
