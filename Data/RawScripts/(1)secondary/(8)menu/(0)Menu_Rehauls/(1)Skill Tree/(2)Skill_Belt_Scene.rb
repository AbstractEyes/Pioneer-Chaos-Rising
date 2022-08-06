class Scene_Skill < Scene_Base

  def initialize(actor_index = 0, equip_index = 0)
    @actor_index = actor_index
  end

  def start
    super
    @menu_window = Skill_Commands.new(0, 40, 100, 32*4+8)
    @menu_window.active = true
    @belt_window = Skill_Belt_Window.new(100, 40, 240, 220)
    @belt_window.refresh($game_party.members[@actor_index])
    @belt_window.active = false
    @belt_window.opacity /= 2
  end

  def terminate
    super
    @belt_window.dispose
    @menu_window.dispose
  end

  def update
    super
    @belt_window.update
    @menu_window.update
    if @belt_window.active
      update_skill_selection
    elsif @menu_window.active
      update_menu_selection
    end
  end

  def update_menu_selection
    if Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      $scene = Scene_Pioneer_Book.new
    elsif Input.trigger?(PadConfig.decision)
      Sound.play_equip
      @menu_window.active = false
      @menu_window.opacity /= 2
      @belt_window.active = true
      @belt_window.opacity *= 2
    end
  end

  def update_skill_selection
    if Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      @belt_window.active = false
      @belt_window.opacity /= 2
      @menu_window.active = true
      @menu_window.opacity *= 2
    elsif Input.trigger?(PadConfig.left) || Input.repeat?(PadConfig.left)
      unless @belt_window.shifting?
        Sound.play_cursor
        @belt_window.last_skill
      end
    elsif Input.trigger?(PadConfig.right) || Input.repeat?(PadConfig.right)
      unless @belt_window.shifting?
        Sound.play_cursor
        @belt_window.next_skill
      end
    elsif Input.trigger?(PadConfig.up)
      unless @belt_window.shifting?
        Sound.play_equip
        @belt_window.last_belt
      end
    elsif Input.trigger?(PadConfig.down)
      unless @belt_window.shifting?
        Sound.play_equip
        @belt_window.next_belt
      end
    #elsif Input.trigger?(PadConfig.page_up)
    #  Sound.play_cursor
    #  next_actor
    #elsif Input.trigger?(PadConfig.page_down)
    #  Sound.play_cursor
    #  prev_actor
    elsif Input.trigger?(PadConfig.decision)
      Sound.play_decision
      #@skill = @skill_window.skill
      #if @skill != nil
      #  @actor.last_skill_id = @skill.id
      #end
      #if @actor.skill_can_use?(@skill)
      #  Sound.play_decision
      #  determine_skill
      #else
      #  Sound.play_buzzer
      #end
    end
  end

end