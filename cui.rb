require 'color'


class CUI
  @@nodes = []
  @@started = Hash.new( 0 )
  @@finished = Hash.new( 0 )
  @@last_updated = Time.now
  @@mutex = Mutex.new


  def self.display
    @@mutex.synchronize do
      now = Time.now
      return if now - @@last_updated < 1
      @@last_updated = now

      system 'tput clear'
      system 'tput cup 0 0'

      @@nodes.sort.each do | each |
        finished = Color.slate( '#' * @@finished[ each ] )
        started = Color.yellow( '#' * @@started[ each ] )
        
        puts "#{ each }: #{ finished }#{ started }"
      end
    end
  end


  def self.started node
    @@mutex.synchronize do
      unless @@nodes.include?( node )
        @@nodes << node
      end
      @@started[ node ] = @@started[ node ] + 1
      display
    end
  end


  def self.finished node
    @@mutex.synchronize do
      @@started[ node ] = @@started[ node ] - 1
      @@finished[ node ] = @@finished[ node ] + 1
      display
    end
  end
end
