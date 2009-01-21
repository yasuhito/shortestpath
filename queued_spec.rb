# -*- coding: utf-8 -*-
require 'job'
require 'queued'
require 'spec_helper'


describe Queued do
  before :each do
    @queued = Queued.new

    STDOUT.stubs :puts

    dummy_log = mock( 'LOG' ) do
      stubs :puts
      stubs :flush
    end
    File.stubs( :open ).with( Queued::LOG_PATH, 'w' ).returns( dummy_log )
  end


  describe 'when starting' do
    it 'should exit if cannnot open port' do
      TCPServer.stubs( :open ).with( Queued::PORT ).raises( 'SOCKET OPEN ERROR' )

      lambda do
        @queued.start
      end.should raise_error( SystemExit )
    end
  end


  describe 'when accepting a command' do
    before :each do
      @client = mock( 'CLIENT' )
      socket = mock( 'SOCKET', :accept => @client ) do
        stubs( :addr ).returns [ "AF_INET", Queued::PORT, "host.domain", "192.168.0.1" ]
      end
      Kernel.stubs( :loop ).yields
      TCPServer.stubs( :open ).with( Queued::PORT ).returns( socket )
      Thread.stubs( :start ).with( @client ).yields( @client )
    end


    ################################################################################
    # DISPATCH Command
    ################################################################################

    
    describe 'and dispatch command arrived' do
      before :each do
        @client.stubs( :gets ).returns( 'dispatch USA-t.m-gr 1 2 957498 957498 19200797' )

        @shell = mock( 'SHELL' ) do
          stubs :on_stdout
          stubs :on_stderr
          stubs :on_success
          stubs :on_failure
          stubs :exec
        end
        Popen3::Shell.stubs( :open ).yields( @shell )

        # [FIXME] ノード名が決め打ち
        CommandBuilder.stubs( :build ).with( 'ec2-72-44-39-169.compute-1.amazonaws.com', 'USA-t.m-gr', [ 957498 ], [ 957498, 19200797 ] )
      end


      it 'should dispatch a job' do
        @queued.expects( :dispatch ).with( @client, 'USA-t.m-gr', [ 957498 ], [ 957498, 19200797 ] )

        @queued.start
      end


      it 'should redirect stdout to client' do
        @shell.stubs( :on_stdout ).yields( 'STDOUT' )
        @client.expects( :puts ).with( 'STDOUT' ).once

        @queued.start
      end


      it 'should redirect stderr to client' do
        @shell.stubs( :on_stderr ).yields( 'STDERR' )
        @client.expects( :puts ).with( 'STDERR' ).once

        @queued.start
      end


      it "should return 'OK' string if job succeeded" do
        @shell.stubs( :on_success ).yields
        @client.expects( :puts ).with( 'OK' ).once

        @queued.start
      end


      it "should return 'FAILED' string if job failed" do
        @shell.stubs( :on_failure ).yields
        @client.expects( :puts ).with( 'FAILED' ).once

        @queued.start
      end
    end


    ################################################################################
    # QUIT Command
    ################################################################################


    it "should exit when received 'quit' command" do
      @client.expects( :gets ).returns( 'quit' )
      
      lambda do
        @queued.start
      end.should raise_error( SystemExit )
    end


    ################################################################################
    # UNKNOWN Command
    ################################################################################


    it "should return 'FAILED' string if received unknown command" do
      @client.stubs( :gets ).returns( 'UNKNOWN COMMAND' )

      @client.expects( :puts ).with( 'FAILED' ).once
      
      @queued.start
    end
  end
end
