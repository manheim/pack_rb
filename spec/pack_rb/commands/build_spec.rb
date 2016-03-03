require 'spec_helper'
require 'pack_rb/commands/build'

module PackRb
  module Commands
    describe Build do
      before do
        Harness = Class.new {
          include Build
          def command
            'packer'
          end
        }
      end

      context '#build_cmd' do
        subject { Harness.new().build_cmd }
        it { is_expected.to eq('packer build') }
      end
    end
  end
end
