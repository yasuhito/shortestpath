require 'command-builder'
require 'spec_helper'


describe CommandBuilder, 'when building a command' do
  it 'should return a commandline string' do
    Job.expects( :new ).with( 'GRAPH', 'SOURCE', 'DESTINATION' ).returns job_mock

    command = CommandBuilder.build( 'NODE', 'GRAPH', 'SOURCE', 'DESTINATION' )

    command.should == "scp SS NODE:SS && ssh NODE 'COMMAND' && ssh NODE 'rm SS'"
  end


  def job_mock
    mock( 'JOB' ) do
      stubs( :ss ).returns 'SS'
      stubs( :command ).returns 'COMMAND'
    end
  end
end

