require 'spec_helper'
require 'pack_rb/sub_commands'

describe PackRb::Executor do
  describe '#run_cmd_stream_output' do
    let(:tpl) { 'template_data' }
    # test logic for this was inspired by:
    # http://rxr.whitequark.org/rubinius/source/spec/ruby/core/io/select_spec.rb
    before :each do
      @outpipe_r, @outpipe_w = IO.pipe
      @errpipe_r, @errpipe_w = IO.pipe
      @inpipe_r, @inpipe_w = IO.pipe
    end
    after :each do
      @outpipe_r.close unless @outpipe_r.closed?
      @outpipe_w.close unless @outpipe_w.closed?
      @errpipe_r.close unless @errpipe_r.closed?
      @errpipe_w.close unless @errpipe_w.closed?
      @inpipe_r.close unless @inpipe_r.closed?
      @inpipe_w.close unless @inpipe_w.closed?
    end
    context 'success' do
      it 'prints and returns STDOUT' do
        dbl_wait_thread = double(Thread)
        @errpipe_w.close
        @outpipe_w.write('mystdout')
        @outpipe_w.close
        es = double('exitstatus', exitstatus: 0)
        allow(dbl_wait_thread).to receive(:value).and_return(es)
        allow(Open3).to receive(:popen3).and_yield(
          @inpipe_w, @outpipe_r, @errpipe_r, dbl_wait_thread
        )

        expect(Open3).to receive(:popen3).once.with('foo bar')
        expect(STDOUT).to receive(:puts).once.with('mystdout')
        expect(PackRb::Executor.run_cmd_stream_output('foo bar', tpl))
          .to eq(['mystdout', '', 0])
        expect(@inpipe_r.read).to eq(tpl)
      end
      it 'prints and returns STDERR' do
        dbl_wait_thread = double(Thread)
        @errpipe_w.write('mystderr')
        @errpipe_w.close
        @outpipe_w.close
        es = double('exitstatus', exitstatus: 0)
        allow(dbl_wait_thread).to receive(:value).and_return(es)
        allow(Open3).to receive(:popen3).and_yield(
          @inpipe_w, @outpipe_r, @errpipe_r, dbl_wait_thread
        )

        expect(Open3).to receive(:popen3).once.with('foo bar')
        expect(STDERR).to receive(:puts).once.with('mystderr')
        expect(PackRb::Executor.run_cmd_stream_output('foo bar', tpl))
          .to eq(['', 'mystderr', 0])
        expect(@inpipe_r.read).to eq(tpl)
      end
      it 'prints and returns both STDOUT and STDERR' do
        dbl_wait_thread = double(Thread)
        @errpipe_w.write('STDERR')
        @errpipe_w.close
        @outpipe_w.write('mystdout')
        @outpipe_w.close
        es = double('exitstatus', exitstatus: 0)
        allow(dbl_wait_thread).to receive(:value).and_return(es)
        allow(Open3).to receive(:popen3).and_yield(
          @inpipe_w, @outpipe_r, @errpipe_r, dbl_wait_thread
        )

        expect(Open3).to receive(:popen3).once.with('foo bar')
        expect(STDOUT).to receive(:puts).once.with('mystdout')
        expect(STDERR).to receive(:puts).once.with('STDERR')
        expect(PackRb::Executor.run_cmd_stream_output('foo bar', tpl))
          .to eq(['mystdout', 'STDERR', 0])
        expect(@inpipe_r.read).to eq(tpl)
      end
    end
    context 'IOError' do
      it 'handles IOErrors gracefully' do
        dbl_wait_thread = double(Thread)
        @errpipe_w.close
        @outpipe_w.write('mystdout')
        @outpipe_w.close
        @errpipe_r.close
        es = double('exitstatus', exitstatus: 0)
        allow(dbl_wait_thread).to receive(:value).and_return(es)
        allow(Open3).to receive(:popen3).and_yield(
          @inpipe_w, @outpipe_r, @errpipe_r, dbl_wait_thread
        )

        expect(Open3).to receive(:popen3).once.with('foo bar')
        expect(STDERR).to receive(:puts).once.with('IOError: closed stream')
        expect(PackRb::Executor.run_cmd_stream_output('foo bar', tpl))
          .to eq(['', '', 0])
        expect(@inpipe_r.read).to eq(tpl)
      end
    end
    context 'failure' do
      it 'returns the non-zero exit code' do
        dbl_wait_thread = double(Thread)
        @errpipe_w.write('STDERR')
        @errpipe_w.close
        @outpipe_w.write('mystdout')
        @outpipe_w.close
        es = double('exitstatus', exitstatus: 23)
        allow(dbl_wait_thread).to receive(:value).and_return(es)
        allow(Open3).to receive(:popen3).and_yield(
          @inpipe_w, @outpipe_r, @errpipe_r, dbl_wait_thread
        )

        expect(Open3).to receive(:popen3).once.with('foo bar')
        expect(STDOUT).to receive(:puts).once.with('mystdout')
        expect(STDERR).to receive(:puts).once.with('STDERR')
        expect(PackRb::Executor.run_cmd_stream_output('foo bar', tpl))
          .to eq(['mystdout', 'STDERR', 23])
        expect(@inpipe_r.read).to eq(tpl)
      end
    end
  end
end
