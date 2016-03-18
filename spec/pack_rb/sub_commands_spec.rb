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

    context 'stream_output' do
      it 'should set STDOUT.sync to true' do
        fake_stdout = stub_const('STDOUT', double('IO'))
        allow(fake_stdout).to receive(:sync=)

        SubCommands.new(stream_output: true)

        expect(fake_stdout).to have_received(:sync=).with(true)
      end

      it 'should set STDERR.sync to true' do
        fake_stderr = stub_const('STDERR', double('IO'))
        allow(fake_stderr).to receive(:sync=)

        SubCommands.new(stream_output: true)

        expect(fake_stderr).to have_received(:sync=).with(true)
      end
    end

    describe '#execute' do
      let(:cmd) { 'packer build' }
      let(:json) { %Q{{"variables":{"foo":"bar"}}} }

      it 'runs the provided command using run_cmd_stream_output' do
        allow(PackRb::Executor).to receive(:run_cmd_stream_output)
          .and_return(['out_and_err', 0])
        expect(PackRb::Executor).to receive(:run_cmd_stream_output).once
          .with("#{cmd} -", json)
        subject.execute(cmd: cmd, tpl: json)
      end

      it 'returns the stdout, stderr and exit code' do
        allow(PackRb::Executor).to receive(:run_cmd_stream_output)
          .and_return(['out_and_err', 0])
        expect(subject.execute(cmd: cmd, tpl: json)).to eq(['out_and_err', 0])
      end
    end
  end
end
