# -*- coding: utf-8 -*-
require 'sp-config'
require 'tempfile'


class Job
  attr_reader :ss


  def initialize graph, source, destination
    validate graph, source, destination
    @source = source
    @destination = destination
    @graph = graph
    @ss = make_ss
  end


  def command
    [ sp_command, merge_command, convert_command ].join( ' && ' )
  end


  def eps
    @tmp_basename + '.eps'
  end


  ################################################################################
  private
  ################################################################################


  def sp_command
    "#{ SPConfig[ 'sp.heap' ] } #{ @graph } #{ ss } #{ out_p }"
  end


  def merge_command
    "#{ SPConfig[ 'merge_ssout' ] } #{ @graph } #{ graph_co } #{ ss } #{ out_p } #{ eps }"
  end


  def convert_command
    "convert -transparent white #{ eps } #{ png } && echo 'OK PNG=#{ png }'"
  end


  def validate graph, source, destination
    unless /\.m\-gr\Z/=~ graph
      raise 'graph file name should have .m-gr suffix'
    end
    if source.include?( nil )
      raise "invalid query #{ source.inspect }"
    end
    if destination.include?( nil )
      raise "invalid query #{ destination.inspect }"
    end
  end


  def png
    @tmp_basename + '.png'
  end


  def out_p
    @tmp_basename + '.out-p'
  end


  def graph_co
    File.join( File.dirname( @graph ), graph_basename ) + '.m-co'
  end


  def graph_basename
    File.basename( @graph, ".*" )[ 0..-3 ]
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


  # [FIXME] Job#object_id が一意であることを仮定してしまっている。
  #
  #         tempfile でマルチスレッド間でほぼ同時に一時ファイルを作ろう
  #         とすると、同じ一時ファイルを作ることがあるように見える。
  #
  #         原因は多分、tempfile.rb の中で Mutex ではなくて
  #         Thread.critical で排他制御を行おうとしているが、これだと
  #         I/O がからむ場合にうまく排他制御が効かなかったりするため。
  #         http://www.ruby-lang.org/ja/man/html/Thread.html
  #         
  #         苦肉の策として object_id で一時ファイル名に一意な prefix を
  #         付けるようにしたつもり。本当は自作の Tempfile ライブラリと
  #         かを作るべきだろう。
  def make_ss
    t = Tempfile.new( "sp.#{ object_id }", SPConfig[ 'working_dir' ] )

    t.puts <<-EOF
p aux sp ss #{ source_ss.size } #{ destination_ss.size }
c
#{ source_ss.join( "\n" ) }
c
#{ destination_ss.join( "\n" ) }
EOF
    t.close

    @tmp_basename = t.path
    sspath = @tmp_basename + '.ss'
    File.rename t.path, sspath
    sspath
  end
end
