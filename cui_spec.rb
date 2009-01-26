# -*- coding: utf-8 -*-
require 'cui'
require 'spec_helper'



describe CUI do
  before :each do
    Kernel.stubs :system
    Kernel.stubs :sleep
    STDOUT.stubs :puts
  end


  describe 'when initialized' do
    it 'should enter the main loop and resets terminal periodically when initialized' do
      Thread.expects( :start ).yields
      Kernel.expects( :loop ).yields

      Kernel.expects( :system ).with( 'tput clear' )
      Kernel.expects( :system ).with( 'tput cup 0 0' )

      cui = CUI.new( [ 'NODE A', 'NODE B' ] )
    end
  end


  describe 'when updated' do
    it 'should print out node status' do
      Thread.stubs( :start )
      cui = CUI.new( [ 'NODE A', 'NODE B' ] )

      STDOUT.expects( :puts ).times( 2 )

      cui.started 'NODE A'
      cui.finished 'NODE A'
      cui.started 'NODE A'
      cui.failed 'NODE A'

      cui.started 'NODE B'
      cui.finished 'NODE B'
      cui.started 'NODE B'

      cui.__send__( :update )
    end
  end
end
