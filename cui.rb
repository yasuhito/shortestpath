# -*- coding: utf-8 -*-
require 'color'


class CUI
  def initialize nodes
    @node_state = {}
    @last_node_state = {}
    @nodes = nodes.sort.uniq
    @nodes.each do | each |
      @node_state[ each ] = []
    end
    @mutex = Mutex.new
  end


  def start
    Thread.start do
      Kernel.loop do
        Kernel.sleep 1
        update
      end
    end
  end


  def failed node
    @mutex.synchronize do
      @node_state[ node ].each_with_index do | each, index |
        if each == :started
          @node_state[ node ][ index ] = :failed
          return
        end
      end
      raise "We shouldn't reach here!"
    end
  end


  def started node
    @mutex.synchronize do
      @node_state[ node ] += [ :started ]
    end
  end


  def finished node
    @mutex.synchronize do
      @node_state[ node ].each_with_index do | each, index |
        if each == :started
          @node_state[ node ][ index ] = :finished
          return
        end
      end
      raise "We shouldn't reach here!"
    end
  end


  ################################################################################
  private
  ################################################################################


  def update
    @mutex.synchronize do
      return unless status_changed?

      @last_node_state = @node_state.dup
      reset
      @nodes.each do | node |
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
    end
  end


  def status_changed?
    @last_node_state != @node_state
  end


  def reset
    Kernel.system 'tput clear'
    Kernel.system 'tput cup 0 0'
  end
end
