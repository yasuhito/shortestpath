# -*- coding: utf-8 -*-
require 'command-builder'
require 'node-list'
require 'popen3'
require 'pshell'


class Queued
  PORT = 7838
  LOG_PATH = '/tmp/queued.log'


  def initialize
    @log = File.open( LOG_PATH, 'w' )
    # [FIXME] ノードのリストが決め打ち
    @node_list = NodeList.new( [ 'ec2-72-44-39-169.compute-1.amazonaws.com',
                                 'ec2-75-101-252-236.compute-1.amazonaws.com',
                                 'ec2-174-129-148-3.compute-1.amazonaws.com' ] )
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
          failed client
        end
      end
    end
  end


  ################################################################################
  private
  ################################################################################


  def dispatch client, graph, source, destination
    Popen3::Shell.open do | shell |
      shell.on_stdout do | line |
        client.puts line
      end
      shell.on_stderr do | line |
        client.puts line
      end
      shell.on_success do
        ok client
      end
      shell.on_failure do
        failed client
      end

      begin
        command = CommandBuilder.build( @node_list.get_node, graph, source, destination )
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


  def ok client
    client.puts 'OK'
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
