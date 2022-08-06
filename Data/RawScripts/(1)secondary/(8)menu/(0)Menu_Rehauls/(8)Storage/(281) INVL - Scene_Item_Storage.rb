################################################################################
# Scene_ItemStorage                                                            #
#------------------------------------------------------------------------------#

class Scene_ItemStorage < Scene_Base

  def start
    super
    create_menu_background
    @viewport = Viewport.new(0, 0, $screen_width, $screen_height)
    
    @help_window = Window_Help_Better.new(0,$screen_height-60,$screen_width,60)
    @help_window.viewport = @viewport
    
    @storeunstore_window = Window_StoreUnstore.new
    @storeunstore_window.active = true
    
    @item_window = Invl_Window_Item.new(0, 40, $screen_width / 2, $screen_height-120-24)
    @item_window.refresh
    @item_window.opacity = 0
    @saved_item_index = -1
    @item_help_background = Window_ItemStorage_Backing_Window.new(0, 0, $screen_width / 2, $screen_height-120,'inventory')
    @item_window.help_window = @help_window
    @item_window.active = false
    
    @storage_window = Window_ItemStorage.new($screen_width / 2, 40, $screen_width / 2, $screen_height-60-40)
    @storage_window.help_window = @help_window
    @storage_window.refresh
    @storage_window.active = false
    @storage_window.opacity = 0
    
    @storage_help = Window_ItemStorage_Backing_Window.new($screen_width / 2, 0, $screen_width / 2, $screen_height-60,'storage')
    @saved_storage_index = -1
    @item_window.help_window.set_text("Storage Chest")
    @storage_window.help_window.set_text("Storage Chest")
    
    @space_gauge_window = Window_SpaceGauge.new(0,$screen_height-120,$screen_width/2,60)
    
    $dropping_item = false
    $storing_item = false
    $withdrawing_item = false
    $box_buy = false
    $box_sell = false
    
    @num_input = Window_ItemNumInput.new
    @num_input.visible = false
    
  end

  def terminate
    super
    dispose_menu_background
    @viewport.dispose
    @help_window.dispose
    @item_window.dispose
    @item_help_background.dispose
    @storage_window.dispose
    @storage_help.dispose
    @storeunstore_window.dispose
    @space_gauge_window.dispose
    @num_input.dispose
  end

  def return_scene
    $scene = Scene_Pioneer_Book.new
  end

  def update
    super
    @space_gauge_window.update    
    @help_window.update
    @item_window.update
    @storage_window.update
    @storeunstore_window.update
    if @item_window.active
      update_item_selection
    elsif @storage_window.active
      update_storage_selection
    elsif @storeunstore_window.active
      update_storeunstore_selection
    elsif @num_input.visible
      num_input_input
    end
    if @storage_window.active or @item_window.active
      if @storage_window.item == nil 
        @storage_window.index -= 1 unless @storage_window.index == 0
      end
      if @item_window.item == nil
        @item_window.index -= 1 unless @item_window.index == 0
      end
    else
      @item_window.help_window.set_text("Storage Chest")
      @storage_window.help_window.set_text("Storage Chest")
    end
    if @storage_window.index != @saved_storage_index
      @saved_storage_index = @storage_window.index
      @storage_help.refresh(@storage_window.item,'storage')
    end
    if @item_window.index != @saved_item_index
      @saved_item_index = @item_window.index
      @item_help_background.refresh(@item_window.item,'inventory')
    end
  end

  def refresh_handler
    if @storage_window.active == true
      while @storage_window.item == nil and @storage_window.index >= 0
        @storage_window.index -= 1 
      end
    end
    new_index = @storage_window.index if @item_window.active
    new_index = @storage_window.jump_to_index_position(@item_window.item)
    @storage_window.refresh
    @item_window.refresh
    @item_help_background.refresh(@item_window.item,'inventory')
    @storage_help.refresh(@storage_window.item,'storage')
    @space_gauge_window.refresh
  end
  
  def update_storeunstore_selection
    unless @storeunstore_activated
      @storeunstore_activated = true
      return
    end
    if Input.trigger?(PadConfig.cancel)
      return_scene
      Sound.play_cancel
    elsif Input.trigger?(PadConfig.decision)
      if @storeunstore_window.index == 0
        Sound.play_decision
        hide_storeunstore_window
        @item_window.active = true
      else
        Sound.play_decision
        hide_storeunstore_window
        @storage_window.active = true
      end
    end
  end

  def update_item_selection
    if Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      show_storeunstore_window
      return
    elsif Input.trigger?(PadConfig.decision)
      @item = @item_window.item
      if $game_party.item_number(@item) > 0
        if @item == nil
          Sound.play_buzzer
        else
          Sound.play_decision	
          item_possible = $game_party.item_number(@item)
          if item_possible > 1
            @num_input.set_max(item_possible)
            @num_input.visible = true
            @item_window.active = false
          else
            Sound.play_decision
            $game_party.lose_item(@item, 1)
            $game_party.store_item(@item, 1)
            #handles all refresh changes
            refresh_handler          
          end
        end
      else
        Sound.play_buzzer
      end
    elsif Input.trigger?(PadConfig.hud)
      @item = @item_window.item
      if $game_party.item_number(@item) > 0
        if @item == nil 
          Sound.play_buzzer
        else
          Sound.play_decision	
          item_possible = $game_party.item_number(@item)
          $game_party.lose_item(@item, item_possible)
          $game_party.store_item(@item, item_possible)
          #handles all refresh changes
          refresh_handler          
        end
      else
        Sound.play_buzzer
      end
    end
  end
  
  def update_storage_selection
    if Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      show_storeunstore_window
      return
    elsif Input.trigger?(PadConfig.decision)
      @item = @storage_window.item
      if @item != nil
        if $game_party.overall_checker(@item, 1)
          Sound.play_decision	
          item_possible = $game_party.full_stack_shop(@item) - $game_party.item_number(@item)
          if item_possible > $game_party.stored_item_number(@item)
            item_possible = $game_party.stored_item_number(@item)
          end
          if item_possible > 1
            @num_input.set_max(item_possible)
            @num_input.visible = true
            @storage_window.active = false
          else
            Sound.play_decision	
            $game_party.unstore_item(@item, 1)
            $game_party.gain_item(@item, 1)
            #handles all refresh changes
            refresh_handler
          end
        else
          Sound.play_buzzer
        end
      else
        Sound.play_buzzer
      end
    elsif Input.trigger?(PadConfig.hud)
      @item = @storage_window.item
      if @item != nil
        if $game_party.overall_checker(@item, 1)
          Sound.play_decision	
          item_possible = $game_party.full_stack_shop(@item) - $game_party.item_number(@item)
          if item_possible > $game_party.stored_item_number(@item)
            item_possible = $game_party.stored_item_number(@item)
          end
          Sound.play_decision	
          $game_party.unstore_item(@item, item_possible)
          $game_party.gain_item(@item, item_possible)
          #handles all refresh changes
          refresh_handler
        else
          Sound.play_buzzer
        end
      else
        Sound.play_buzzer
      end
    end
  end

  def num_input_input
    @num_input.update
    if Input.trigger?(PadConfig.cancel)
      if @storeunstore_window.index == 0
        hide_storeunstore_window
        @item_window.active = true
        @storage_window.active = false
        @num_input.visible = false
      elsif @storeunstore_window.index == 1
        hide_storeunstore_window
        @item_window.active = false
        @storage_window.active = true
        @num_input.visible = false
      end
    elsif Input.trigger?(PadConfig.decision)
      if @storeunstore_window.index == 0
        $game_party.store_item(@item, @num_input.qn)
        $game_party.lose_item(@item, @num_input.qn)
        Sound.play_decision
        hide_storeunstore_window
        #handles all refresh changes
        refresh_handler          
        @item_window.active = true
        @storage_window.active = false
        @num_input.visible = false
      elsif @storeunstore_window.index == 1
        $game_party.unstore_item(@item, @num_input.qn)
        $game_party.gain_item(@item, @num_input.qn)
        Sound.play_decision
        hide_storeunstore_window
        $storing_item = false
        $withdrawing_item = true
        #handles all refresh changes
        refresh_handler          
        @item_window.active = false
        @storage_window.active = true
        @num_input.visible = false
      end
    end
  end
####################################################################################
  def show_storeunstore_window
    @storeunstore_window.open
    @storeunstore_window.active = true
    @item_window.active = false
    @storage_window.active = false
  end
  
  def hide_storeunstore_window
    @storeunstore_window.close
    @storeunstore_activated = false
    @storeunstore_window.active = false
  end
  
  def show_space_gauge_window
    @space_gauge_window.open
    @space_gauge_window.refresh
  end
  
  def hide_space_gauge_window
    @space_gauge_window.close
  end
  
  def show_item_window
    @item_window.open
    @storage_window.close
    @item_window.active = true
    @storeunstore_window.active = false
    @storage_window.active = false
  end
  
  def hide_item_window
    @item_window.close
    @item_window.active = false
    @item_activated = false
    @storeunstore_window.active = true
  end
  
  def show_storage_window
    @storage_window.open
    @item_window.close
    @storage_window.active = true
    @storeunstore_window.active = false
    @item_window.active = false
  end
  
  def hide_storage_window
    @storage_window.close
    @storage_window.active = false
    @storage_activated = false
    @storeunstore_window.active = true
  end
  
end