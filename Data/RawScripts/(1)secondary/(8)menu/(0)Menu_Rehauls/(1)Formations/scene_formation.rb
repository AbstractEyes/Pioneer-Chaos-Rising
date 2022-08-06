class Scene_Formation < Scene_Base

  def start
    super
    @background = Sprite.new
    @background.bitmap = Cache.system('/book/background')
    @formation_command = Formation_Options.new(80, 32, 160, 32+(32*5))
    @formation_command.active = true
    @formation_command.index = 0
    @formation_command.opacity = 0
    @formation_grid = Formation_Window.new($screen_width / 2 + 32, 32,5*32+64, 5*32+32)
    @formation_grid.active = false
    @formation_grid.index = 12
    @formation_grid.opacity = 0
    #@formation_bench = Formation_Bench.new($screen_width / 2, 32+5*32+32, 5*32+64, 96)
    #@formation_bench.opacity = 0
    @last_command_index = 0
    @last_formation_index = 0
  end

  def terminate
    super
    #@formation_title.dispose
    @background.dispose
    @formation_command.dispose
    @formation_grid.dispose
    #@formation_bench.dispose
  end

  def update
    super
    @background.update
    @formation_command.update
    @formation_grid.update
    #@formation_bench.update
    if @last_command_index != @formation_command.index
      @last_command_index = @formation_command.index
      @formation_grid.refresh(@last_command_index)
      return
    end
    if @formation_grid.index != @last_formation_index
      @last_formation_index = @formation_grid.index
      if @formation_grid.locked?
        @formation_grid.refresh
      end
    end
    if @formation_command.active
      update_command_inputs
    elsif @formation_grid.active
      update_formation_grid_inputs
    end
  end

  def update_formation_grid_inputs
    # Formation grid
    # Formation list
    if Input.trigger?(PadConfig.decision)
      if @formation_grid.locked?
        @formation_grid.set
        Sound.play_equip
      else
        if @formation_grid.exists?
          @formation_grid.lock
          Sound.play_equip
        else
          Sound.play_buzzer
        end
      end
      #Snag party member from bench or grid.
    elsif Input.trigger?(PadConfig.cancel) || Input.trigger?(PadConfig.left)
      Sound.flip_page_1
      if @formation_grid.locked?
        @formation_grid.unlock
      else
        @formation_grid.refresh
        @formation_command.active = true
        @formation_grid.active = false
      end
    end
  end

  def update_command_inputs
    # Formation list
    if Input.trigger?(PadConfig.decision) || Input.trigger?(PadConfig.right)
      Sound.play_equip
      @formation_command.active = false
      @formation_grid.active = true
    elsif Input.trigger?(PadConfig.cancel) || Input.trigger?(PadConfig.left)
      Sound.flip_page_1
      $scene = Scene_Pioneer_Book.new
    end
  end
end