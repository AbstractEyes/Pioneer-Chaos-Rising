class Coord
  attr_accessor :x
  attr_accessor :y
  
  def initialize(x, y)
    @x, @y = x, y
  end
end

class Line_Matrix < Coord
  
  def initialize(x,y,d=1,l=5)
    super(x,y)
    # Reserved variables to restrict refresh.
    @length, @direction = l, d
    @xdif, @ydif = 0, 0
  end
  
  def refresh(x,y,d=@direction,l=@length)
    @x, @y, @direction, @length = x, y, d, l
  end
  
  def inside?(x,y)
    x_step, y_step = 0, 0
    for xb in get_x_difference
      x_step += get_x_step
      for yb in get_y_difference
        y_step += get_y_step
        return true if(xb + x_step == x && yb + y_step == y)
      end
    end
    return false
  end
  
private
  def get_x_step
  end
  def get_y_step
  end
  # 1 downleft
  # 2 down
  # 3 downright
  # 4 left
  # 6 right
  # 7 upleft
  # 8 up
  # 9 upright
  def get_x_difference
    if @direction==1 || @direction==7 || @direction==4 #Straight line
      #downleft #upleft #left
      return ((@x - @length)...(@x))
    elsif @direction==2 || @direction==8
      #down #up
      return @x...@x+1
    elsif @direction==6 || @direction==3 || @direction==9
      #right #downright #upright
      return ((@x)...(@x + @length))
    end
    return 0
  end
  
  def get_y_difference
    if @direction==1
      return ((@y)...(@y + @length))
    elsif @direction==2
      return ((@y)...(@y + @length))
    elsif @direction==3
      return ((@y)...(@y + @length))
    elsif @direction==4
      return @y...@y+1
    elsif @direction==6
      return @y...@y+1
    elsif @direction==7
      return ((@y - @length)...(@y))
    elsif @direction==8
      return ((@y - @length)...(@y))
    elsif @direction==9
      return ((@y - @length)...(@y))
    end
    return 0
  end
  
end