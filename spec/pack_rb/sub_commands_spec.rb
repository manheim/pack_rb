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

      it 'runs the provided command using run_cmd_stream_output' do
        allow(PackRb::Executor).to receive(:run_cmd_stream_output)
          .and_return(['out', 'err', 0])
        expect(PackRb::Executor).to receive(:run_cmd_stream_output).once
          .with("#{cmd} -", json)
        subject.execute(cmd: cmd, tpl: json)
      end

      it 'returns the stdout, stderr and exit code' do
        allow(PackRb::Executor).to receive(:run_cmd_stream_output)
          .and_return(['out', 'err', 0])
        expect(subject.execute(cmd: cmd, tpl: json)).to eq(['out', 'err', 0])
      end
    end
  end
end
