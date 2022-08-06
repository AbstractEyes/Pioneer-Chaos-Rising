class Skill_Commands < Window_Selectable

  def initialize(x,y,width,height)
    super(x,y,width,height)
    @data = ['Learn Skills', 'Unlearn Skills', 'Save Set', 'Load Set']
    @item_max = @data.size
    @column_max = 1
    self.active = true
    self.visible = true
    @index = 0
    create_window
  end

  def update
    super
  end

  def create_window
    self.contents.clear
    create_contents
    for i in 0...@data.size
      rect = item_rect(i)
      self.contents.draw_text(rect, @data[i])
    end
  end

end