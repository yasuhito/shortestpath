require 'tempfile'


class Job
  attr_reader :ss


  def initialize graph, source, destination
    @source = source
    @destination = destination
    @graph = graph
    validate
    @ss = make_query_file
  end


  def command
    [ sp_command, merge_command, convert_command ].join( ' && ' )
  end


  ################################################################################
  private
  ################################################################################


  def sp_command
    "~/bin/sp.heap #{ @graph } #{ ss } #{ outp }"
  end


  def merge_command
    "~/bin/merge_ssout #{ @graph } #{ graph_co } #{ ss } #{ outp } #{ eps }"
  end


  def convert_command
    "convert -transparent white #{ eps } #{ png } && echo 'OK PNG=#{ png }'"
  end


  def validate
    unless /\.m\-gr$/=~ @graph
      raise 'graph file name should have .m-gr suffix'
    end
    if @source.include?( nil )
      raise "invalid query #{ @source.inspect }"
    end
    if @destination.include?( nil )
      raise "invalid query #{ @destination.inspect }"
    end
  end


  def png
    @tmp_path + '.png'
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
    t = Tempfile.new( "sp.#{ Thread.current.object_id }" )
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
