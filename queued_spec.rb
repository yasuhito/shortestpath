require 'job'
require 'queued'
require 'spec_helper'


describe Queued do
  describe 'when starting' do
    it 'should log and exit if cannnot open port' do
      dummy_log = 'DUMMY LOG'
      dummy_log.expects( :puts ).at_least_once
      dummy_log.expects( :flush ).at_least_once
      File.expects( :open ).with( '/tmp/queued.log', 'w' ).once.returns( dummy_log )

      TCPServer.stubs( :open ).with( 7838 ).raises( 'SOCKET OPEN ERROR' )

      queued = Queued.new
      lambda do
        queued.start
      end.should raise_error( SystemExit )
    end
  end


  describe 'when accepting a command' do
    before :each do
      dummy_log = 'DUMMY LOG'
      dummy_log.stubs( :puts )
      dummy_log.stubs( :flush )
      File.stubs( :open ).with( '/tmp/queued.log', 'w' ).returns( dummy_log )

      @client = 'DUMMY CLIENT'

      socket = 'DUMMY SOCKET'
      socket.stubs( :accept ).returns( @client )

      Kernel.stubs( :loop ).yields
      TCPServer.stubs( :open ).with( 7838 ).returns( socket )
      Thread.stubs( :start ).with( @client ).yields( @client )
    end


    ################################################################################
    # DISPATCH Command
    ################################################################################


    describe 'and dispatch command arrived' do
      before :each do
        @queued = Queued.new
        @client.stubs( :gets ).returns( 'dispatch USA-t.m-gr 1 10 957498 957498 19200797 13006257 4314559 17261435 8077810 3048748 21869636 13446936 18549540' )
      end


      it 'should dispatch a job' do
        @queued.expects( :dispatch ).with( @client, 'USA-t.m-gr',
                                           [ 957498 ], [ 957498, 19200797, 13006257, 4314559, 17261435, 8077810, 3048748, 21869636, 13446936, 18549540 ] ).once
        @queued.start
      end


      it "should return 'OK' string if job succeeded" do
        shell = 'SHELL'
        Popen3::Shell.stubs( :open ).yields( shell )
        shell.stubs( :on_stdout )
        shell.stubs( :on_stderr )
        shell.stubs( :on_success ).yields
        shell.stubs( :on_failure )
        shell.stubs( :exec )

        @client.expects( :puts ).with( 'OK' ).once

        dummy_job = 'DUMMY JOB'
        dummy_job.stubs( :sp_command )
        dummy_job.stubs( :merge_command )
        Job.stubs( :new ).with( 'USA-t.m-gr', [ 957498 ],
                                [ 957498, 19200797, 13006257, 4314559, 17261435, 8077810, 3048748, 21869636, 13446936, 18549540 ] ).returns( dummy_job )

        @queued.start
      end


     it "should return 'FAILED' string if job failed" do
        shell = 'SHELL'
        Popen3::Shell.stubs( :open ).yields( shell )
        shell.stubs( :on_stdout )
        shell.stubs( :on_stderr )
        shell.stubs( :on_success )
        shell.stubs( :on_failure ).yields
        shell.stubs( :exec )

        @client.expects( :puts ).with( 'FAILED' ).once

        dummy_job = 'DUMMY JOB'
        dummy_job.stubs( :sp_command )
        dummy_job.stubs( :merge_command )
        Job.stubs( :new ).with( 'USA-t.m-gr', [ 957498 ],
                                [ 957498, 19200797, 13006257, 4314559, 17261435, 8077810, 3048748, 21869636, 13446936, 18549540 ] ).returns( dummy_job )

        @queued.start
     end
    end


    it "should exit when 'quit' command arrived" do
      @client.expects( :gets ).returns( 'quit' )
      
      queued = Queued.new
      lambda do
        queued.start
      end.should raise_error( SystemExit )
    end


    ################################################################################
    # UNKNOWN Command
    ################################################################################


    describe 'and unknown command arrived' do
      it "should return 'FAILED' string" do
        queued = Queued.new
        @client.stubs( :gets ).returns( 'UNKNOWN COMMAND' )
        @client.expects( :puts ).with( 'FAILED' ).once
        queued.start
      end
    end
  end
end
