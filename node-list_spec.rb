require 'node-list'
require 'spec_helper'


describe NodeList do
  it 'should have empty node list at first' do
    nodes = NodeList.new( [] )
    nodes.should be_empty
  end


  describe 'when (de)allocating jobs' do
    it 'should allocate available node' do
      nodes = NodeList.new( [ 'NODE A', 'NODE B', 'NODE C' ] )

      nodes.allocate_to( 'CLIENT A' ).should == 'NODE A'
      nodes.allocate_to( 'CLIENT B' ).should == 'NODE B'
      nodes.allocate_to( 'CLIENT C' ).should == 'NODE C'
      nodes.allocate_to( 'CLIENT D' ).should be_nil
      nodes.should be_empty

      nodes.deallocate_from( 'CLIENT A' ).should == 'NODE A'
      nodes.deallocate_from( 'CLIENT B' ).should == 'NODE B'
      nodes.deallocate_from( 'CLIENT C' ).should == 'NODE C'
      nodes.deallocate_from( 'CLIENT D' ).should be_nil
      nodes.should_not be_empty
    end
  end
end
