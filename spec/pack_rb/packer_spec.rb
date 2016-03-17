require 'spec_helper'
require 'pack_rb/packer'

module PackRb
  describe Packer do
    describe '#command' do
      subject { Packer.new(opts).command }

      context 'machine-readable' do
        context 'when true' do
          let(:opts) { { machine_readable: true } }

          it {
            allow_any_instance_of(Packer).to receive(:bin).and_return('binpath')
            is_expected.to eq('binpath -machine-readable')
          }
        end

        context 'when false' do
          let(:opts) { Hash.new }

          it {
            allow_any_instance_of(Packer).to receive(:bin).and_return('binpath')
            is_expected.to eq('binpath')
          }
        end
      end
    end

    describe '#bin' do
      subject { Packer.new(opts).bin }

      context 'packer found on path' do
        let(:opts) { Hash.new }
        it {
          allow_any_instance_of(Packer).to receive(:find_executable)
            .with('packer').and_return('/path/to/packer')
          allow_any_instance_of(Packer).to receive(:find_executable)
            .with('packer-io').and_return(nil)
          is_expected.to eq('/path/to/packer')
        }
      end

      context 'packer-io found on path' do
        let(:opts) { Hash.new }
        it {
          allow_any_instance_of(Packer).to receive(:find_executable)
            .with('packer').and_return(nil)
          allow_any_instance_of(Packer).to receive(:find_executable)
            .with('packer-io').and_return('/path/to/packer-io')
          is_expected.to eq('/path/to/packer-io')
        }
      end

      context 'neither binary name found on path' do
        let(:opts) { Hash.new }
        it {
          allow_any_instance_of(Packer).to receive(:find_executable)
            .with('packer').and_return(nil)
          allow_any_instance_of(Packer).to receive(:find_executable)
            .with('packer-io').and_return(nil)
          expect{ Packer.new(opts).command }.to raise_error(RuntimeError,
            'Could not find packer or packer-io binary on path. Please ' \
            'specify the full binary path with the \'bin_path\' option.')
        }
      end

      context 'bin_path option specified' do
        let(:opts) { { bin_path: '/usr/local/bin/packer' } }

        it { is_expected.to eq('/usr/local/bin/packer') }
      end

      context 'effect on #command' do
        subject { Packer.new(opts).command }

        context 'without machine-readable' do
          let(:opts) { { bin_path: '/usr/local/bin/packer' } }

          it { is_expected.to eq('/usr/local/bin/packer') }
        end

        context 'with machine-redable' do
          let(:opts) do
            {
              bin_path: '/usr/local/bin/packer',
              machine_readable: true
            }
          end

          it { is_expected.to eq('/usr/local/bin/packer -machine-readable') }
        end
      end
    end

    describe '#template' do
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
          base_cmd: 'binpath',
          tpl: json,
          args: { debug: true, only: ['foo','bar'] }
        }
      end

      it 'delegates to commander' do
        p = Packer.new(tpl: json)
        allow_any_instance_of(Packer).to receive(:bin).and_return('binpath')
        expect(p.commander).to receive(:build).with(expected_opts)
        p.build(debug: true, only: ['foo','bar'])
      end

      context 'handling of stream_output' do
        let(:p) { Packer.new(opts) }
        let(:f) { stub_const('PackRb::SubCommands', double('fake')) }
        before  { allow(f).to receive(:new) }

        context 'when stream_output is set to true' do
          let(:opts) { {stream_output: true} }

          it 'should pass stream_output: true to the delegate' do
            p.commander
            expect(f).to have_received(:new).with(opts)
          end
        end

        context 'when stream_output is not set' do
          let(:opts) { {} }

          it 'shoudl pass stream_output: false to the delegate' do
            p.commander
            expect(f).to have_received(:new).with(stream_output: false)
          end
        end
      end

      it 'raises if sub command not supported' do
        expect{ Packer.new.foo }.to raise_error(NoMethodError)
      end
    end
  end
end
