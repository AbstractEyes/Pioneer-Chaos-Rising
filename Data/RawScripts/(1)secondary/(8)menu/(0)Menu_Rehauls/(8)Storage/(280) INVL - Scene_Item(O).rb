################################################################################
# Scene_Item                                                                   #
#------------------------------------------------------------------------------#

class Scene_Item < Scene_Base

  def start
    super
    @viewport = Viewport.new(0, 0, $screen_width, $screen_height)
    #@background = Sprite.new
    #@background.bitmap = Cache.system('/book/background')
    #@background.visible = true
    @help_window = Window_Help_Better.new(0,0,$screen_width,60)
    @help_window.viewport = @viewport
    @item_window = Invl_Window_Item.new(0, 60, $screen_width/2, $screen_height-60)
    @item_window.viewport = @viewport
    @item_window.help_window = @help_window
    @item_window.active = false
    @target_window = Window_MenuStatus.new(0, 0)
    @target_window.z = 105
    hide_target_window
    @dropconfirm_window = Window_DropConfirm.new
    @dropconfirm_window.opacity = 0
    @dropconfirm_window.contents_opacity = 0
    @usedrop_window = Window_UseDrop.new
    @usedrop_window.opacity = 255
    @space_gauge_window = Window_SpaceGauge.new($screen_width/2, $screen_height-60, $screen_width/2, 60)
    @usedrop_window.help_window = @help_window
    @inventory_help = Inventory_Help.new($screen_width/2, 60, $screen_width/2, $screen_height-120)
    @item_window_saved_index
    $dropping_item = false
    $storing_item = false
    $withdrawing_item = false
    show_usedrop_window
  end

  def terminate
    super
    @viewport.dispose
    #@background.dispose
    @help_window.dispose
    @item_window.dispose
    @target_window.dispose
    @usedrop_window.dispose
    @space_gauge_window.dispose
    @dropconfirm_window.dispose
    @inventory_help.dispose
  end
  #--------------------------------------------------------------------------
  # * Return to Original Screen
  #--------------------------------------------------------------------------
  def return_scene
    $scene = Scene_Pioneer_Book.new
  end

  def update
    super
    #@background.update
    @usedrop_window.update
    @space_gauge_window.update
    @dropconfirm_window.update
    update_menu_background
    @help_window.update
    @item_window.update
    @target_window.update
    if @item_window.active
      update_item_selection
    elsif @target_window.active
      update_target_selection
    elsif @usedrop_window.active
      update_usedrop_selection
    end
    if @item_window_saved_index != @item_window.index && @item_window.active
      @item_window_saved_index = @item_window.index
      @inventory_help.refresh(@item_window.item)
    end
    if @target_window.active and (@item_window.item == nil or $game_party.item_number(@item_window.item) <= 0)
      hide_target_window
      @item_window.refresh
    end
  end

  def update_usedrop_selection
    unless @usedrop_activated
      @usedrop_activated = true
      return
    end
    if Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      $dropping_item = false
      return_scene
    elsif Input.trigger?(PadConfig.decision)
      if @usedrop_window.index == 0
        $dropping_item = false
      else
        $dropping_item = true
      end
      @item_window.refresh
      Sound.play_decision
      hide_usedrop_window
    end
  end
  
  def update_item_selection
    if Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      show_usedrop_window
      return
    elsif Input.trigger?(PadConfig.decision)
      @item = @item_window.item
      if @item != nil
        $game_party.last_item_id = @item.id
      end
      if $dropping_item == false
        if $game_party.item_can_use?(@item)
          Sound.play_decision
          determine_item
        else
          Sound.play_buzzer
        end
      else
        Sound.play_decision	
        $game_party.lose_item(@item, 1)
        @item_window.refresh
        if @item_window.index >= $game_party.items.size
          @item_window.index -= 1
        end
        if @item_window.index < 0
          @item_window.index = 0
        end
      end
    end
  end
  
  def show_usedrop_window
    @usedrop_window.open
    @usedrop_window.active = true
    @dropconfirm_window.close
    @dropconfirm_window.active = false
    @item_window.active = false
  end
  
  def hide_usedrop_window
    @usedrop_activated = false
    @usedrop_window.close
    @usedrop_window.active = false
    @item_window.active = true
    if @item_window.index >= @item_window.item_max
      @item_window.index = [@item_window.item_max - 1, 0].max
    end
  end
  
  def show_space_gauge_window
    @space_gauge_window.open
  end
  
  def hide_space_gauge_window
    @space_gauge_window.close
  end
  
  def show_item_window
    @dropconfirm_activated = false
    @dropconfirm_window.close
    @dropconfirm_window.index = 0
    @dropconfirm_window.active = false
    @item_window.active = true
    if @item_window.index >= @item_window.item_max
      @item_window.index = [@item_window.item_max - 1, 0].max
    end
  end
  
  def show_dropconfirm_window
    @dropconfirm_window.opacity = 255
    @dropconfirm_window.contents_opacity = 255
    @dropconfirm_window.open
    @dropconfirm_window.active = true
    @item_window.active = false
  end
  
  def hide_dropconfirm_window
    @dropconfirm_activated = false
    @dropconfirm_window.close
    @dropconfirm_window.active = false
    @item_window.active = true
    if @item_window.index >= @item_window.item_max
      @item_window.index = [@item_window.item_max - 1, 0].max
    end
  end
  
  def use_item_nontarget
    Sound.play_use_item
    $game_party.consume_item(@item)
    @item_window.draw_item(@item_window.index)
    @target_window.refresh
    if $game_party.all_dead?
      $scene = Scene_Gameover.new
    elsif @item.common_event_id > 0
      $game_temp.common_event_id = @item.common_event_id
      $scene = Scene_Pioneer_Book.new
    end
  end

  #--------------------------------------------------------------------------
  # * Confirm Item
  #--------------------------------------------------------------------------
  #def determine_item
  #  if @item.for_friend?
  #    show_target_window(@item_window.index % 2 == 0)
  #    if @item.for_all?
  #      @target_window.index = 99
  #    else
  #      if $game_party.last_target_index < @target_window.item_max
  #        @target_window.index = $game_party.last_target_index
  #      else
  #        @target_window.index = 0
  #      end
  #    end
  #  else
  #    use_item_nontarget
  #  end
  #end

end