class NodeList
  attr_reader :list


  def initialize list
    @list = list
  end


  def get
    @list.shift
  end


  def add node
    @list << node
  end
end
