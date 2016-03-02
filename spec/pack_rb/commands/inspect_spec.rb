require 'spec_helper'
require 'pack_rb/commands/inspect'

module PackRb
  module Commands
    describe Inspect do
      before do
        Harness = Class.new {
          include Inspect
          def command
            'packer'
          end
        }
      end

      context '#inspect_cmd' do
        subject { Harness.new().inspect_cmd }
        it { is_expected.to eq('packer inspect') }
      end
    end
  end
end
