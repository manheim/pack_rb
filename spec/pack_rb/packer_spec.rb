require 'spec_helper'
require 'pack_rb/packer'

module PackRb
  describe Packer do
    context '#command' do
      subject { Packer.new(opts).command }

      context 'machine-readable' do
        context 'when true' do
          let(:opts) { { machine_readable: true } }

          it { is_expected.to eq('packer -machine-readable') }
        end

        context 'when false' do
          let(:opts) { Hash.new }

          it { is_expected.to eq('packer') }
        end
      end

      context '#bin' do
        subject { Packer.new(opts).bin }

        context 'default' do
          let(:opts) { Hash.new }
          it { is_expected.to eq('packer') }
        end

        context '/usr/local/bin/packer' do
          let(:opts) { { bin_path: '/usr/local/bin/packer' } }

          it { is_expected.to eq('/usr/local/bin/packer') }
        end
      end

      context '#template' do
        subject { Packer.new(opts).template }

        context 'with hash' do
          let(:json) { %Q{{"variables":{"foo":"bar"}}} }
          let(:opts) { { tpl: { variables: { foo: 'bar'} } } }

          it { is_expected.to eq(json) }
        end

        context 'with file path' do
          before do
            allow(File).to receive(:read).with(path).and_return(json)
          end

          let(:json) { %Q{{"variables":{"foo":"bar"}}} }
          let(:path) { 'config/packer.json' }
          let(:opts) { { tpl: path } }

          it { is_expected.to eq(json) }
        end

        context 'with string of json' do
          let(:json) { %Q{{"variables":{"foo":"bar"}}} }
          let(:opts) { { tpl: json } }

          it { is_expected.to eq(json) }
        end
      end

      describe '#method_missing' do
        let(:json) { %Q{{"variables":{"foo":"bar"}}} }
        let(:expected_opts) do
          {
            base_cmd: 'packer',
            tpl: json,
            args: { debug: true, only: ['foo','bar'] }
          }
        end

        it 'delegates to commander' do
          p = Packer.new(tpl: json)
          expect(p.commander).to receive(:build).with(expected_opts)
          p.build(debug: true, only: ['foo','bar'])
        end

        it 'raises if sub command not supported' do
          expect{ Packer.new.foo }.to raise_error(NoMethodError)
        end
      end
    end
  end
end
