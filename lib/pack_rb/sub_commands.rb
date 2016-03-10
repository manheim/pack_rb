require 'open3'

require 'pack_rb/sub_commands/build'
require 'pack_rb/sub_commands/inspect'
require 'pack_rb/sub_commands/validate'

module PackRb
  class SubCommands
    include PackRb::SubCommands::Build
    include PackRb::SubCommands::Inspect
    include PackRb::SubCommands::Validate

    # Execute a Packer command.
    #
    # @param opts [Hash] options passed to the Packer class
    #
    # @return [Array] - stdout [String], stderr [String], exit code [Fixnum]
    def execute(opts)
      cmd = opts[:cmd]
      tpl = opts[:tpl]

      out, err, status = run_cmd_stream_output("#{cmd} -", tpl)
      # rubocop:disable Style/RedundantReturn
      return [out, err, status]
      # rubocop:enable Style/RedundantReturn
    end

    # popen3 wrapper to simultaneously stream command output to the
    # appropriate file descriptor, and capture it.
    #
    # @param cmd [String] command to run
    # @param tpl [String] the template content
    # @return [Array] - stdout [String], stderr [String], exit code [Fixnum]
    def run_cmd_stream_output(cmd, tpl)
      all_out = ''
      all_err = ''
      exit_status = nil
      Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thread|
        stdin.write(tpl)
        stdin.close_write
        begin
          files = [stdout, stderr]
          until files.find { |f| !f.eof }.nil?
            ready = IO.select(files)
            next unless ready
            readable = ready[0]
            readable.each do |f|
              begin
                data = f.read_nonblock(512)
                if f.fileno == stdout.fileno
                  puts data
                  all_out << data
                else
                  STDERR.puts data
                  all_err << data
                end
              rescue EOFError
                nil
              end
            end
          end
        rescue IOError => e
          STDERR.puts "IOError: #{e}"
        end
        exit_status = wait_thread.value.exitstatus
      end
      # rubocop:disable Style/RedundantReturn
      return all_out, all_err, exit_status
      # rubocop:enable Style/RedundantReturn
    end
  end
end
