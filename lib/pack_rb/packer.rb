require 'json'

module PackRb
  class Packer
    def initialize(opts = {})
      @machine_readable = opts[:machine_readable]
      @bin_path         = opts[:bin_path]
      @tpl              = opts[:tpl]
    end

    def command
      if machine_readable
        'packer -machine-readable'
      else
        'packer'
      end
    end

    def bin
      bin_path || 'packer'
    end

    def template
      obj = @tpl
      json?(obj) || path?(obj) || hash?(obj)
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
