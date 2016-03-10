require 'spec_helper'
require 'pack_rb/sub_commands/build'

module PackRb
  class SubCommands
    describe Build do
      before do
        @harness ||= Class.new do
          include Build

          def execute(opts)
            puts opts
          end
        end
      end

      describe '#build_cmd' do
        let(:json) { %Q{{"variables":{"foo":"bar"}}} }
        let(:opts) do
          {
            base_cmd: 'packer',
            args: { force: true },
            tpl: json
          }
        end

        it 'should call execute on the extended class' do
          h = @harness.new()

          expect(h).to receive(:execute).
            with(cmd: 'packer build -force', tpl: json)

          h.build(opts)
        end
      end

      describe '#parse_options' do
        context 'unsupported' do
          subject { -> { @harness.new().parse_options(opts) } }
          let(:opts) { {foo: 'bar'} }

          it { is_expected.to raise_error(Error::UnsupportedOption) }
        end

        context 'supported' do
          subject { @harness.new().parse_options(opts) }

          context 'array options' do
            context 'except' do
              let(:opts) { {except: ['foo','bar']} }

              it { is_expected.to eq('-except=foo,bar') }
            end

            context 'only' do
              let(:opts) { {only: ['foo','bar']} }

              it { is_expected.to eq('-only=foo,bar') }
            end
          end

          context 'boolean options' do
            context 'color' do
              let(:opts) { {color: false} }

              it { is_expected.to eq('-color=false') }
            end
          end

          context 'flags' do
            context 'force' do
              context 'when true' do
                let(:opts) { {force: true} }

                it { is_expected.to eq('-force') }
              end

              context 'when false' do
                let(:opts) { {force: false} }

                it { is_expected.to eq('') }
              end
            end

            context 'debug' do
              context 'when true' do
                let(:opts) { {debug: true} }

                it { is_expected.to eq('-debug') }
              end

              context 'when false' do
                let(:opts) { {debug: false} }

                it { is_expected.to eq('') }
              end
            end
          end
        end
      end
    end
  end
end
