class Target_Data < Window_Base
  
  def initialize(x,y,width,height)
    super(x,y,width,height)
    self.visible = false
  end
  
  def refresh(x,y,actor_data)
    self.x = x
    self.y = y
    @data = actor_data
    draw_data
  end
  
  def draw_data
    #Todo: Create a proper enemy data window.
    @data.compact!
    p @data.size
    if @data.empty?
      self.height = 96
      create_contents
      rect = Rect.new(4, 4, 200, WLH)
      self.contents.font.color = system_color
      self.contents.draw_text(rect, 'No target.')
    else
      (@data.size > 1) ? self.height = 96 * (@data.size - 1) + 32 : self.height = 96
      create_contents
      update
      for i in 0...@data.size
        battler = @data[i].battler
        if battler != nil
          rect = Rect.new(4, 64 * i + 32, self.contents.width, WLH)
          self.contents.font.color = normal_color
          self.contents.draw_text(rect, battler.name)
          if !battler.dead?
            self.draw_character(battler.character.character_name,
                                battler.character.character_index,
                                self.contents.width - 32, rect.y + 32)
            self.draw_actor_hp(battler, rect.x, rect.y + 32, rect.width - 4)
          else
            self.contents.draw_text(rect, 'Dead')
          end
        end
      end
    end
  end
  
end