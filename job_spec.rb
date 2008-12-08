require 'job'


describe Job, 'when starting a SP job' do
  before :each do
    @job = Job.new( 123.456, 987.654 )
    @dummy_shell = 'SHELL'
    Popen3::Shell.stubs( :open ).yields( @dummy_shell )
  end


  it 'should run SP program' do
    @dummy_shell.stubs( :on_failure )

    @dummy_shell.expects( :exec ).with( 'sp 123.456 987.654' ).once

    @job.run
  end


  it 'should NOT raise if the SP job succeeded' do
    @dummy_shell.stubs( :on_failure )
    @dummy_shell.stubs( :exec )

    lambda do
      @job.run
    end.should_not raise_error
  end


  it 'should raise if the SP job failed' do
    @dummy_shell.expects( :on_failure ).yields

    lambda do
      @job.run
    end.should raise_error( %{Command "sp 123.456 987.654" failed.} )
  end
end
