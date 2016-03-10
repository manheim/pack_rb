require 'open3'

module PackRb
  class Executor
    # popen3 wrapper to simultaneously stream command output to the
    # appropriate file descriptor, and capture it.
    #
    # @param cmd [String] command to run
    # @param tpl [String] the template content
    # @return [Array] - stdout [String], stderr [String], exit code [Fixnum]
    def self.run_cmd_stream_output(cmd, tpl)
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
      [all_out, all_err, exit_status]
    end
  end
end
