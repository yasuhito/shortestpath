require 'jobs'


describe Jobs do
  it 'should assign a job' do
    lambda do
      Jobs.assign 'TEST JOB'
      Jobs.assigned?( 'TEST JOB' ).should be_true
    end.should_not raise_error
  end
end
