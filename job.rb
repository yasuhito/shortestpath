require 'tempfile'


class Job
  def initialize graph, source, destination
    @source = source
    @destination = destination
    @graph = graph
    validate
  end

  
  def sp_command
    "/home/yasuhito/project/sp/spsolve081229/sp.heap #{ @graph } #{ ss } #{ outp }"
  end


  def merge_command
    "/home/yasuhito/project/sp/tools081229/merge_ssout #{ @graph } #{ graph_co } #{ ss } #{ outp } #{ eps }"
  end


  private


  def ss
    @ss || make_query_file
  end


  def validate
    unless /\.m\-gr$/=~ @graph
      raise 'graph file name should have .m-gr suffix'
    end
    unless FileTest.exist?( @graph )
      raise "graph file #{ @graph } does not exist!"
    end
    if @source.include?( nil )
      raise "invalid query #{ @source.inspect }"
    end
    if @destination.include?( nil )
      raise "invalid query #{ @destination.inspect }"
    end
  end


  def eps
    @tmp_path + '.eps'
  end


  def outp
    @tmp_path + '.out-p'
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

    @tmp_path = t.path
    sspath = t.path + '.ss'

    File.rename t.path, sspath
    sspath
  end
end
