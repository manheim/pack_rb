require 'spec_helper'
require 'pack_rb/sub_commands/inspect'

module PackRb
  class SubCommands
    describe Inspect do
      before do
        @harness ||= Class.new { include Inspect }
      end

      context '#inspect_tpl' do
        subject { @harness.new().inspect_tpl(base_cmd: 'packer') }
        it { is_expected.to eq('packer inspect') }
      end
    end
  end
end
