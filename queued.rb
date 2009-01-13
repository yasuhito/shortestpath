require 'job'
require 'popen3'
require 'pshell'


class Queued
  PORT = 7838


  def initialize
    @log = File.open( '/tmp/queued.log', 'w' )
  end


  def start
    socket = open_socket

    Kernel.loop do
      Thread.start( socket.accept ) do | client |
        command = client.gets.chomp
        log command
        
        case command
        when /dispatch (\S+) (\d+) (\d+) (.+)/
          log "DISPATCH COMMAND"

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
    job = Job.new( graph, source, destination )
    Popen3::Shell.open do | shell |
      shell.on_stdout do | line |
        # client.puts line
      end
      shell.on_stderr do | line |
        # log "WARN [#{ fits }]: #{ line }"
      end
      shell.on_success do
        ok client
      end
      shell.on_failure do
        failed client
      end

      command = [ job.command, job.merge_command ].join( ';' )
      log command
      shell.exec command
    end
  end


  def ok client
    client.puts 'OK'
  end


  def failed client
    client.puts 'FAILED'
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


  def log message
    @log.puts "#{ Time.now }: #{ message }"
    @log.flush
  end
end
