require 'queued'
require 'spec_helper'


describe Queued do
  describe 'when starting' do
    it 'should log and exit if cannnot open port' do
      dummy_log = 'DUMMY LOG'
      dummy_log.expects( :puts ).at_least_once
      dummy_log.expects( :flush ).at_least_once
      File.expects( :open ).with( '/tmp/queued.log', 'w' ).once.returns( dummy_log )

      TCPServer.stubs( :open ).with( 78383 ).raises( 'SOCKET OPEN ERROR' )

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
      TCPServer.stubs( :open ).with( 78383 ).returns( socket )
      Thread.stubs( :start ).with( @client ).yields( @client )
    end


    describe 'and dispatch command arrived' do
      before :each do
        @queued = Queued.new
        @client.stubs( :gets ).returns( 'dispatch' )
      end


      it 'should dispatch a job' do
        @queued.expects( :dispatch ).with( @client ).once
        @queued.start
      end


      it "should send 'OK' if job succeeded" do
        @client.expects( :puts ).with( 'OK' ).once
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
  end
end
