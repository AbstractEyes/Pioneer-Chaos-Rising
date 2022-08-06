module Sound

  def self.flip_page
    Sound.flip_page_1
  end


  def self.flip_pages
    Sound.flip_page_1
    Sound.flip_page_2
  end

end

class Game_Temp
  def equip_slot_index=(new_index)
    @equip_slot_index = new_index
  end
  def equip_slot_index
    @equip_slot_index = 0 if @equip_slot_index.nil?
    return @equip_slot_index
  end
end

class Scene_Equip < Scene_Base

  def start
    super
    @background = Sprite.new
    @background.bitmap = Cache.system('/book/background')
    @background.visible = true
    @status_character_list = Window_StatusCharacter.new(0, 0, $screen_width/2, $screen_height)
    @status_character_list.visible = true
    @status_character_list.active = true
    @status_character_list.refresh
    @equipment_list = Window_Equip_Overhaul.new($screen_width/2, 0, $screen_width/2, $screen_height)
    @equipment_list.active = false
    @equipment_list.visible = true
    #@status_character.actor_id = 1
    refresh
  end

  def index
    $game_temp.status_actor_index
  end

  def index=(new_index)
    $game_temp.status_actor_index=new_index
  end

  def terminate
    super
    @background.dispose
    @status_character_list.dispose
    @equipment_list.dispose
  end

  def refresh
    @status_character_list.x = 0
    @status_character_list.index = self.index
    @equipment_list.refresh(self.index)
    #@status_data.x = $screen_width / 2
    #@status_data.refresh(self.index)
    Graphics.wait(1)
  end

  def update
    super
    @background.update
    @status_character_list.update
    @equipment_list.update
    if self.index != @status_character_list.index
      self.index = @status_character_list.index
      refresh
    end
    if @status_character_list.active
      update_character_list_inputs
    elsif @equipment_list.active
      update_equipment_list_inputs
    end
  end

  def update_character_list_inputs
    if Input.trigger?(PadConfig.cancel)
      return_book_scene
    elsif Input.trigger?(PadConfig.decision)
      #switch to equipment list
      #change displayed stats to single piece of equipment
      @status_character_list.active = false
      @equipment_list.active = true
    end
  end

  def update_equipment_list_inputs
    if Input.trigger?(PadConfig.cancel)
      @equipment_list.active = false
      @status_character_list.active = true
    elsif Input.trigger?(PadConfig.decision)
      #switch to reserve equipment list
    end
  end

  def return_book_scene
    Sound.flip_page_1
    $scene = Scene_Pioneer_Book.new
  end

end