class Color
  PINK = "[0;31m"
  GREEN = "[0;32m"
  YELLOW = "[0;33m"
  SLATE = "[0;34m"
  ORANGE = "[0;35m"
  BLUE = "[0;36m"
  RESET = "[0m"


  def self.slate string
    SLATE + string + RESET
  end


  def self.yellow string
    YELLOW + string + RESET
  end


  def self.pink string
    PINK + string + RESET
  end
end
