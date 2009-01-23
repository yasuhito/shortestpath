# -*- coding: utf-8 -*-
require 'dispatcher'
require 'spec_helper'


describe Dispatcher do
  before :each do
    @logger = mock( 'LOGGER' ) do
      stubs :log
    end
    STDOUT.stubs( :puts )
    @client = mock( 'CLIENT' )
    @nodes = NodeList.new( [ 'NODE_A', 'NODE_B', 'NODE_C' ] )
    @dispatcher = Dispatcher.new( @nodes, @logger )
  end

 
  describe 'when queue is full' do
    before :each do
      @nodes.stubs( :empty? ).returns( true )
    end


    it "should send 'FAILED' then close connection" do
      @client.expects( :puts ).with( 'FAILED Queue is full' )
      @client.expects( :close )

      @dispatcher.dispatch @client, 'USA-t.m-gr', [ 957498 ], [ 957498, 19200797 ]
    end
  end


  describe 'when queue is not full' do
    before :each do
      @nodes.stubs( :empty? ).returns( false )
    end


    it 'should allocate a node' do
      @nodes.expects( :allocate_to ).with( @client ).returns( 'NODE' )
      @dispatcher.expects( :exec ).with( 'NODE', @client, 'USA-t.m-gr', [ 957498 ], [ 957498, 19200797 ] )

      @dispatcher.dispatch @client, 'USA-t.m-gr', [ 957498 ], [ 957498, 19200797 ]
    end


    describe 'and executing a job' do
      before :each do
        @nodes.stubs( :allocate_to ).returns( 'NODE' )

        @shell = mock( 'SHELL' ) do
          stubs( :on_stdout ).yields( 'OK PNG=/PATH/FILENAME.PNG' )
          stubs :on_stderr
          stubs :on_success
          stubs :on_failure
          stubs :exec
        end
        Popen3::Shell.stubs( :open ).yields( @shell )

        CommandBuilder.stubs( :build ).returns( 'COMMAND' )
      end


      it 'should log stderr' do
        @shell.stubs( :on_stderr ).yields( 'STDERR' )
        
        @logger.expects( :log ).with( 'STDERR' )
        
        @dispatcher.dispatch @client, 'USA-t.m-gr', [ 957498 ], [ 957498, 19200797 ]
      end


      it "should return 'OK NODE_NAME:PNG_PATH' then close connection if succeeded" do
        @shell.stubs( :on_success ).yields

        @client.expects( :puts ).with( 'OK NODE:/PATH/FILENAME.PNG' )
        @client.expects( :close )

        @dispatcher.dispatch @client, 'USA-t.m-gr', [ 957498 ], [ 957498, 19200797 ]
      end


      it "should return 'FAILED' then close connection if failed" do
        @shell.stubs( :on_failure ).yields

        @client.expects( :puts ).with( 'FAILED' )
        @client.expects( :close )

        @dispatcher.dispatch @client, 'USA-t.m-gr', [ 957498 ], [ 957498, 19200797 ]
      end


      it "should return 'FAILED' then close connection if job description was invalid" do
        CommandBuilder.stubs( :build ).raises( 'INVALID JOB' )

        @client.expects( :puts ).with( 'FAILED Invalid request' )
        @client.expects( :close )
        
        @dispatcher.dispatch @client, 'USA-t.m-gr', [ 957498 ], [ 957498, 19200797 ]
      end
    end
  end
end
