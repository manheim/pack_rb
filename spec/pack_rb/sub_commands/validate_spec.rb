require 'spec_helper'
require 'pack_rb/sub_commands/validate'

module PackRb
  class SubCommands
    describe Validate do
      before do
        @harness ||= Class.new { include Validate }
      end

      context '#validate' do
        subject { @harness.new().validate(base_cmd: 'packer') }
        it { is_expected.to eq('packer validate') }
      end
    end
  end
end
