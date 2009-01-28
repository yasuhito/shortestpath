# -*- coding: utf-8 -*-
require 'cui'
require 'spec_helper'



describe CUI do
  before :each do
    Kernel.stubs :system
    Kernel.stubs :sleep
    STDOUT.stubs :puts

    @cui = CUI.new( [ 'NODE A', 'NODE B' ] )
  end


  describe 'when started' do
    it 'should enter the main loop and resets terminal periodically' do
      Thread.expects( :start ).yields
      Kernel.expects( :loop ).yields

      Kernel.expects( :system ).with( 'tput clear' )
      Kernel.expects( :system ).with( 'tput cup 0 0' )

      @cui.start
    end
  end


  describe 'when updated' do
    before :each do
      Thread.stubs :start
    end


    it 'should print out node status' do
      STDOUT.expects( :puts ).times( 2 )

      @cui.started 'NODE A'
      @cui.finished 'NODE A'
      @cui.started 'NODE A'
      @cui.failed 'NODE A'

      @cui.started 'NODE B'
      @cui.finished 'NODE B'
      @cui.started 'NODE B'

      @cui.__send__ :update
    end


    it 'should raise if node status updated in invalid sequence' do
      lambda do
        @cui.failed 'NODE A'
      end.should raise_error( "We shouldn't reach here!" )

      lambda do
        @cui.finished 'NODE A'
      end.should raise_error( "We shouldn't reach here!" )
    end
  end
end
