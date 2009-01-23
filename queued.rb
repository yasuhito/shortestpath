# -*- coding: utf-8 -*-
require 'dispatcher'


class Queued
  class Logger
    PATH = '/tmp/queued.log'


    def initialize
      @log = File.open( PATH, 'w' )
    end


    def log message
      @log.puts "#{ Time.now }: #{ message }"
      @log.flush
    end


    def log_and_msg message
      log message
      STDOUT.puts message
    end
  end


  PORT = 7838


  def initialize node_list
    @logger = Logger.new
    @dispatcher = Dispatcher.new( NodeList.new( node_list ), @logger )
    STDOUT.puts "#{ node_list.size } nodes: (#{ node_list.join( ', ' )})"
  end


  def start
    socket = open_socket
    @logger.log_and_msg "Queued started on #{ socket.addr[ 2 ] }, port = #{ PORT }"

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
          @logger.log_and_msg msg
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
      @logger.log $!.to_s
      $!.backtrace.each do | each |
        @logger.log each
      end
      exit -1
    end
    socket
  end
end
