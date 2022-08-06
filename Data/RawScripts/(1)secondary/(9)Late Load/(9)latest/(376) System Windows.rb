class System_Window
  def initialize(window)
    @window = window
    @x = 0
    @y = 0
    @width = 0
    @height = 0
    @rect = nil
  end
  attr_accessor :window
  attr_accessor :x
  attr_accessor :y
  attr_accessor :width
  attr_accessor :height
  attr_accessor :rect
end