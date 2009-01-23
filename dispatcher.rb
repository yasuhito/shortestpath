# -*- coding: utf-8 -*-
require 'command-builder'
require 'cui'
require 'node-list'
require 'popen3'
require 'pshell'


class Dispatcher
  def initialize node_list, logger
    @clients = []
    @mutex = Mutex.new
    @node_list = NodeList.new( node_list )
    puts "#{ @node_list.list.size } nodes: (#{ @node_list.list.join( ', ' )})"
    @max_size = node_list.size
    @logger = logger
  end


  def dispatch client, graph, source, destination
    @mutex.synchronize do
      if @clients.size >= max_size
        failed client, 'Queue is full'
        client.close
        return
      end
      add_client client
    end
    exec client, graph, source, destination
  end


  ################################################################################
  private
  ################################################################################


  def max_size
    @max_size
  end


  def add_client client
    @clients << client
  end


  def remove_client client
    @clients -= [ client ]
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


  def exec client, graph, source, destination
    node = nil
    Popen3::Shell.open do | shell |
      @mutex.synchronize do
        node = @node_list.get
      end
      png = nil

      shell.on_stdout do | line |
        png = $1 if /\AOK (.+)/=~ line
        @logger.log line
      end

      shell.on_stderr do | line |
        @logger.log line
      end

      shell.on_success do
        ok client, "#{ node }:#{ png }"
        @mutex.synchronize do
          @node_list.add node
          remove_client client
          CUI.finished node
        end
        client.close
      end

      shell.on_failure do
        failed client
        @mutex.synchronize do
          @node_list.add node
          remove_client client
        end
        client.close
      end

      begin
        command = CommandBuilder.build( node, graph, source, destination )
      rescue
        @logger.log $!.to_s
        failed client, 'Invalid request'
        @mutex.synchronize do
          @node_list.add node
          remove_client client
        end
        client.close
        $!.backtrace.each do | each |
          @logger.log each
        end
        return
      end

      @mutex.synchronize do
        CUI.started node
      end
      @logger.log command
      shell.exec command
    end
  end
end
