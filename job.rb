require 'tempfile'


class Job
  def initialize graph, source, destination
    @source = source
    @destination = destination
    @graph = graph
    @ss = make_query_file
  end

  
  def command
    "/home/yasuhito/project/sp/spsolve081229/sp.heap #{ @graph } #{ @ss } #{ outp }"
  end


  def merge_command
    "/home/yasuhito/project/sp/tools081229/merge_ssout #{ @graph } #{ graph_co } #{ @ss } #{ outp } #{ eps }"
  end


  private


  def eps
    @ss + ".eps"
  end


  def outp
    @ss + ".out-p"
  end


  def graph_co
    File.join( File.dirname( @graph ), File.basename( @graph, ".*" )[ 0..-3 ] ) + '.m-co'
  end


  def source_ss
    @source.collect do | each |
      "s #{ each }"
    end
  end


  def destination_ss
    @destination.collect do | each |
      "d #{ each }"
    end
  end


  def make_query_file
    t = Tempfile.new( 'sp' )
    t.puts <<-SS
p aux sp ss #{ source_ss.size } #{ destination_ss.size }
c
#{ source_ss.join( "\n" ) }
c
#{ destination_ss.join( "\n" ) }
SS
    t.close
    t.path
  end
end
