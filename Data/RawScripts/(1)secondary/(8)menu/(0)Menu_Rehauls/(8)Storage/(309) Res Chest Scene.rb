

class Scene_Resource_Chest < Scene_Base
  
  #--------------------------------------------------------------------------
  # * Start processing
  #--------------------------------------------------------------------------
  def start
    super
    create_menu_background
    @viewport = Viewport.new(0, 0, $screen_width, $screen_height)
    @help_window = Window_Help.new
    @help_window.viewport = @viewport
    @item_window = Resource_Chest.new(0, 56, $screen_width, 300)
    @item_window.viewport = @viewport
    @item_window.help_window = @help_window
    @item_window.active = true
    @name_window = Resource_Window_Name.new(0, 354, $screen_width, 62)
    @name_window.viewport = @viewport
    
    @space_gauge_window = Window_SpaceGauge.new(0, 354, $screen_width, 62)
    @space_gauge_window.opacity = 0
    fix_space_window
  end
  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_menu_background
    @viewport.dispose
    @help_window.dispose
    @item_window.dispose
    @name_window.dispose
    @space_gauge_window.dispose
  end
  #--------------------------------------------------------------------------
  # * Return to Original Screen
  #--------------------------------------------------------------------------
  def return_scene
    $scene = Scene_Map.new
  end
  #--------------------------------------------------------------------------
  # * Update Frame
  #--------------------------------------------------------------------------
  def update
    super
    update_menu_background
    @help_window.update
    @item_window.update
    if @item_window.active
      update_item_selection
    end
  end
  
  def fix_space_window
    @space_gauge_window.opacity = 0
    @space_gauge_window.x = 4
    @space_gauge_window.y = 300
    @space_gauge_window.z = @item_window.z + 1
  end
  
  #--------------------------------------------------------------------------
  # * Update Item Selection
  #--------------------------------------------------------------------------
  def update_item_selection
    if Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      return_scene
    elsif Input.trigger?(PadConfig.hud)
      @item = @item_window.item
      stack_max = $game_party.full_stack_size(@item)
      if @item != nil
        $game_party.last_item_id = @item.id
      end
      item_possible = stack_max - $game_party.item_number(@item)
      if item_possible > $game_party.res_item_number(@item)
        item_possible = $game_party.res_item_number(@item)
      end
      if $game_party.overall_checker(@item, 1)
        for i in 1..item_possible
          Sound.play_equip
          $game_party.remove_res_item(@item, 1)
          $game_party.gain_item(@item, 1)
          @item_window.refresh
          Graphics.wait(8)
        end
        @space_gauge_window.update
        fix_space_window
      else
        Sound.play_cancel
      end
    elsif Input.trigger?(PadConfig.decision)
      @item = @item_window.item
      stack_max = $game_party.full_stack_size(@item)
      if @item != nil
        $game_party.last_item_id = @item.id
      end
      if $game_party.overall_checker(@item, 1)
        Sound.play_equip
        $game_party.remove_res_item(@item, 1)
        $game_party.gain_item(@item, 1)
        @item_window.refresh
        @space_gauge_window.update
      else
        Sound.play_cancel
      end
    end
  end
  
end