require 'tempfile'


class Job
  def initialize graph, source, destination
    @source = source
    @destination = destination
    @graph = graph
  end

  
   def command
    "sp.heap #{ @graph } #{ query_file } /tmp/sp.out-p"
  end


  private


  def source_ss
    lines = @source.collect do | each |
      "s #{ each }"
    end
    lines.join( "\n" )
  end


  def destination_ss
    lines = @destination.collect do | each |
      "d #{ each }"
    end
    lines.join( "\n" )
  end


  def query_file
    t = Tempfile.new( 'sp' )
    t.puts <<-SS
p aux sp ss 1 10
c
#{ source_ss }
c
#{ destination_ss }
SS
    t.close
    t.path
  end
end
