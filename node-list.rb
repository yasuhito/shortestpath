class NodeList
  def initialize list = nil
    @list = ( list ? list : [] )
  end


  def get_node
    @list.shift
  end


  def add_node node
    @list << node
  end


  def get_list
    @list
  end
end
