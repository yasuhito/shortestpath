# -*- coding: utf-8 -*-
require 'cui'
require 'spec_helper'


describe CUI do
  before :each do
    # 表示がチラつかないようにする仕組みを発動させない
    sleep 1.1
  end


  it 'should clear terminal when updated' do
    Kernel.expects( :system ).with( 'tput clear' )
    Kernel.expects( :system ).with( 'tput cup 0 0' )

    CUI.update []
  end


  it 'should print out node status' do
    Kernel.stubs( :system )

    STDOUT.expects( :puts ).times( 2 )

    CUI.update [ 'NODE A', 'NODE B' ]
  end
end
