class Equipment_Calculate
  def calculate(equipment)

  end
end

class Window_StatusEquipment < Window_Base

  def initialize(x,y,w,h)
    super(x,y,w,h)
    @actor_id = -1
    @stats = Equipment_Calculate.new
    refresh(0)
  end

  def refresh(actor_id)
    @actor_id = actor_id
    return if @actor_id == -1
    display_equipment
  end

  def display_equipment
    @actor = $game_party.all_members[@actor_id]
    self.contents.clear
    @data = []
    for item in @actor.equips do @data.push(item) end
    #@item_max = @data.size
    self.contents.font.color = system_color
    outline_rect(4, 32 * 0, self.contents.width - 8, 30, :RED)
    outline_rect(4, 32 * 1, self.contents.width - 8, 30, :RED)
    outline_rect(4, 32 * 2, self.contents.width - 8, 30, :CYAN)
    outline_rect(4, 32 * 3, self.contents.width - 8, 30, :CYAN)
    outline_rect(4, 32 * 4, self.contents.width - 8, 30, :CYAN)
    self.contents.draw_text(4, 32 * 0, 92, 30, 'Weapon 1')
    self.contents.draw_text(4, 32 * 1, 92, 30, 'Weapon 2')
    self.contents.draw_text(4, 32 * 2, 92, 30, 'Head')
    self.contents.draw_text(4, 32 * 3, 92, 30, 'Body')
    self.contents.draw_text(4, 32 * 4, 92, 30, 'Legs')
    draw_item_name(@data[0], 92, 32 * 0)
    draw_item_name(@data[1], 92, 32 * 1)
    draw_item_name(@data[2], 92, 32 * 2)
    draw_item_name(@data[3], 92, 32 * 3)
    draw_item_name(@data[4], 92, 32 * 4)
  end

  def calculate_equipment_stats

  end

  def outline_rect(x, y, w, h, color = :RED)
    self.contents.fill_rect(x,y,w,h,PHI.color(color))
    self.contents.fill_rect(x+1,y+1,w-2,h-2,PHI.color(:INV))
  end

end