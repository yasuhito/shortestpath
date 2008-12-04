require 'job'


describe Job do
  it 'should know commandline string' do
    job = Job.new
    job.cmd.should == 'sp.heap' 
  end
end
