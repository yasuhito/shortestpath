class Queued
  PORT = 78383


  def initialize
    @log = File.open( '/tmp/queued.log', 'w' )
  end


  def start
    socket = open_socket

    Kernel.loop do
      Thread.start( socket.accept ) do | client |
        command = client.gets.chomp
        case command
        when /dispatch (\d+\.\d+) (\d+\.\d+)/
          dispatch client, $1.to_f, $2.to_f
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


  def dispatch client, coord1, coord2
    job = Job.new( coord1, coord2 )
    begin
      job.run
      # TODO: rescue and send 'FAILED'
    end
    ok client
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
