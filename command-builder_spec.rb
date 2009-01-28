require 'command-builder'
require 'spec_helper'


describe CommandBuilder, 'when building a command' do
  it 'should return a valid commandline string' do
    Job.expects( :new ).with( 'GRAPH', 'SOURCE', 'DESTINATION' ).returns job_mock

    command = CommandBuilder.build( 'NODE', 'GRAPH', 'SOURCE', 'DESTINATION' )
    command.should == "scp SS NODE:SS && ssh NODE 'COMMAND' && ssh NODE 'rm SS EPS OUT-P'"
  end


  def job_mock
    mock( 'JOB' ) do
      stubs( :command ).returns 'COMMAND'
      stubs( :eps ).returns 'EPS'
      stubs( :ss ).returns 'SS'
      stubs( :out_p ).returns 'OUT-P'
    end
  end
end

