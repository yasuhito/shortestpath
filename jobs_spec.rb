require 'jobs'


describe Jobs do
  before :each do
    Jobs.init
  end


  it 'should assign a job' do
    Jobs.assign 'TEST JOB'
    Jobs.assigned?( 'TEST JOB' ).should be_true
  end


  it 'should unassign a job' do
    Jobs.assign 'TEST JOB 1'
    Jobs.assign 'TEST JOB 2'
    Jobs.assign 'TEST JOB 3'

    Jobs.unassign 'TEST JOB 2'

    Jobs.list.should == [ 'TEST JOB 1', 'TEST JOB 3' ]
  end
end
