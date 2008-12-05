class Queued
  PORT = 78383


  def initialize
    @log = File.open( '/tmp/queued.log', 'w' )
  end


  def start
    open_socket
  end


  ################################################################################
  private
  ################################################################################


  def open_socket
    begin
      @socket = TCPServer.open( PORT )
    rescue
      log $!.to_s
      $!.backtrace.each do | each |
        log each
      end
      exit -1
    end
  end


  def log message
    @log.puts "#{ Time.now }: #{ message }"
    @log.flush
  end
end
