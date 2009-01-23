# -*- coding: utf-8 -*-
require 'cui'
require 'spec_helper'


describe CUI do
  before :each do
    @cui = CUI.new( [ 'NODE A', 'NODE B' ] )
    Kernel.stubs :system
    STDOUT.stubs :puts
  end


  it 'should clear terminal when updated' do
    @cui.stubs( :update_freq_high? ).returns( false )

    Kernel.expects( :system ).with( 'tput clear' )
    Kernel.expects( :system ).with( 'tput cup 0 0' )

    @cui.update
  end


  it 'should print out node status' do
    STDOUT.expects( :puts ).times( 2 )

    @cui.started 'NODE A'
    @cui.finished 'NODE A'
    @cui.started 'NODE A'
    @cui.failed 'NODE A'

    @cui.started 'NODE A'
    @cui.finished 'NODE B'
    @cui.started 'NODE B'

    @cui.stubs( :update_freq_high? ).returns( false )
    @cui.update
  end


  it 'should raise if unknown status was set' do
    lambda do
      @cui.update( { 'NODE A' => [ :unknown ] } )
    end.should raise_error
  end
end
