require 'job'


describe Job do
  it 'should know commandline string' do
    job = Job.new( 123.456, 987.654 )
    job.cmd.should == 'sp.heap' 
  end
end
