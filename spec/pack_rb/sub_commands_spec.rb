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
      let(:cmd) { 'packer build -' }
      let(:json) { %Q{{"variables":{"foo":"bar"}}} }
      let(:stdin) { {stdin_data: json} }

      it 'runs the provided command using Open3' do
        expect(Open3).to receive(:capture3).with(cmd, stdin)
        SubCommands.new.execute(cmd: cmd, tpl: json)
      end
    end
  end
end
