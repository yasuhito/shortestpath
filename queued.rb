# -*- coding: utf-8 -*-
require 'command-builder'
require 'node-list'
require 'popen3'
require 'pshell'


class Queued
  PORT = 7838
  LOG_PATH = '/tmp/queued.log'


  def initialize node_list
    @log = File.open( LOG_PATH, 'w' )
    @node_list = NodeList.new( node_list )
  end


  def start
    socket = open_socket
    log_and_msg "Queued started on #{ socket.addr[ 2 ] }, port = #{ PORT }"

    Kernel.loop do
      Thread.start( socket.accept ) do | client |
        command = client.gets.chomp
        log command
        
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
          dispatch client, graph, source, destination
        when /quit/
          exit 0
        else # FAILED
          failed client, "Invalid request '#{ command }'"
        end

        client.close
      end
    end
  end


  ################################################################################
  private
  ################################################################################


  def dispatch client, graph, source, destination
    Popen3::Shell.open do | shell |
      node = @node_list.get_node
      png = nil

      shell.on_stdout do | line |
        png = $1 if /\AOK (.+)/=~ line
        client.puts line
      end
      shell.on_stderr do | line |
        client.puts line
      end
      shell.on_success do
        ok client, "#{ node }:#{ png }"
      end
      shell.on_failure do
        failed client
      end

      begin
        command = CommandBuilder.build( node, graph, source, destination )
      rescue
        failed client, $!.to_s
        $!.backtrace.each do | each |
          log each
        end
        return
      end

      log_and_msg command
      shell.exec command
    end
  end


  def ok client, message = nil
    msg = message ? "OK #{ message }" : 'OK'
    log_and_msg msg
    client.puts msg
  end


  def failed client, message = nil
    msg = message ? "FAILED #{ message }" : 'FAILED'
    log_and_msg msg
    client.puts msg
  end


  def open_socket
    begin
      socket = TCPServer.open( PORT )
    rescue
      log $!.to_s
      $!.backtrace.each do | each |
        log each
      end
      exit -1
    end
    socket
  end


  def log_and_msg message
    log message
    STDOUT.puts message
  end


  def log message
    @log.puts "#{ Time.now }: #{ message }"
    @log.flush
  end
end
