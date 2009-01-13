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
    @source.collect do | each |
      "s #{ each }"
    end
  end


  def destination_ss
    @destination.collect do | each |
      "d #{ each }"
    end
  end


  def query_file
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
