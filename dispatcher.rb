# -*- coding: utf-8 -*-
require 'command-builder'
require 'cui'
require 'node-list'
require 'popen3'
require 'pshell'


class Dispatcher
  def initialize nodes, logger
    @clients = []
    @nodes = nodes
    @logger = logger
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

      shell.on_stdout do | line |
        png = $1 if /\AOK PNG=(.+)/=~ line
        @logger.log line
      end

      shell.on_stderr do | line |
        @logger.log line
      end

      shell.on_success do
        ok client, "#{ node }:#{ png }"
        @nodes.deallocate_from client
        CUI.finished node
        client.close
      end

      shell.on_failure do
        failed client
        @nodes.deallocate_from client
        CUI.failed node
        client.close
      end

      begin
        command = CommandBuilder.build( node, graph, source, destination )
      rescue
        settle_invalid_request client, node
        return
      end

      CUI.started node
      @logger.log command
      shell.exec command
    end
  end
end
