class Queued
  PORT = 78383


  def initialize
    @log = File.open( '/tmp/queued.log', 'w' )
  end


  def start
    socket = open_socket

    Kernel.loop do
      Thread.start( socket.accept ) do | s |
        command = s.gets.chomp
        case command
        when /dispatch/
          dispatch
        when /quit/
          exit 0
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
