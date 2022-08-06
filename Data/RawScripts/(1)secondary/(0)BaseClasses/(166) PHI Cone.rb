# north cone
# left: -45
# right: 45

class Cone_Matrix < Coord
  attr_reader :acute
  attr_reader :left_angle
  attr_reader :right_angle
  
  def initialize(x, y, acute, left_angle, right_angle)
    super(x, y)
    @acute,@left_angle,@right_angle = acute,left_angle,right_angle
  end
  def refresh(x,y,o=0,s=0)
    # center Point x, center point y, point length, point offset
    @x,@y,@s,@o = x,y,s,o
  end

  # y = mx + b
  # ay = -@left_angle/180 * dx + 0
  def inside?(x,y)
    n = Proc.new {
      dx = x - @x
      ay = (180 - @left_angle * (@left_angle < 0 ? 1 : -1))/180 * dx
      return false if @left_angle < 0 ? (ay < y) : (ay >= y)
      ay = (180 + @right_angle * (@right_angle < 0 ? 1 : -1))/180 * dx
      return @right_angle < 0 ? (ay > y) : (ay <= y)
    }.call
    return acute ? n : !n
  end
end