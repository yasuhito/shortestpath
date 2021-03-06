class NodeList
  def initialize list
    @mutex = Mutex.new
    @nodes = list
    @clients = []
    @allocation = {}
  end


  def to_ary
    @nodes
  end


  def allocate_to client
    @mutex.synchronize do
      @clients << client
      node = @nodes.shift
      @allocation[ client ] = node
      node
    end
  end


  def deallocate_from client
    @mutex.synchronize do
      node = @allocation[ client ]
      @nodes << node
      @clients.each_with_index do | each, i |
        if each == client
          @clients.delete_at i
          break
        end
      end
      @allocation.delete client
      node
    end
  end


  def empty?
    @mutex.synchronize do
      @nodes.empty?
    end
  end
end
