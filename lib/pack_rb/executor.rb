require 'open3'

module PackRb
  class Executor
    # popen2e wrapper to simultaneously stream command output and capture it.
    #
    # STDOUT and STDERR will be combined to the same stream, and returned as one
    # string. This is because there doesn't seem to be a safe, cross-platform
    # way to both capture and stream STDOUT and STDERR separately that isn't
    # prone to deadlocking if large chunks of data are written to the pipes.
    #
    # @param cmd [String] command to run
    # @param tpl [String] the template content
    # @return [Array] - out_err [String], exit code [Fixnum]
    def self.run_cmd_stream_output(cmd, tpl)
      old_sync = $stdout.sync
      $stdout.sync = true
      all_out_err = ''
      exit_status = nil
      Open3.popen2e(cmd) do |stdin, stdout_and_err, wait_thread|
        stdin.write(tpl)
        stdin.close_write
        begin
          while (line = stdout_and_err.gets)
            puts line
            all_out_err << line
          end
        rescue IOError => e
          STDERR.puts "IOError: #{e}"
        end
        exit_status = wait_thread.value.exitstatus
      end
      # rubocop:disable Style/RedundantReturn
      $stdout.sync = old_sync
      return all_out_err, exit_status
      # rubocop:enable Style/RedundantReturn
    end
  end
end
