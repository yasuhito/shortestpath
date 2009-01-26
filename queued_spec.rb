# -*- coding: utf-8 -*-
require 'job'
require 'queued'
require 'spec_helper'


describe Queued do
  before :each do
    STDOUT.stubs :puts

    @dispatcher = mock( 'DISPATCHER' )
    Dispatcher.stubs( :new ).returns( @dispatcher )

    dummy_log = mock( 'LOG' ) do
      stubs :info
      stubs :error
      stubs :debug
    end
    Logger.stubs( :new ).with( Queued::LOG_PATH ).returns( dummy_log )

    @queued = Queued.new( [ 'ec2-72-44-39-169.compute-1.amazonaws.com',
                            'ec2-75-101-252-236.compute-1.amazonaws.com',
                            'ec2-174-129-148-3.compute-1.amazonaws.com' ] )
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
      @client = mock( 'CLIENT' ) do
        stubs :close
      end
      socket = mock( 'SOCKET', :accept => @client ) do
        stubs( :addr ).returns [ "AF_INET", Queued::PORT, "host.domain", "192.168.0.1" ]
      end
      Kernel.stubs( :loop ).yields
      TCPServer.stubs( :open ).with( Queued::PORT ).returns( socket )
      Thread.stubs( :start ).with( @client ).yields( @client )
    end


    it 'should delegate job to dispatcher' do
      @client.stubs( :gets ).returns( 'dispatch USA-t.m-gr 1 2 957498 957498 19200797' )

      @dispatcher.expects( :dispatch ).with( @client, 'USA-t.m-gr', [ 957498 ], [ 957498, 19200797 ] )

      @queued.start
    end


    it "should exit when received 'quit' command" do
      @client.expects( :gets ).returns( 'quit' )
      
      lambda do
        @queued.start
      end.should raise_error( SystemExit )
    end


    it "should return 'FAILED' if unknown command received" do
      @client.stubs( :gets ).returns( 'UNKNOWN COMMAND' )

      @client.expects( :puts ).with( "FAILED Invalid request 'UNKNOWN COMMAND'" ).once
      
      @queued.start
    end
  end
end
