class Color
  PINK = "[0;31m"
  GREEN = "[0;32m"
  YELLOW = "[0;33m"
  SLATE = "[0;34m"
  ORANGE = "[0;35m"
  BLUE = "[0;36m"
  RESET = "[0m"


  def self.slate str
    SLATE + str + RESET
  end


  def self.yellow str
    YELLOW + str + RESET
  end


  def self.pink str
    PINK + str + RESET
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
