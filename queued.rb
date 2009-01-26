# -*- coding: utf-8 -*-
require 'dispatcher'
require 'logger'


class Queued
  PORT = 7838
  LOG_PATH = '/tmp/queued.log'


  def initialize node_list
    @logger = Logger.new( LOG_PATH )
    @dispatcher = Dispatcher.new( NodeList.new( node_list ), @logger )
    STDOUT.puts "#{ node_list.size } nodes: (#{ node_list.join( ', ' )})"
  end


  def start
    socket = open_socket
    STDOUT.puts "Queued started port = #{ PORT }"

    Kernel.loop do
      Thread.start( socket.accept ) do | client |
        command = client.gets.chomp
        
        case command
        when /dispatch (\S+) (\d+) (\d+) (.+)/
          graph = $1
          source = []
          destination = []

          points = $4.split( ' ' )
          $2.to_i.times do
            source << points.shift.to_i
          end
          $3.to_i.times do
            destination << points.shift.to_i
          end
          @dispatcher.dispatch client, graph, source, destination
        when /quit/
          client.close
          exit 0
        else # FAILED
          msg = "FAILED Invalid request '#{ command }'"
          @logger.error msg
          client.puts msg
          client.close
        end
      end
    end
  end


  ################################################################################
  private
  ################################################################################


  def open_socket
    begin
      socket = TCPServer.open( PORT )
    rescue
      @logger.error $!.to_s
      $!.backtrace.each do | each |
        @logger.debug each
      end
      exit -1
    end
    socket
  end
end
