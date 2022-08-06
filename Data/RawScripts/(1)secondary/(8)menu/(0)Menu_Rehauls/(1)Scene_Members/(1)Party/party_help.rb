class Party_Help < Window_Base

  def set(text)
    create_contents
    self.contents.draw_text(0, 0, width, WLH, text)
  end

end