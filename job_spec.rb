require 'job'
require 'spec_helper'


describe Job do
  describe 'when invalid graph file name passed' do
    it 'should raise error' do
      lambda do
        Job.new './INVALID_GRAPH', [ 1 ], [ 2, 3 ]
      end.should raise_error( RuntimeError, 'graph file name should have .m-gr suffix' )
    end
  end


  describe 'when .m-gr file not found' do
    it 'should raise error' do
      lambda do
        Job.new './NO_SUCH.m-gr', [ 1 ], [ 2, 3 ]
      end.should raise_error( RuntimeError, 'graph file ./NO_SUCH.m-gr does not exist!' )
    end
  end


  describe 'when .m-gr file exists' do
    before :each do
      FileTest.stubs( :exist? ).returns( true ) 
    end


    describe 'and invalid query arrived' do
      it 'should raise error' do
        lambda do
          Job.new './USA-t.m-gr', [ 957498, nil ], [ 957498, 13006257 ]
        end.should raise_error( RuntimeError, 'invalid query [957498, nil]' )

        lambda do
          Job.new './USA-t.m-gr', [ 957498 ], [ 957498, nil, 13006257 ]
        end.should raise_error( RuntimeError, 'invalid query [957498, nil, 13006257]' )
      end
    end


    describe 'and executing a job' do
      it 'should know SP command' do
        job = Job.new( './USA-t.m-gr', [ 957498 ], [ 957498, 19200797 ] )
        job.sp_command.should match( /sp\.heap \.\/USA\-t\.m\-gr \S+\.ss \S+\.out\-p/ )
      end


      it 'should know merge command' do
        job = Job.new( './USA-t.m-gr', [ 957498 ], [ 957498, 19200797 ] )
        job.merge_command.should match( /merge_ssout \.\/USA\-t\.m\-gr \.\/USA\.m\-co \S+\.ss \S+\.out\-p \S+\.eps/ )
      end
    end
  end
end
