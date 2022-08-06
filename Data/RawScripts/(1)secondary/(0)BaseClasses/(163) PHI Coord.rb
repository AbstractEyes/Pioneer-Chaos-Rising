class Coord
  attr_accessor :x
  attr_accessor :y
  
  def initialize(x, y)
    @x, @y = x, y
  end
  def refresh(x, y)
    @x, @y = x, y
  end
  def set(x,y)
    refresh(x,y)
  end
  def nodes
    return []
  end
end