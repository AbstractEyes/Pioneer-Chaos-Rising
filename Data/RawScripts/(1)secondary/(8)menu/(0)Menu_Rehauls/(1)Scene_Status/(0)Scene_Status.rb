
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
  def status_actor_index=(new_index)
    @actor_status_index=new_index
  end
  def status_actor_index
    @actor_status_index = 0 if @actor_status_index.nil?
    return @actor_status_index
  end
  def status_page=(new_index)
    @status_page = new_index
  end
  def status_page
    @status_page = 0 if @status_page.nil?
    return @status_page
  end
end

class Scene_Rehauled_Status < Scene_Base

  def start
    super
    @background = Sprite.new
    @background.bitmap = Cache.system('/book/background')
    @background.visible = true
    @status_data = Window_StatusData.new($screen_width/2, 0, $screen_width/2, $screen_height)
    @elemental_status_data = Window_ElementalData.new($screen_width/2, 0, $screen_width/2, $screen_height)
    @elemental_status_data.visible = false
    @status_character_list = Window_StatusCharacter.new(0, 0, $screen_width/2, $screen_height)
    @status_character_list.active = true
    @status_character_list.refresh
    refresh
  end

  def perform_transition
    Graphics.transition(0)
  end

  def return_scene
    Sound.flip_pages
    $scene = Scene_Pioneer_Book.new
  end

  def fix_index
    self.index = 0 if self.index < 0
    self.index = $game_party.members.size - 1 if self.index > $game_party.members.size - 1
    self.index
  end

  def fix_page
    self.page = 0 if self.page < 0
    self.page = 1 if self.page > self.max_page
    self.page
  end

  def index
    $game_temp.status_actor_index
  end

  def index=(new_index)
    $game_temp.status_actor_index=new_index
  end

  def page
    $game_temp.status_page
  end

  def page=(new_page)
    $game_temp.status_page = new_page
  end

  def max_page
    return 1
  end

  def terminate
    super
    #@status_equip.dispose
    @status_data.dispose
    @elemental_status_data.dispose
    @status_character_list.dispose
    @background.dispose
  end

  def update
    super
    #@status_equip.update
    @background.update
    @status_data.update
    @elemental_status_data.update
    @status_character_list.update
    update_actor_input
  end

  def update_visibility
    case self.page
      when 0
        @status_character_list.visible = true
        @status_character_list.active = true
        @status_character_list.index = self.index
        @status_data.visible = true
        @elemental_status_data.visible = false
      when 1
        @status_character_list.active = false
        @status_character_list.visible = false
        @status_data.visible = true
        @elemental_status_data.visible = true
    end
  end

  def refresh
    fix_index
    fix_page
    update_visibility
    #@status_character.refresh(self.index)
    case self.page
      when 0
        @status_character_list.x = 0
        @status_character_list.index = self.index
        @status_data.x = $screen_width / 2
        @status_data.refresh(self.index)
      when 1
        @status_data.x = 0
        @status_data.refresh(self.index)
        Graphics.wait(1)
        @elemental_status_data.x = $screen_width / 2
        @elemental_status_data.refresh(self.index)
        Graphics.wait(1)
      when 2


    end
  end

  def update_actor_input
    if Input.trigger?(PadConfig.up)
      Sound.flip_page
      self.index -= 1
      refresh
    elsif Input.trigger?(PadConfig.down)
      Sound.flip_page
      self.index += 1
      refresh
    elsif Input.trigger?(PadConfig.left) || Input.trigger?(PadConfig.cancel)
      self.page -= 1
      if self.page < 0
        Sound.flip_pages
        fix_page
        return_scene
        return
      else
        Sound.flip_page
      end
      refresh
    elsif Input.trigger?(PadConfig.right) || Input.trigger?(PadConfig.decision)
      if self.max_page != self.page
        Sound.flip_page
      end
      self.page += 1
      refresh
    end

  end

end