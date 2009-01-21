require 'node-list'
require 'spec_helper'


describe NodeList do
  before :each do
    @node_list = NodeList.new
  end

 
  it 'should have empty node list' do
    @node_list.get_list.should be_empty
  end


  it 'should be initialized with node list' do
    node_list = NodeList.new( [ 'NODE A', 'NODE B', 'NODE C' ] )
    node_list.get_list == [ 'NODE A', 'NODE B', 'NODE C' ]
  end


  describe 'when adding a node' do
    it 'should hold a node list' do
      @node_list.add 'NODE A'
      @node_list.add 'NODE B'
      @node_list.add 'NODE C'

      @node_list.get_list.should == [ 'NODE A', 'NODE B', 'NODE C' ]
    end
  end


  describe NodeList, 'when dispatching a job' do
    it 'should return available node' do
      @node_list.add 'NODE A'
      @node_list.add 'NODE B'
      @node_list.add 'NODE C'

      @node_list.get_node.should == 'NODE A'
    end
  end
end
