require 'command-builder'
require 'spec_helper'


describe CommandBuilder, 'when building a command' do
  it 'should have commandline string' do
    job = mock( 'JOB' ) do
      stubs( :ss ).returns 'SS'
      stubs( :command ).returns 'COMMAND'
    end
    Job.expects( :new ).with( 'GRAPH', 'SOURCE', 'DESTINATION' ).returns job

    command = CommandBuilder.build( 'NODE', 'GRAPH', 'SOURCE', 'DESTINATION' )

    command.should == "scp SS NODE:SS; ssh NODE 'COMMAND'"
  end
end

