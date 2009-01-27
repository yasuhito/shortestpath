require 'job'
require 'spec_helper'


describe Job do
  before :each do
    @job = Job.new( './USA-t.m-gr', [ 1 ], [ 2, 3 ] )
  end


  describe 'when instantiated' do
    it 'should create .ss file' do
      @job.ss.should match( /.+\.ss\Z/ )
      FileTest.exists?( @job.ss ).should be_true
    end


    it 'should raise if invalid graph path specified' do
      lambda do
        Job.new './INVALID_GRAPH', [ 1 ], [ 2, 3 ]
      end.should raise_error( RuntimeError, 'graph file name should have .m-gr suffix' )
    end


    it 'should raise if the source set has nil element' do
      lambda do
        Job.new './USA-t.m-gr', [ 1, nil ], [ 2, 3 ]
      end.should raise_error( RuntimeError, 'invalid query [1, nil]' )
    end


    it 'should raise if the destination set has nil element' do
      lambda do
        Job.new './USA-t.m-gr', [ 1 ], [ 2, nil, 3 ]
      end.should raise_error( RuntimeError, 'invalid query [2, nil, 3]' )
    end
  end


  describe 'when executing a job' do
    it 'should know commandline string' do
      # should exec sp.heap and merge_ssout, then convert
      @job.command.should match( /sp\.heap.+merge_ssout.+convert/ )
    end
  end
end
