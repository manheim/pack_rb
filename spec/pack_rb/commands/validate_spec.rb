require 'spec_helper'
require 'pack_rb/commands/validate'

module PackRb
  module Commands
    describe Validate do
      before do
        Harness = Class.new {
          include Validate
          def command
            'packer'
          end
        }
      end

      context '#validate_cmd' do
        subject { Harness.new().validate_cmd }
        it { is_expected.to eq('packer validate') }
      end
    end
  end
end
