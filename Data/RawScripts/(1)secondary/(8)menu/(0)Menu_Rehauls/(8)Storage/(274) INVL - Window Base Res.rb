class Window_Base < Window

  def draw_resource_value(value, x, y, width)
    cx = contents.text_size(" Resource").width
    self.contents.font.color = normal_color
    self.contents.draw_text(x, y, width-cx-2, WLH, value, 2)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, width, WLH, " Resource", 2)
  end

end