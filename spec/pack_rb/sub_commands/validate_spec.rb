require 'spec_helper'
require 'pack_rb/sub_commands/validate'

module PackRb
  class SubCommands
    describe Validate do
      before do
        @harness ||= Class.new do
          include Validate

          def execute(opts)
            puts opts
          end
        end
      end

      context '#validate' do
        let(:json) { %Q{{"variables":{"foo":"bar"}}} }
        let(:opts) do
          {
            base_cmd: 'packer',
            tpl: json
          }
        end

        it 'should call execute on extended class', use_harness: true do
          h = @harness.new()

          expect(h).to receive(:execute).
            with(cmd: 'packer validate', tpl: json)

          h.validate(opts)
        end
      end
    end
  end
end
