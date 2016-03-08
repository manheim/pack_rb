require 'spec_helper'
require 'pack_rb/sub_commands'

module PackRb
  describe SubCommands do
    context 'supported commands' do
      subject { SubCommands.new }

      it { is_expected.to respond_to(:build) }
      it { is_expected.to respond_to(:inspect_tpl) }
      it { is_expected.to respond_to(:validate) }
    end

    context '#execute' do
      let(:cmd) { 'packer build' }
      let(:json) { %Q{{"variables":{"foo":"bar"}}} }
      let(:stdin) { {stdin_data: json} }
      let(:status) { double('status', exitstatus: 0) }


      it 'runs the provided command using Open3' do

        allow(Open3).to receive(:capture3) do
          [double('io'), double('io'), status]
        end

        expect(Open3).to receive(:capture3).with("#{cmd} -", stdin)
        SubCommands.new.execute(cmd: cmd, tpl: json)
      end

      context 'on error' do
        let(:out) { double('out', to_s: 'oh noes') }
        let(:err) { double('err', to_s: 'kabloom') }
        let(:status) { double('status', exitstatus: 1) }

        # As of version 0.9.0 packer sends errors to stdout.
        # This will print both stdout and stderr for in the future if/when
        # they fix this oddity.
        it 'prints stdout and stderr' do
          allow(Open3).to receive(:capture3) do
            [out, err, status]
          end

          expect{ SubCommands.new.execute(cmd: cmd, tpl: json) }
            .to output("oh noes\nkabloom\n").to_stdout
        end

        context 'no stdout message' do
          let(:out) { nil }

          it 'only prints stderr' do
            allow(Open3).to receive(:capture3) do
              [out, err, status]
            end

            expect{ SubCommands.new.execute(cmd: cmd, tpl: json) }
              .to output("kabloom\n").to_stdout
          end
        end

        context 'no stderr message' do
          let(:out) { double('out', to_s: 'oh noes') }
          let(:err) { nil }

          it 'only prints stdout' do
            allow(Open3).to receive(:capture3) do
              [out, err, status]
            end

            expect{ SubCommands.new.execute(cmd: cmd, tpl: json) }
              .to output("oh noes\n").to_stdout
          end
        end
      end
    end
  end
end
