require 'spec_helper'

describe BuildExec do
  context 'a build executor' do
    let(:listener) { stub(:info => true) }
    let(:launcher) { stub(:execute) }
    let(:workspace) do
      stub({
        :realpath => '/var/jenkins/builds',
        :create_launcher => launcher
      })
    end
    let(:build) { stub(:workspace => workspace) }

    subject { BuildExec.new(build, listener) }

    context '.run' do
      let(:out) { StringIO.new << "stdout" }
      let(:err) { StringIO.new << "stderr" }
      
      before do
        launcher.should_receive(:execute).and_return(1)
      end

      it 'succeeds with no opts' do
        subject.run('foo').should == {:out => '', :err => '', :val => 1}
      end

      it 'returns the stdout, stderr, and exit code from the command that was run' do
        opts = {:out => out, :err => err}
        subject.run('foo', opts).should == {:out => 'stdout', :err => 'stderr', :val => 1}
      end

      it 'assigns the contents of opts[:stdin_str] to a stream in opts[:in]' do
        opts = {:out => out, :err => err, :stdin_str => "More STDIN"}
        subject.run('foo', opts)

        opts[:in].read.should == "More STDIN\n"
      end

      it 'raises an exception when opts[:raise] is provided and the command fails' do
        expect { subject.run('foo', {:raise => true}) }.to raise_error(StandardError)
      end
    end
  end
end
