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


task :run do
  begin
    pool = ThreadPool.new( node_list.size )
    make_target_dirs
    targets = []

    ss_all.each do | each |
      puts "SS: #{ each }"
      pool.dispatch( each, *parse_ss( each ) ) do | ss, s, d |
        begin
          telnet( s, d ) do | l |
            case l
            when /^FAILED/
              raise "Queue is full"
            when /^OK (\S+:\S+\.png)/
              targets << scp_png( $1 )
            end
          end
        rescue
          STDERR.puts $!.to_s
          sleep 1
          $stderr.puts "Retrying #{ ss } ... "
          retry
        end
      end
    end
    pool.shutdown
  rescue Interrupt
    $stderr.puts "Caught Ctrl-c signal! Terminating ..."
  ensure
    composite_png targets
    clean_temp_file
  end
end


task :server do
  q = Queued.new( node_list )
  q.start
end


################################################################################
# Helper Functions
################################################################################


def clean_temp_file
  FileUtils.rm Dir.glob( '/tmp/*.ss' ), :force => true
end


def composite_png targets
  unless targets.empty?
    system "convert -composite #{ targets.join( ' ' ) } /tmp/target.png"
  end
end


def ss_all
  Dir.glob '/tmp/count3109-3000/*.ss'
end


def parse_ss ss
  s = []
  d = []
  IO.readlines( ss ).each do | each |
    case each.chomp
    when /^s (\d+)/
      s << $1        
    when /^d (\d+)/
      d << $1
    end
  end
  [ s, d ]
end


def scp_png path
  target_dir = File.join( '/tmp', path.split( ':' )[ 0 ] )
  puts "SCPing #{ path } to #{ target_dir } ..."
  system "scp #{ path } #{ target_dir }"
  File.join target_dir, File.basename( path.split( ':' )[ 1 ] )
end


def node_list
  IO.readlines( 'node_list.txt' ).collect do | each |
    each.chomp
  end
end


def telnet s, d, &block
  telnet = Net::Telnet.new( 'Host' => 'localhost', 'Port' => 7838, 'Timeout' => 10000 )
  telnet.cmd "dispatch /home/yasuhito/USA-t.m-gr #{ s.size } #{ d.size } #{ s.join( ' ' ) } #{ d.join( ' ' ) }" do | line |
    block.call line
  end
end


def make_target_dirs
  node_list.each do | each |
    dir = File.join( '/tmp', each )
    if FileTest.directory?( dir )
      FileUtils.rm Dir.glob( File.join( dir, '*.png' ) )
    else
      FileUtils.mkdir dir
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
