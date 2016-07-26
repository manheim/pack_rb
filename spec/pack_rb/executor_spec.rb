require 'spec_helper'
require 'pack_rb/sub_commands'

describe PackRb::Executor do
  describe '#run_cmd_stream_output' do
    let(:tpl) { 'template_data' }
    # test logic for this was inspired by:
    # http://rxr.whitequark.org/rubinius/source/spec/ruby/core/io/select_spec.rb
    before :each do
      @outerrpipe_r, @outerrpipe_w = IO.pipe
      @inpipe_r, @inpipe_w = IO.pipe
    end
    after :each do
      @outerrpipe_r.close unless @outerrpipe_r.closed?
      @outerrpipe_w.close unless @outerrpipe_w.closed?
      @inpipe_r.close unless @inpipe_r.closed?
      @inpipe_w.close unless @inpipe_w.closed?
    end
    context 'success' do
      it 'prints and returns output' do
        dbl_wait_thread = double(Thread)
        @outerrpipe_w.write('mystdout')
        @outerrpipe_w.close
        es = double('exitstatus', exitstatus: 0)
        allow(dbl_wait_thread).to receive(:value).and_return(es)
        allow($stdout).to receive(:sync).and_return(false)
        allow($stdout).to receive(:sync=).with(true)
        allow(Open3).to receive(:popen2e).and_yield(
          @inpipe_w, @outerrpipe_r, dbl_wait_thread
        )

        expect(Open3).to receive(:popen2e).once.with('foo bar')
        expect(STDOUT).to receive(:puts).once.with('mystdout')
        expect($stdout).to receive(:sync=).once.with(true)
        expect($stdout).to receive(:sync=).once.with(false)
        expect(PackRb::Executor.run_cmd_stream_output('foo bar', tpl))
          .to eq(['mystdout', 0])
        expect(@inpipe_r.read).to eq(tpl)
      end
    end
    context 'IOError' do
      it 'handles IOErrors gracefully' do
        dbl_wait_thread = double(Thread)
        @outerrpipe_w.close
        @outerrpipe_r.close
        es = double('exitstatus', exitstatus: 0)
        allow(dbl_wait_thread).to receive(:value).and_return(es)
        allow($stdout).to receive(:sync).and_return(false)
        allow($stdout).to receive(:sync=).with(true)
        allow(Open3).to receive(:popen2e).and_yield(
          @inpipe_w, @outerrpipe_r, dbl_wait_thread
        )

        expect(Open3).to receive(:popen2e).once.with('foo bar')
        expect(STDERR).to receive(:puts).once.with('IOError: closed stream')
        expect($stdout).to receive(:sync=).once.with(true)
        expect($stdout).to receive(:sync=).once.with(false)
        expect(PackRb::Executor.run_cmd_stream_output('foo bar', tpl))
          .to eq(['', 0])
        expect(@inpipe_r.read).to eq(tpl)
      end
    end
    context 'failure' do
      it 'returns the non-zero exit code' do
        dbl_wait_thread = double(Thread)
        @outerrpipe_w.write("mystdout\n")
        @outerrpipe_w.write("STDERR\n")
        @outerrpipe_w.close
        es = double('exitstatus', exitstatus: 23)
        allow(dbl_wait_thread).to receive(:value).and_return(es)
        allow($stdout).to receive(:sync).and_return(false)
        allow($stdout).to receive(:sync=).with(true)
        allow(Open3).to receive(:popen2e).and_yield(
          @inpipe_w, @outerrpipe_r, dbl_wait_thread
        )

        expect(Open3).to receive(:popen2e).once.with('foo bar')
        expect(STDOUT).to receive(:puts).once.with("mystdout\n")
        expect(STDOUT).to receive(:puts).once.with("STDERR\n")
        expect($stdout).to receive(:sync=).once.with(true)
        expect($stdout).to receive(:sync=).once.with(false)
        expect(PackRb::Executor.run_cmd_stream_output('foo bar', tpl))
          .to eq(["mystdout\nSTDERR\n", 23])
        expect(@inpipe_r.read).to eq(tpl)
      end
    end
  end
end
