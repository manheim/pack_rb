require 'spec_helper'
require 'pack_rb/sub_commands/build'

module PackRb
  class SubCommands
    describe Build do
      before do
        @harness ||= Class.new { include Build }
      end

      context '#build_cmd' do
        subject { @harness.new().build(base_cmd: 'packer') }
        it { is_expected.to eq('packer build') }

        context 'with options' do
          let(:opts) do
            {
              base_cmd: 'packer',
              args: { force: true }
            }
          end

          subject { @harness.new().build(opts) }

          it { is_expected.to eq('packer build -force') }
        end
      end

      context '#parse_options' do
        subject { @harness.new() }

        context 'unsupported' do
          let(:opts) { {foo: 'bar'} }

          it 'should raise Error::UnsupportedOption' do
            expect{ subject.parse_options(opts) }
              .to raise_error(Error::UnsupportedOption)
          end
        end

        context 'supported' do
          context 'array options' do
            let(:except_opts) { {except: ['foo','bar']} }
            let(:only_opts) { {only: ['foo','bar']} }

            it 'should convert value to comma separated string' do
              expect(subject.parse_options(except_opts))
                .to eq('-except=foo,bar')

              expect(subject.parse_options(only_opts)).to eq('-only=foo,bar')
            end
          end

          context 'boolean options' do
            let(:opts) { {color: false} }

            it 'should return the exact value in option format' do
              expect(subject.parse_options(opts)).to eq('-color=false')
            end
          end

          context 'flags' do
            context 'when true' do
              let(:force_opts) { {force: true} }
              let(:debug_opts) { {debug: true} }
              it 'should just return the flag name in option format' do
                expect(subject.parse_options(force_opts)).to eq('-force')
                expect(subject.parse_options(debug_opts)).to eq('-debug')
              end
            end

            context 'when false' do
              let(:opts) { {force: false} }
              it 'should return an empty string' do
                expect(subject.parse_options(opts)).to eq('')
              end
            end
          end
        end
      end
    end
  end
end
