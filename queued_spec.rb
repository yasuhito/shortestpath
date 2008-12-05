require 'queued'
require 'spec_helper'


describe Queued do
  before :each do
    @queued = Queued.new
  end


  it 'should respond to quit command' do
    TCPServer.stubs( :open ).with( 78383 )

    @queued.start
  end


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
