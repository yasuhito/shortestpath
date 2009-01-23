require 'dispatcher'
require 'spec_helper'


describe Dispatcher do
  before :each do
    @logger = mock( 'LOGGER' ) do
      stubs :log
      stubs :log_and_msg
    end
    STDOUT.stubs( :puts )
    @client = mock( 'CLIENT' )
    @dispatcher = Dispatcher.new( NodeList.new( [ 'NODE_A', 'NODE_B', 'NODE_C' ] ), @logger )
  end

 
  describe 'when queue is full' do
    it 'should close connection' do
      @dispatcher.stubs( :max_queue_size ).returns( 0 )

      @client.expects( :puts ).with( 'FAILED Queue is full' )
      @client.expects( :close )

      @dispatcher.dispatch @client, 'USA-t.m-gr', [ 957498 ], [ 957498, 19200797 ]
    end
  end


  describe 'when queue is not full' do
    before :each do
      @dispatcher.stubs( :exec )
    end


    it 'should keep a client list' do
      @dispatcher.expects( :allocate_node_to ).with( @client )

      @dispatcher.dispatch @client, 'USA-t.m-gr', [ 957498 ], [ 957498, 19200797 ]
    end


    it 'should execute a job' do
      @dispatcher.expects( :exec ).with( @client, 'USA-t.m-gr', [ 957498 ], [ 957498, 19200797 ] )

      @dispatcher.dispatch @client, 'USA-t.m-gr', [ 957498 ], [ 957498, 19200797 ]
    end
  end


  describe 'when job description was invalid' do
    it "should return 'FAILED'" do
      CommandBuilder.stubs( :build ).raises( 'INVALID JOB' )

      @client.expects( :puts ).with( 'FAILED Invalid request' )
      @client.expects( :close )

      @dispatcher.dispatch @client, 'USA-t.m-gr', [ 957498 ], [ 957498, 19200797 ]
    end
  end


  describe 'when job being executed' do
    before :each do
      @shell = mock( 'SHELL' ) do
        stubs( :on_stdout ).yields( 'OK PNG=/PATH/FILENAME.PNG' )
        stubs :on_stderr
        stubs :on_success
        stubs :on_failure
        stubs :exec
      end
      Popen3::Shell.stubs( :open ).yields( @shell )

      CommandBuilder.stubs( :build )
    end


    it 'should log stderr' do
      @shell.stubs( :on_stderr ).yields( 'STDERR' )

      @logger.expects( :log ).with( 'STDERR' )

      @dispatcher.dispatch @client, 'USA-t.m-gr', [ 957498 ], [ 957498, 19200797 ]
    end


    it "should return 'OK' if succeeded" do
      @shell.stubs( :on_success ).yields

      @client.expects( :puts ).with( 'OK NODE_A:/PATH/FILENAME.PNG' )
      @client.expects( :close )

      @dispatcher.dispatch @client, 'USA-t.m-gr', [ 957498 ], [ 957498, 19200797 ]
    end


    it "should return 'FAILED' if failed" do
      @shell.stubs( :on_failure ).yields

      @client.expects( :puts ).with( 'FAILED' )
      @client.expects( :close )

      @dispatcher.dispatch @client, 'USA-t.m-gr', [ 957498 ], [ 957498, 19200797 ]
    end
  end
end
