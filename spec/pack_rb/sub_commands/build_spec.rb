require 'spec_helper'
require 'pack_rb/sub_commands/build'

module PackRb
  class SubCommands
    describe Build do
      before do
        Harness = Class.new { include Build }
      end

      context '#build_cmd' do
        subject { Harness.new().build(base_cmd: 'packer') }
        it { is_expected.to eq('packer build') }
      end
    end
  end
end
