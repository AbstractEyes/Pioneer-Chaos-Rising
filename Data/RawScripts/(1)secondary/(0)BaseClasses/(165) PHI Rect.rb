class Rect_Matrix < Coord
  attr_reader :x1
  attr_reader :x2
  attr_reader :y1
  attr_reader :y2
  attr_reader :s
  
  def initialize(x = 0, y = 0, s = 0)
    super(x,y)
    @x1, @x2, @y1, @y2, @s = x-s, x+s, y-s, y+s, s
  end
  
  def refresh(x,y,s = @s)
    @s = s
    @x, @y, @x1, @x2, @y1, @y2 = x, y, x-s, x+s, y-s, y+s
  end

  def w
    return (@x2 - @x1) / 2
  end

  def width
    return @x2 - @x1
  end

  def h
    return (@y2 - @y1) / 2
  end

  def height
    return @y2 - @y1
  end

  def nodes
    out = []
    for x in @x1...@x2
      for y in @y1...@y2
        out.push Coord.new(x,y)
      end
    end
    return out.uniq
  end

  def inside?(x,y)
    return (((x >= @x1) and (x <= @x2)) and ((y >= @y1) and (y <= @y2)))
  end
  
end