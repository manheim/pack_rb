require 'json'
require 'pack_rb/sub_commands'
require 'mkmf'

# MakeMakefile::find_executable provides a built-in, native Ruby
# implementation of the Unix ``which`` command. Modify some variables
# to make it suppress writing log files or echoing.
begin
  const_get 'MakeMakefile'
  # this will fail with NameError on older rubies
  module MakeMakefile::Logging
    @logfile = File::NULL
    @quiet = true
  end
rescue NameError
  # module on older rubies
  module Logging
    @logfile = File::NULL
    @quiet = true
  end
end

module PackRb
  class Packer
    def initialize(opts = {})
      @machine_readable = opts[:machine_readable]
      @bin_path         = opts[:bin_path]
      @tpl              = opts[:tpl]
    end

    def command
      if machine_readable
        "#{bin} -machine-readable"
      else
        bin
      end
    end

    def bin
      return bin_path if bin_path
      # some distros, such as Arch Linux, package the Packer
      # binary as ``packer-io``
      ['packer', 'packer-io'].each do |bin_name|
        p = find_executable(bin_name)
        return p if p
      end
      raise RuntimeError, "Could not find packer or packer-io binary on path." \
                          " Please specify the full binary path with the " \
                          "'bin_path' option."
    end

    def template
      obj = @tpl
      json?(obj) || path?(obj) || hash?(obj)
    end

    def commander
      @commander ||= PackRb::SubCommands.new
    end

    def method_missing(name, *args, &block)
      return super unless commander.respond_to?(name)

      opts = {
        base_cmd: command,
        tpl: template,
        args: args.first
      }

      commander.send(name, opts)
    end

    private

    def can_match?(obj)
      obj.respond_to?(:match)
    end

    def like_json?(obj)
      obj.match(/{.*}/)
    end

    def json?(obj)
      can_match?(obj) && like_json?(obj) && obj
    end

    def path?(obj)
      can_match?(obj) && File.read(obj)
    end

    def hash?(obj)
      obj.to_json
    end

    def bin_path
      @bin_path
    end

    def machine_readable
      @machine_readable
    end
  end
end
