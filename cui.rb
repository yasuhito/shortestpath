# -*- coding: utf-8 -*-
require 'color'


class CUI
  def initialize
    @node_state = Hash.new( [] )
    @last_updated = Time.now
    @mutex = Mutex.new
  end


  def update
    now = Time.now
    return if update_freq_high?( now )

    reset_terminal

    @node_state.keys.sort.each do | node |
      status = @node_state[ node ].collect do | each |
        case each
        when :started
          Color.yellow '#'
        when :finished
          Color.slate '#'
        when :failed
          Color.pink '#'
        end
      end
      STDOUT.puts "#{ node }: #{ status }"
    end

    @last_updated = now
  end


  def failed node
    @mutex.synchronize do
      @node_state[ node ].pop
      @node_state[ node ] += [ :failed ]
      update
    end
  end


  def started node
    @mutex.synchronize do
      @node_state[ node ] += [ :started ]
      update
    end
  end


  def finished node
    @mutex.synchronize do
      @node_state[ node ].pop
      @node_state[ node ] += [ :finished ]
      update
    end
  end


  ################################################################################
  private
  ################################################################################


  def reset_terminal
    Kernel.system 'tput clear'
    Kernel.system 'tput cup 0 0'
  end


  def update_freq_high? now
     now - @last_updated < 0.2
  end
end
