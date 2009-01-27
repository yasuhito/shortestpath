# -*- coding: utf-8 -*-
require 'rubygems'

require 'logger'
require 'net/telnet'
require 'queued'
require 'rake/clean'
require 'sp-config'
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


class QueueFullError < RuntimeError; end
$mutex = Mutex.new

task :run do
  begin
    $log = Logger.new( STDOUT )
    if ENV[ 'DEBUG' ]
      $log.level = Logger::DEBUG
    else
      $log.level = Logger::INFO
    end

    FileUtils.rm target_png, :force => true

    pool = ThreadPool.new( node_list.size, $log )
    make_target_dirs

    ss_all.each do | each |
      $log.info "Submitting a query (ss=#{ each }) ..."
      pool.dispatch( each, *parse_ss( each ) ) do | ss, s, d |
        begin
          telnet( s, d ) do | l |
            case l
            when /^FAILED/
              raise QueueFullError, 'Queue is full'
            when /^OK \S+:\S+\.png/
              $log.info "Finished query (ss=#{ ss })"
              composite_png scp_png( l[ 3..-1 ].chomp )
            end
          end
        rescue QueueFullError
          $log.error $!.to_s
          sleep 1
          $log.info "Retrying #{ ss } ... "
          retry
        rescue
          $log.error $!.to_s
          $!.backtrace.each do | each |
            $log.debug each
          end
          sleep 1
          $log.info "Retrying #{ ss } ... "
          retry
        end
      end
      sleep 1
    end
    pool.shutdown
  rescue Interrupt
    $log.info "Got Ctrl-C signal! Terminating ..."
  end
end


task :server do
  q = Queued.new( node_list )
  q.start
end


################################################################################
# Helper Functions
################################################################################


def target_png
  File.expand_path SPConfig[ 'target' ]
end


def temp_target_png
  File.expand_path File.join( SPConfig[ 'working_dir' ], 'temp.png' )
end


def graph
  File.expand_path SPConfig[ 'graph' ]
end


def composite_png png
  $mutex.synchronize do
    cmd = nil
    if FileTest.exists?( target_png )
      cmd = "cp #{ target_png } #{ temp_target_png }; convert -composite #{ png } #{ temp_target_png } #{ target_png }"
    else
      cmd = "mv #{ png } #{ target_png }"
    end
    $log.debug cmd
    system cmd
  end
end


def ss_all
  ss = Dir.glob( File.join( ENV[ 'SS' ], '*.ss' ) )
  if ss.empty?
    $stderr.puts "usage: rake SS=SS_DIR run"
    $stderr.puts "example: rake SS=/tmp/count3109/ run"
    exit -1
  end
  ss
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
  target_dir = File.join( SPConfig[ 'working_dir' ], path.split( ':' )[ 0 ] )
  $log.debug "SCPing #{ path } to #{ target_dir } ..."
  unless system( "scp -q #{ path } #{ target_dir }" )
    raise "Failed to scp #{ path } to #{ target_dir }!"
  end
  File.join target_dir, File.basename( path.split( ':' )[ 1 ] )
end


def node_list
  IO.readlines( 'node_list.txt' ).collect do | each |
    each.chomp
  end
end


def telnet s, d, &block
  telnet = Net::Telnet.new( 'Host' => 'localhost', 'Port' => 7838, 'Timeout' => 10000 )
  telnet.cmd "dispatch #{ SPConfig[ 'graph' ] } #{ s.size } #{ d.size } #{ s.join( ' ' ) } #{ d.join( ' ' ) }" do | line |
    block.call line
  end
end


def make_target_dirs
  node_list.each do | each |
    dir = File.expand_path( File.join( SPConfig[ 'working_dir' ], each ) )
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
