require 'job'
require 'spec_helper'


describe Job do
  describe 'when executing a job' do
    before :each do
      @job = Job.new( './USA-t.m-gr', [ 1 ], [ 2, 3 ] )
    end


    it 'should know commandline string' do
      # should exec sp.heap and merge_ssout, then convert
      @job.command.should match( /sp\.heap.+merge_ssout.+convert/ )
    end


    it 'should create .ss file' do
      @job.ss.should match( /.+\.ss\Z/ )
      FileTest.exists?( @job.ss ).should be_true
    end
  end


  describe 'when invalid graph file name passed' do
    it 'should raise error' do
      lambda do
        Job.new './INVALID_GRAPH', [ 1 ], [ 2, 3 ]
      end.should raise_error( RuntimeError, 'graph file name should have .m-gr suffix' )
    end
  end


  describe 'when invalid query arrived' do
    it 'should raise error' do
      lambda do
        Job.new './USA-t.m-gr', [ 1, nil ], [ 2, 3 ]
      end.should raise_error( RuntimeError, 'invalid query [1, nil]' )
      
      lambda do
        Job.new './USA-t.m-gr', [ 1 ], [ 2, nil, 3 ]
      end.should raise_error( RuntimeError, 'invalid query [2, nil, 3]' )
    end
  end
end
