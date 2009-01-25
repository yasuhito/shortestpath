# -*- coding: utf-8 -*-
require 'command-builder'
require 'cui'
require 'fileutils'
require 'node-list'
require 'popen3'
require 'pshell'


class Dispatcher
  def initialize nodes, logger
    @clients = []
    @nodes = nodes
    @logger = logger
    @cui = CUI.new( @nodes.to_ary )
  end


  def dispatch client, graph, source, destination
    if queue_full?
      failed client, 'Queue is full'
      client.close
      return
    end
    node = @nodes.allocate_to( client )
    exec node, client, graph, source, destination
  end


  ################################################################################
  private
  ################################################################################


  def queue_full?
    @nodes.empty?
  end


  def failed client, message = nil
    msg = message ? "FAILED #{ message }" : 'FAILED'
    @logger.log msg
    client.puts msg
  end


  def ok client, message = nil
    msg = message ? "OK #{ message }" : 'OK'
    @logger.log msg
    client.puts msg
  end


  def settle_invalid_request client, node
    @logger.log $!.to_s
    failed client, 'Invalid request'
    @nodes.deallocate_from client
    client.close
    $!.backtrace.each do | each |
      @logger.log each
    end
  end


  def exec node, client, graph, source, destination
    Popen3::Shell.open do | shell |
      png = nil
      command = nil

      begin
        command = CommandBuilder.build( node, graph, source, destination )
      rescue
        settle_invalid_request client, node
        return
      end

      shell.on_stdout do | line |
        ( /\AOK PNG=(.+)/=~ line ) ? png = $1 : @logger.log( line )
      end

      shell.on_stderr do | line |
        @logger.log line
      end

      shell.on_success do
        ok client, "#{ node }:#{ png }"
        @nodes.deallocate_from client
        @cui.finished node
        client.close
      end

      shell.on_failure do
        failed client
        @nodes.deallocate_from client
        @cui.failed node
        client.close
      end

      @cui.started node
      @logger.log command.to_str
      shell.exec command.to_str
    end
  end
end
