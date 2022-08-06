class Window_MacroHelp < Window_Base

  def initialize(x,y,width,height)
    super(x,y,width,height)
  end

  def update
    super
  end

  def dispose
    super
  end

  def draw_text(text, color)
    create_contents
    old_color = self.contents.font.color
    self.contents.font.color = color
    self.contents.draw_text(self.contents.rect, text)
    self.contents.font.color = old_color
  end

end