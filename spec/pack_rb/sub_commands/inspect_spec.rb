require 'spec_helper'
require 'pack_rb/sub_commands/inspect'

module PackRb
  class SubCommands
    describe Inspect do
      before do
        @harness ||= Class.new do
          include Inspect

          def execute(opts)
            puts opts
          end
        end
      end

      describe '#inspect_tpl' do
        let(:json) { %Q{{"variables":{"foo":"bar"}}} }
        let(:opts) do
          {
            base_cmd: 'packer',
            tpl: json
          }
        end

        it 'should call execute on extended class' do
          h = @harness.new()

          expect(h).to receive(:execute).
            with(cmd: 'packer inspect', tpl: json)

          h.inspect_tpl(opts)
        end
      end
    end
  end
end
