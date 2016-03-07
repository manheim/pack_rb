require 'pack_rb/sub_commands/error/errors'
module PackRb
  class SubCommands
    module Build
      def build(opts)
        base_cmd = opts[:base_cmd]
        args     = opts[:args]

        cmd_arr = [ base_cmd, 'build' ]
        cmd_arr << parse_options(args) if args
        cmd_arr.join(' ')
      end

      def parse_options(opts)
        transformed_opts = opts.inject([]) do |arr, kv|
          key = kv.first
          val = kv.last

          raise Error::UnsupportedOption unless supported?(key)

          arr << transform(key).call(key.to_s, val)
        end

        transformed_opts.join(' ')
      end

      private
      def transformation_strategy
        {
          except: array_type,
          only: array_type,
          color: boolean_type,
          force: flag_type,
          debug: flag_type
        }
      end

      def transform(opt)
        transformation_strategy[opt]
      end

      def supported?(opt)
        transformation_strategy.keys.include?(opt)
      end

      def array_type
        Proc.new { |opt, val| "-#{opt}=#{val.join(',')}" }
      end

      def boolean_type
        Proc.new { |opt, val| "-#{opt}=#{val}" }
      end

      def flag_type
        Proc.new { |opt, val| val ? "-#{opt}" : '' }
      end
    end
  end
end
