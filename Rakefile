require 'rubygems'

require 'net/telnet'
require 'queued'
require 'rake/clean'
require 'spec'
require 'spec/rake/spectask'
require 'spec/rake/verify_rcov'
require 'thread_pool'


task :default => :verify_rcov
task :verify_rcov => :spec
RCov::VerifyTask.new do | t |
  t.threshold = 100
end


Spec::Rake::SpecTask.new do | t |
  t.spec_files = FileList[ '*_spec.rb' ]
  t.spec_opts = [ '--format=specdoc', '--color' ]
  t.rcov = true
  t.rcov_opts = lambda do
    IO.readlines( './rcov.opts' ).map do | l |
      l.chomp.split ' '
    end.flatten
  end
end


def parse_ss ss
  s = []
  d = []
  IO.readlines( ss ).each do | each |
    if /^s (\d+)/=~ each.chomp
      s << $1        
    end
    if /^d (\d+)/=~ each.chomp
      d << $1
    end
  end
  [ s, d ]
end


def scp_png path
  target_dir = File.join( '/tmp', path.split( ':' )[ 0 ] )
  puts "SCPing #{ path } to #{ target_dir } ..."
  system "scp #{ path } #{ target_dir }"
end


def node_list
  IO.readlines( 'node_list.txt' ).collect do | each |
    each.chomp
  end
end


task :run do
  pool = ThreadPool.new( 16 )

  ss = Dir.glob( '/tmp/count3109-3000/*.ss' )

  node_list.each do | each |
    dir = File.join( '/tmp', each )
    unless FileTest.directory?( dir )
      FileUtils.mkdir dir
    end
  end

  ss.each do | each |
    puts "SS: #{ each }"

    s, d = parse_ss( each )
    pool.dispatch( each, s, d ) do | ss, s, d |
      begin
        telnet = Net::Telnet.new( "Host" => "localhost", "Port" => 7838, "Timeout" => 1000 )
        telnet.cmd "dispatch /home/yasuhito/USA-t.m-gr #{ s.size } #{ d.size } #{ s.join( ' ' ) } #{ d.join( ' ' ) }" do | l |
          case l
          when /^FAILED/
            raise "Queue is full"
          when /^OK (\S+:\S+\.png)/
            scp_png $1
          end
        end
      rescue
        sleep 1
        $stderr.puts "Retrying #{ ss } ... "
        retry
      end
    end
  end

  pool.shutdown
end


task :server do
  q = Queued.new( node_list )
  q.start
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
