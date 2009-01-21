require 'command-builder'
require 'spec_helper'


describe CommandBuilder, 'when building a command' do
  it 'should have commandline string' do
    job = 'JOB'
    job.stubs( :command ).returns 'COMMAND'
    Job.expects( :new ).with( 'GRAPH', 'SOURCE', 'DESTINATION' ).returns job

    command = CommandBuilder.build( 'NODE', 'GRAPH', 'SOURCE', 'DESTINATION' )

    command.should == "ssh NODE 'COMMAND'"
  end
end

