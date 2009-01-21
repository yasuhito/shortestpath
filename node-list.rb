class NodeList
  def initialize list = nil
    @list = ( list ? list : [] )
  end


  def size
    @list.size
  end


  def add node
    @list << node
  end


  def get_list
    @list
  end


  def get_node
    @list.shift
  end
end
