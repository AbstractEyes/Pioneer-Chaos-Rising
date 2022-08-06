#==============================================================================
# ** Ellipse
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Stores an ellipse object.
#==============================================================================

class Ellipse
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Public Instance Variables
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_accessor :x
  attr_accessor :y
  attr_reader   :a # The width of the oval
  attr_reader   :b # The Height of the oval
  attr_reader   :h # The x position of the origin
  attr_reader   :k # The y position of the origin
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Object Initialization
  #     x : the top left x position
  #     y : the top left y position
  #     a : the width of oval from origin to the side
  #     b : the height of oval from origin. If nil, then a is radius of circle
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def initialize (x, y, a, b = nil)
    @x = x
    @y = y
    @a = a
    @b = b.nil? ? a : b
    @h = x + a
    @k = y + @b
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Within?
  #    x : the x coordinate being tested
  #    y : the y coordinate being tested
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def within? (x, y)
    x_square = ((x - @h)*(x - @h)).to_f / (@a*@a)
    y_square = ((y - @k)*(y - @k)).to_f / (@b*@b)
    # If "radius" <= 1, then it must be within the ellipse
    return (x_square + y_square) <= 1 
  end
end

#==============================================================================
# ** Bitmap
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  This adds the methods fill_ellipse, outline_ellipse, and fill_rounded_rect
#==============================================================================

class Bitmap
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Outline Ellipse
  #    ellipse : the ellipse being drawn
  #    width   : the width of the bar
  #    colour  : the colour of the outline
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def outline_ellipse (ellipse, colour = font.color, width = 1, steps = 0)
    # For neatness, define local variables a and b to the ellipse variables
    a, b = ellipse.a, ellipse.b
    # Use Ramanujan's approximation of the Circumference of an ellipse
    steps = Math::PI*(3*(a + b) - Math.sqrt((3*a + b)*(a + 3*b))) if steps == 0
    radian_modifier = (2*Math::PI) / steps
    for i in 0...steps
      t = (radian_modifier*i) % (2*Math::PI)
      # Expressed parametrically:
      #   x = h + acos(t), y = k + bsin(t) : where t ranges from 0 to 2pi
      x = (ellipse.h + (a*Math.cos(t)))
      y = (ellipse.k + (b*Math.sin(t)))
      set_pixel(x, y, colour)
    end
    # Thicken the line
    if width > 1
      ellipse = Ellipse.new(ellipse.x + 1, ellipse.y + 1, ellipse.a - 1, ellipse.b - 1)
      outline_ellipse(ellipse, colour, width - 1, steps)
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Fill Ellipse
  #    ellipse : the ellipse being drawn
  #    colour  : the colour of the outline
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def fill_ellipse (ellipse, colour = font.color, steps = 0)
    # For neatness, define local variables a and b to the ellipse variables
    a, b = ellipse.a, ellipse.b
    # Use Ramanujan's approximation of the Circumference of an ellipse
    steps = Math::PI*(3*(a + b) - Math.sqrt((3*a + b)*(a + 3*b))) if steps == 0
    radian_modifier = (2*Math::PI) / steps
    for i in 0...(steps / 2)
      t = (radian_modifier*i) % (2*Math::PI)
      # Expressed parametrically:
      #   x = h + acos(t), y = k + bsin(t) : where t ranges from 0 to 2pi
      x = ellipse.h + (a*Math.cos(t))
      y = ellipse.k - (b*Math.sin(t))
      fill_rect(x, y, 1, 2*(ellipse.k - y), colour)
    end
  end

  def draw_circle(cx, cy, rad, color, thick = 2, start_angle = 0, end_angle = 359)
    end_angle = start_angle / end_angle * 360
    rad -= 1
    error   = -rad
    x, y    = rad, 0
    while x >= y
      self.fill_rect(cx + x, cy + y, thick, thick, color) if (end_angle >= 270 - (61 * y / rad))
      self.fill_rect(cx - x, cy + y, thick, thick, color) if (x != 0 && end_angle > 90 + (61 * y / rad))
      self.fill_rect(cx + x, cy - y, thick, thick, color) if (y != 0 && end_angle > 270 + (61 * y / rad))
      self.fill_rect(cx - x, cy - y, thick, thick, color) if (x != 0 && y != 0 && end_angle >= 90 - (61 * y / rad))
      #if x != y
        self.fill_rect(cx + y, cy + x, thick, thick, color) if (end_angle > 180 + (61 * y / rad))
        self.fill_rect(cx - y, cy + x, thick, thick, color) if (y != 0 && end_angle >= 180 - (61 * y / rad))
        self.fill_rect(cx + y, cy - x, thick, thick, color) if (x != 0 && end_angle >= 360 - (61 * y / rad))
        self.fill_rect(cx - y, cy - x, thick, thick, color) if (y != 0 && x != 0 && end_angle > (61 * y / rad))
      #end
      error += y
      y	 += 1
      error += y
      if error >= 0
        error -= x
        x	 -= 1
        error -= x
      end
    end
  end


  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Fill Rounded Rectangle
  #    rect    : the rectangle being drawn
  #    colour  : the colour of the outline
  #    w       : the number of pixels to cover by rounding
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #  Used to fill a rectangle with rounded corners
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def fill_rounded_rect (rect, colour = font.color, w = 11)
    # Draw Body of the rectangle
    fill_rect(rect.x + w, rect.y, rect.width - 2*w, rect.height, colour)
    # Draw Left Vertical Rect
    fill_rect(rect.x, rect.y + w, w, rect.height - 2*w, colour)
    # Draw Right Vertical Rect
    x = rect.x + rect.width - w
    fill_rect(x, rect.y + w, w, rect.height - 2*w, colour)
    # Make a circle
    circle = Ellipse.new(0, 0, w)
    for i in 0...w
      for j in 0...w
        # Upper Left Corner
        set_pixel(rect.x + i, rect.y + j, colour) if circle.within?(i, j)
        # Upper Right Corner
        set_pixel(rect.x + rect.width - w + i, rect.y + j, colour) if circle.within?(i + w, j)
        # Bottom Left Corner
        set_pixel(rect.x + i, rect.y + rect.height - w + j, colour) if circle.within?(i, j + w)
        # Bottom Right Corner
        set_pixel(rect.x + rect.width - w + i, rect.y + rect.height - w + j, colour) if circle.within?(i + w, j + w)
      end
    end
  end

  def fill_rounded_rect_c(x,y,width,height, color=font.color, w = 8)
    fill_rounded_rect(Rect.new(x,y,width,height),color,w)
  end

end
