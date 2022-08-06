#==============================================================================
# Debug Tools
#==============================================================================
# Author  : OriginalWij
# Version : 1.1
#==============================================================================

###############################################################################
###############################################################################
###############################################################################
# REMOVE THIS SCRIPT WHEN GAME COMPLETE !!!     FOR TESTING PURPOSES ONLY !!! #
###############################################################################
###############################################################################
###############################################################################

#==============================================================================
# v1.0
# - Initial release
# v1.1
# - Changed to be active only in "test" or "battle test" modes
#   (won't work if run from the .exe)
#==============================================================================

#==============================================================================
# Map Keys:
# ---------
# F5  = Teleport (warp)
# F6  = Save (with full party recovery)
# F7  = Add/Remove (items, gold, and/or party members)
# F8  = Icon IDs (find icon ID #)
# F9  = Default Debug (with improvements)
# ALT = Show Above Key Definitions
#
# Battle Keys:
# ------------
# F5  = Full Recovery --> party
# F6  = All HP = 1    --> party
# F7  = All HP = 1    --> enemies
# F8  = Kill All      --> enemies (auto-win)
# ALT = Show Above Key Definitions
#==============================================================================

#==============================================================================
# Window_NumberInput
#==============================================================================

class Window_NumberInput < Window_Base
  #--------------------------------------------------------------------------
  # Get index (New)
  #--------------------------------------------------------------------------
  def index
    return @index
  end
  #--------------------------------------------------------------------------
  # Set index (New)
  #--------------------------------------------------------------------------
  def index=(new_index)
    @index = new_index
  end
end

#==============================================================================
# Scene_Map
#==============================================================================

class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # Update (Mod)
  #--------------------------------------------------------------------------
  alias test_keys_update update unless $@
  def update
    test_keys_update
    check_test_keys# if $TEST # check for key press if in test mode
  end
  #--------------------------------------------------------------------------
  # Check Test Keys (New)
  #--------------------------------------------------------------------------
  def check_test_keys
    if Input.trigger?(Input.F5)    # Teleport
      Sound.play_decision
      $scene = Scene_Teleport.new
    elsif Input.trigger?(Input.F6) # Save
      Sound.play_save
      for actor in $game_party.members
        actor.recover_all
      end
      $scene = Scene_File.new(true, false, true)
    elsif Input.trigger?(Input.F7) # Add/Remove
      Sound.play_decision
      $scene = Scene_ItemsGoldParty.new
    elsif Input.trigger?(Input.F8) # Icon IDs
      Sound.play_decision
      $scene = Scene_Icon_ID_Find.new
#~     elsif Input.trigger?(PadConfig.dashLT) # Show Keys
#~       Sound.play_decision
#~       show_keys
    end
  end
  #--------------------------------------------------------------------------
  # Show Keys (New)
  #--------------------------------------------------------------------------
  def show_keys
    @keys_window = Window_Help.new
    txt = 'F5» Teleport  F6» Save  F7» Add/Remove  F8» Icon IDs'
    @keys_window.set_text(txt, 1)
    wait_for_button(PadConfig.dashLT)
    Sound.play_cancel
    @keys_window.dispose
  end
  #--------------------------------------------------------------------------
  # Wait For Button (New)
  #--------------------------------------------------------------------------
  def wait_for_button(button)
    loop do
      update_basic
      break if Input.trigger?(button)
    end
  end
end

#==============================================================================
# Scene_Battle
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # Update Party Command Selection (Mod)
  #--------------------------------------------------------------------------
  alias test_keys_update_party_com_sel update_party_command_selection unless $@
  def update_party_command_selection
    test_keys_update_party_com_sel
    check_test_keys# if $TEST or $BTEST # check for key press if in test mode(s)
  end
  #--------------------------------------------------------------------------
  # Update Actor Command Selection (Mod)
  #--------------------------------------------------------------------------
  alias test_keys_update_actor_com_sel update_actor_command_selection unless $@
  def update_actor_command_selection
    test_keys_update_actor_com_sel
    check_test_keys# if $TEST or $BTEST # check for key press if in test mode(s)
  end
  #--------------------------------------------------------------------------
  # Check Test Keys (New)
  #--------------------------------------------------------------------------
  def check_test_keys
    if Input.trigger?(Input.F5)    # Recover All --> Party
      Sound.play_recovery
      for actor in $game_party.members
        actor.recover_all
      end
      @status_window.refresh
    elsif Input.trigger?(Input.F6) # All HP = 1 --> Party
      Sound.play_actor_damage
      for actor in $game_party.members
        actor.hp = 1
      end
      @status_window.refresh
    elsif Input.trigger?(Input.F7) # All HP = 1 --> Enemies
      Sound.play_enemy_damage
      for enemy in $game_troop.existing_members
        enemy.hp = 1
      end
    elsif Input.trigger?(Input.F8) # Kill All --> Enemies (Auto-Win)
      Sound.play_enemy_collapse
      for enemy in $game_troop.existing_members
        enemy.add_state(1)
        enemy.perform_collapse
      end
#~     elsif Input.trigger?(PadConfig.dashLT) # Show keys
#~       Sound.play_decision
#~       show_keys
    end
  end
  #--------------------------------------------------------------------------
  # Show Keys (New)
  #--------------------------------------------------------------------------
  def show_keys
    @keys_window = Window_Help.new
    txt = 'F5» Heal  F6» HP=1  F7» Enemies HP=1  F8» Auto-Win'
    @keys_window.set_text(txt, 1)
    wait_for_button(PadConfig.dashLT)
    Sound.play_cancel
    @keys_window.dispose
  end
  #--------------------------------------------------------------------------
  # Wait For Button (New)
  #--------------------------------------------------------------------------
  def wait_for_button(button)
    loop do
      update_basic
      break if Input.trigger?(button)
    end
  end
end

#==============================================================================
# Scene_Debug
#==============================================================================

class Scene_Debug < Scene_Base
  #--------------------------------------------------------------------------
  # Update Left Window Input (Overwrite)
  #--------------------------------------------------------------------------
  def update_left_input
    if Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      $scene = Scene_Map.new
      return
    elsif Input.trigger?(PadConfig.decision)
      Sound.play_decision
      wlh = 28 
      if @left_window.mode == 0
        text1 = 'C » ON / OFF'
        @help_window.contents.draw_text(4, 0, 336, wlh, text1)
      else
        text1 = 'LEFT » -1'    
        text2 = 'RIGHT » +1'    
        text3 = 'L » -10'   
        text4 = 'R » +10'   
        text5 = 'X » -100'       # added
        text6 = 'Y » +100'       # added
        text7 = 'Z » Clear\c[0]' # added
        @help_window.contents.draw_text(4, wlh * 0, 336, wlh, text1)
        @help_window.contents.draw_text(4, wlh * 1, 336, wlh, text2)
        @help_window.contents.draw_text(4, wlh * 2, 336, wlh, text3)
        @help_window.contents.draw_text(4, wlh * 3, 336, wlh, text4)
        @help_window.contents.draw_text(172, wlh * 0, 336, wlh, text5) # added
        @help_window.contents.draw_text(172, wlh * 1, 336, wlh, text6) # added
        @help_window.contents.draw_text(172, wlh * 2, 336, wlh, text7) # added
      end
      @left_window.active = false
      @right_window.active = true
      @right_window.index = 0
    end
  end
  #--------------------------------------------------------------------------
  # Update Right Window Input (Mod)
  #--------------------------------------------------------------------------
  alias test_keys_sd_update_right_input update_right_input unless $@
  def update_right_input
    test_keys_sd_update_right_input
    if Input.repeat?(PadConfig.hud) and @right_window.mode == 1 # -100
      Sound.play_decision
      $game_variables[@right_window.top_id + @right_window.index] -= 100
      @right_window.draw_item(@right_window.index)
    elsif Input.repeat?(PadConfig.hud) and @right_window.mode == 1 # +100
      Sound.play_decision
      $game_variables[@right_window.top_id + @right_window.index] += 100
      @right_window.draw_item(@right_window.index)
    elsif Input.trigger?(Input.Z) and @right_window.mode == 1 # clear
      Sound.play_decision
      $game_variables[@right_window.top_id + @right_window.index] = 0
      @right_window.draw_item(@right_window.index)
    end
  end
end
  
#==============================================================================
# Map_Select_Window
#==============================================================================

class Map_Select_Window < Window_Base
  #--------------------------------------------------------------------------
  # Initialize
  #--------------------------------------------------------------------------
  def initialize
    super(0, 56, 160, 120)
    refresh
  end
  #--------------------------------------------------------------------------
  # Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.color = system_color
    self.contents.draw_text(0, 0, 120, WLH, 'Map ID:', 0)
    self.contents.draw_text(0, 32, 120, WLH, 'Map X:', 0)
    self.contents.draw_text(0, 64, 120, WLH, 'Map Y:', 0)
  end
end

#==============================================================================
# Map_Keys_Window
#==============================================================================

class Map_Keys_Window < Window_Base
  #--------------------------------------------------------------------------
  # Initialize
  #--------------------------------------------------------------------------
  def initialize
    super(0, 264, 160, 152)
    refresh
  end
  #--------------------------------------------------------------------------
  # Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.color = crisis_color
    self.contents.font.size = 16
    self.contents.draw_text(4, 0, 120, WLH, 'Z » Toggle Input', 0)
    self.contents.draw_text(4, 32, 120, WLH, 'R » Next Input', 0)
    self.contents.draw_text(4, 64, 120, WLH, 'L » Prev Input', 0)
    self.contents.draw_text(4, 96, 120, WLH, 'C » Teleport', 0)
  end
end

#==============================================================================
# Item_Keys_Window
#==============================================================================

class Item_Keys_Window < Window_Base
  #--------------------------------------------------------------------------
  # Initialize
  #--------------------------------------------------------------------------
  def initialize
    super(0, 208, 160, 208)
    unfresh
  end
  #--------------------------------------------------------------------------
  # Unfresh
  #--------------------------------------------------------------------------
  def unfresh
    self.contents.clear
  end
  #--------------------------------------------------------------------------
  # Refresh Items
  #--------------------------------------------------------------------------
  def refresh_items
    self.contents.clear
    self.contents.font.color = crisis_color
    self.contents.font.size = 16
    self.contents.draw_text(4, 2, 120, 24, 'UP » Prev Item', 0)
    self.contents.draw_text(4, 32, 120, 24, 'DOWN » Next Item', 0)
    self.contents.draw_text(4, 62, 120, 24, 'C » +1 Item', 0)
    self.contents.draw_text(4, 92, 120, 24, 'Z » +10 Items', 0)
    self.contents.draw_text(4, 122, 120, 24, 'Y » -1 Item', 0)
    self.contents.draw_text(4, 152, 120, 24, 'X » -10 Items', 0)
  end
  #--------------------------------------------------------------------------
  # Refresh Gold
  #--------------------------------------------------------------------------
  def refresh_gold
    self.contents.clear
    self.contents.font.color = crisis_color
    self.contents.font.size = 16
    self.contents.draw_text(4, 2, 120, 24, 'UP » +100', 0)
    self.contents.draw_text(4, 32, 120, 24, 'DOWN » -100', 0)
    self.contents.draw_text(4, 62, 120, 24, 'L » +1,000', 0)
    self.contents.draw_text(4, 92, 120, 24, 'R » -1,000', 0)
    self.contents.draw_text(4, 122, 120, 24, 'X » +10,000', 0)
    self.contents.draw_text(4, 152, 120, 24, 'Y » -10,000', 0)
  end
  #--------------------------------------------------------------------------
  # Refresh Actors
  #--------------------------------------------------------------------------
  def refresh_actors
    self.contents.clear
    self.contents.font.color = crisis_color
    self.contents.font.size = 16
    self.contents.draw_text(4, 2, 120, 24, 'RIGHT » Remove', 0)
    self.contents.draw_text(4, 32, 120, 24, 'LEFT » Add', 0)
    self.contents.draw_text(4, 62, 120, 24, 'C » Stats', 0)
  end
  #--------------------------------------------------------------------------
  # Refresh Actor's Stats
  #--------------------------------------------------------------------------
  def refresh_actors_stats
    self.contents.clear
    self.contents.font.color = crisis_color
    self.contents.font.size = 16
    self.contents.draw_text(4, 2, 120, 24, 'A » +1', 0)
    self.contents.draw_text(4, 32, 120, 24, 'Z » -1', 0)
    self.contents.draw_text(4, 62, 120, 24, 'L » +10', 0)
    self.contents.draw_text(4, 92, 120, 24, 'R » -10', 0)
    self.contents.draw_text(4, 122, 120, 24, 'X » +100', 0)
    self.contents.draw_text(4, 152, 120, 24, 'Y » -100', 0)
  end
end

#==============================================================================
# Misc_Window
#==============================================================================

class Misc_Window < Window_Base
  #--------------------------------------------------------------------------
  # Initialize
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x, y, width, height)
    refresh
  end
  #--------------------------------------------------------------------------
  # Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
  end
end

#==============================================================================
# Icon_Info_Window
#==============================================================================

class Icon_Info_Window < Window_Base
  #--------------------------------------------------------------------------
  # Initialize
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, $screen_width, 48)
  end
  #--------------------------------------------------------------------------
  # Set Text
  #--------------------------------------------------------------------------
  def set_text(text, align = 0)
    self.contents.clear
    self.contents.font.color = normal_color
    self.contents.font.size = 20
    self.contents.draw_text(4, -4, self.width - 40, WLH, text, align)
  end
end

#==============================================================================
# Icon_Window
#==============================================================================

class Icon_Window < Window_Command
  #--------------------------------------------------------------------------
  # Draw item
  #--------------------------------------------------------------------------
  def draw_item(index, enabled = true)
    rect = item_rect(index)
    rect.width -= 8
    icon = @commands[index].to_i
    draw_icon(icon, rect.x, rect.y, enabled)
  end
end

#==============================================================================
# Party_Member_Select_Window
#==============================================================================

class Party_Member_Select_Window < Window_Selectable
  #--------------------------------------------------------------------------
  # Initialize
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height, stats = false)
    super(x, y, width, height)
    if stats
      @pmsw = 36
      @item_max = 9
    else
      @pmsw = 40
      @item_max = 4
    end
    @column_max = 1
    self.opacity = 0
    self.index = 0
    self.contents.clear
  end
  #--------------------------------------------------------------------------
  # Get rectangle
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new(0, 0, 0, 0)
    rect.width = (contents.width + @spacing) / @column_max - @spacing
    rect.height = @pmsw
    rect.x = index % @column_max * (rect.width + @spacing)
    rect.y = index / @column_max * @pmsw
    return rect
  end
  #--------------------------------------------------------------------------
  # Update cursor
  #--------------------------------------------------------------------------
  def update_cursor
    if @index < 0               
      self.cursor_rect.empty
    elsif @index < @item_max    
      super
    elsif @index >= 100         
      self.cursor_rect.set(0, (@index - 100) * @pmsw,
        contents.width, @pmsw)
    else                        
      self.cursor_rect.set(0, 0, contents.width, @item_max * @pmsw)
    end
  end
end

#==============================================================================
# Item_Display_Window
#==============================================================================

class Item_Display_Window < Window_Selectable
  #--------------------------------------------------------------------------
  # Initialize
  #--------------------------------------------------------------------------
  def initialize(data)
    super(160, 52, 384, 368)
    @data = data
    @item_max = @data.size - 1
    @column_max = 1
    self.opacity = 0
    self.index = 0
    refresh
  end
  #--------------------------------------------------------------------------
  # Refresh
  #--------------------------------------------------------------------------
  def refresh
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
  end
  #--------------------------------------------------------------------------
  # Draw Item
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    item = @data[index + 1]
    if item != nil
      number = $game_party.item_number(item)
      rect.width -= 4
      draw_item_name(item, rect.x, rect.y, true)
      self.contents.draw_text(rect, sprintf(":%2d", number), 2)
    end
  end
end

#==============================================================================
# Scene_Teleport
#==============================================================================

class Scene_Teleport < Scene_Base
  #--------------------------------------------------------------------------
  # Initialize
  #--------------------------------------------------------------------------
  def initialize
    @map_id = 1
    @map_x = @map_y = @active_input = 0
    @cursor_count = 17
    @blink = false
  end
  #--------------------------------------------------------------------------
  # Start
  #--------------------------------------------------------------------------
  def start
    create_menu_background
    @info_window = Window_Help.new
    @map_name_window = Window_Help.new
    @info_window.width = @map_name_window.x = 160
    @map_name_window.width = 384
    @map_name_window.height = 33
    @info_window.create_contents
    @map_name_window.create_contents
    @map_display_window = Misc_Window.new(160, 32, 384, 384)
    @map_text_window = Misc_Window.new(160, -16, 384, 432)
    @map_text_window.opacity = 0
    @map_text_window.z = @map_display_window.z + 1
    @map_text_window.active = false
    @map = load_data(sprintf("Data/Map%03d.rvdata", @map_id))
    @map_select_window = Map_Select_Window.new
    @map_confirm_window = Misc_Window.new(0, 176, 160, 88)
    @map_keys_window = Map_Keys_Window.new
    @input_window = []
    for i in 0..2
      @input_window[i] = Window_NumberInput.new
      @input_window[i].number = 1 if i == 0
      @input_window[i].index = 2
      @input_window[i].update_cursor
      @input_window[i].digits_max = 3
      @input_window[i].x = 48
      @input_window[i].y = 56 + (i * 32)
    end
    @map_info = load_data('Data/MapInfos.rvdata')
    create_target(@map.data, 0, 0)
    @input_window[0].active = true
  end
  #--------------------------------------------------------------------------
  # Terminate
  #--------------------------------------------------------------------------
  def terminate
    dispose_menu_background
    dispose_target_map
    @info_window.dispose
    @map_name_window.dispose
    @map_display_window.dispose
    @map_text_window.dispose
    @map_select_window.dispose
    if @confirm_window != nil
      @confirm_window.dispose
      @confirm_window = nil
    end
    @map_confirm_window.dispose
    @map_keys_window.dispose
    for i in 0..2
      @input_window[i].dispose
    end
  end
  #--------------------------------------------------------------------------
  # Update
  #--------------------------------------------------------------------------
  def update
    update_menu_background
    case @active_input
    when 0
      @info_window.set_text('Select Map ...', 1)
    when 1
      @info_window.set_text('Select X ...', 1)
    when 2
      @info_window.set_text('Select Y ...', 1)
    else
      @info_window.set_text('Select X & Y ...', 1)
    end
    @info_window.set_text('Teleport?', 1) if @confirm_window != nil
    @map_display_window.update
    @map_text_window.update
    @map_select_window.update
    @map_keys_window.update
    for i in 0..2
      @input_window[i].update
    end
    if @confirm_window != nil
      @confirm_window.update
    end
    if Input.trigger?(Input.Z) # Toggle input
      if @confirm_window == nil and @active_input < 3
        Sound.play_decision
        @active_input += 10
        for i in 0..2
          @input_window[i].active = false
        end
        @map_text_window.active = true
      elsif @confirm_window == nil
        Sound.play_cancel
        @active_input -= 10
        @map_text_window.active = false
        @input_window[@active_input].active = true
      end
    elsif Input.trigger?(PadConfig.cancel) # Exit/Cancel
      Sound.play_cancel
      if @confirm_window != nil
        @confirm_window.active = false
        reset_active_input
        @confirm_window.dispose
        @confirm_window = nil
      else
        $scene = Scene_Map.new
      end
    elsif Input.trigger?(PadConfig.decision) # Accept/Confirm
      if @confirm_window != nil
        if @confirm_window.index == 0
          Sound.play_load
          $game_player.reserve_transfer(@input_window[0].number, 
            @input_window[1].number, @input_window[2].number, 0)
          for i in 1..20
            $game_map.screen.pictures[i].erase 
          end
          $scene = Scene_Map.new
        else
          Sound.play_decision
          @confirm_window.active = false
          reset_active_input
          @confirm_window.dispose
          @confirm_window = nil
        end
      else
        Sound.play_decision
        com1 = '    Confirm '
        com2 = '     Cancel '
        @confirm_window = Window_Command.new(160, [com1, com2])
        @confirm_window.index = 1
        @confirm_window.y = 180
        @confirm_window.opacity = 0
        for i in 0..2
          @input_window[i].active = false
        end
        @map_text_window.active = false
        @confirm_window.active = true
      end
    elsif Input.repeat?(PadConfig.up) and @map_text_window.active == true
      if @input_window[2].number > 0
        adjust_y(-1) # move up
      end
    elsif Input.repeat?(PadConfig.down) and @map_text_window.active == true
      if @input_window[2].number < @map.height - 1
        adjust_y(1)  # move down
      end
    elsif Input.repeat?(PadConfig.page_up) and @map_text_window.active == true
      if @input_window[1].number > 0
        adjust_x(-1) # move left
      end
    elsif Input.repeat?(PadConfig.page_down) and @map_text_window.active == true
      if @input_window[1].number < @map.width - 1
        adjust_x(1)  # move right
      end
    elsif Input.repeat?(PadConfig.up) or Input.repeat?(PadConfig.down) and 
        @map_text_window.active == false # adjust map and coordinates
      mapid = @input_window[0].number
      filename = sprintf("Data/Map%03d.rvdata", mapid)
      dispose_target_map
      @map_display_window.refresh
      @map_text_window.refresh
      if FileTest.exist?(filename)
        @map_id = @input_window[0].number
        if @input_window[1].number > 4
          @map_x = (@input_window[1].number - 5) * 256
        else
          @map_x = 0
        end
        if @input_window[2].number > 4
          @map_y = (@input_window[2].number - 5) * 256
        else
          @map_y = 0
        end
        @map = load_data(sprintf("Data/Map%03d.rvdata", @map_id))
        if @map_x > ((@map.width * 256) - 2816)
          @map_x = ((@map.width * 256) - 2816)
        end
        if @map_y > ((@map.height * 256) - 2816)
          @map_y = ((@map.height * 256) - 2816)
        end
        if @input_window[1].number > @map.width - 1
          index = @input_window[1].index
          @input_window[1].number = @map.width - 1
          @input_window[1].index = index
          @input_window[1].update_cursor
        end
        if @input_window[2].number > @map.height - 1
          index = @input_window[2].index
          @input_window[2].number = @map.height - 1
          @input_window[2].index = index
          @input_window[2].update_cursor
        end
        create_target(@map.data, @map_x, @map_y)
      else
        text = 'Map #' + @input_window[0].number.to_s + ' does not exist ...'
        @map_text_window.contents.draw_text(16, 4, 320, 24, text, 1)
      end
    elsif Input.trigger?(PadConfig.page_up) and @map_text_window.active == false
      Sound.play_cursor
      @active_input -= 1 # previous input
      @active_input = 2 if @active_input < 0
      for i in 0..2
        @input_window[i].active = false
      end
      @input_window[@active_input].active = true
    elsif Input.trigger?(PadConfig.page_down) and @map_text_window.active == false
      Sound.play_cursor
      @active_input += 1 # next input
      @active_input = 0 if @active_input > 2
      for i in 0..2
        @input_window[i].active = false
      end
      @input_window[@active_input].active = true
    end
    mx = calc_x
    my = calc_y
    if @map_text_window.active == true # adjust map cursor
      if @cursor_count == 0 and @blink == true
        @cursor_count = 17
        @blink = false
        @map_text_window.contents.fill_rect(mx, my + 48, 32, 32, 
          Color.new(0, 255, 0, 255 - @cursor_count * 15))
        @map_text_window.contents.fill_rect(mx + 2, my + 50, 28, 28, 
          Color.new(0, 255, 0, (255 - (@cursor_count * 15)) / 2))
      elsif @cursor_count == 0 and @blink == false
        @cursor_count = 17
        @blink = true
        @map_text_window.contents.fill_rect(mx, my + 48, 32, 32, 
          Color.new(0, 255, 0, @cursor_count * 15))
        @map_text_window.contents.fill_rect(mx + 2, my + 50, 28, 28, 
          Color.new(0, 255, 0, (@cursor_count * 15) / 2))
      else
        @cursor_count -= 1
        if @blink == true
          @map_text_window.contents.fill_rect(mx, my + 48, 32, 32, 
            Color.new(0, 255, 0, @cursor_count * 15))
          @map_text_window.contents.fill_rect(mx + 2, my + 50, 28, 28, 
            Color.new(0, 255, 0, (@cursor_count * 15) / 2))
        else
          @map_text_window.contents.fill_rect(mx, my + 48, 32, 32, 
            Color.new(0, 255, 0, 255 - @cursor_count * 15))
          @map_text_window.contents.fill_rect(mx + 2, my + 50, 28, 28, 
            Color.new(0, 255, 0, (255 - (@cursor_count * 15)) / 2))
        end
      end
    else
      mapid = @input_window[0].number
      filename = sprintf("Data/Map%03d.rvdata", mapid)
      if FileTest.exist?(filename)
        @map_text_window.contents.fill_rect(mx, my + 48, 32, 32, 
          Color.new(255, 0, 0, 255))
        @map_text_window.contents.fill_rect(mx + 2, my + 50, 28, 28, 
          Color.new(255, 0, 0, 128))
      else
        @map_text_window.contents.clear_rect(mx, my + 48, 32, 32)
      end
    end
  end
  #--------------------------------------------------------------------------
  # Create Target Map, Cursor, and Text
  #--------------------------------------------------------------------------
  def create_target(map_data, ox, oy)
    @viewport = Viewport.new(@map_display_window.x + 16, 
      @map_display_window.y + 16, 352,352)
    @viewport.z = @map_display_window.z
    @target_map = Tilemap.new(@viewport)
    @target_map.bitmaps[0] = Cache.system("TileA1")
    @target_map.bitmaps[1] = Cache.system("TileA2")
    @target_map.bitmaps[2] = Cache.system("TileA3")
    @target_map.bitmaps[3] = Cache.system("TileA4")
    @target_map.bitmaps[4] = Cache.system("TileA5")
    @target_map.bitmaps[5] = Cache.system("TileB")
    @target_map.bitmaps[6] = Cache.system("TileC")
    @target_map.bitmaps[7] = Cache.system("TileD")
    @target_map.bitmaps[8] = Cache.system("TileE")
    @target_map.map_data = map_data
    @target_map.ox = ox / 8
    @target_map.oy = oy / 8
    filename = sprintf("Data/Map%03d.rvdata", @map_id)
    if FileTest.exist?(filename)
      mx = calc_x
      my = calc_y
      @map_text_window.contents.fill_rect(mx, my + 48, 32, 32, 
        Color.new(255, 0, 0, 255))
      @map_text_window.contents.fill_rect(mx + 2, my + 50, 28, 28, 
        Color.new(255, 0, 0, 128))
      @map_text_window.contents.font.size = 16
      text = @map_info[@map_id].name
      @map_text_window.contents.draw_text(16, 4, 320, 24, text, 1)
    end
  end
  #--------------------------------------------------------------------------
  # Dispose Target Map
  #--------------------------------------------------------------------------
  def dispose_target_map
    unless @target_map == nil
      @target_map.dispose
      @target_map = nil
    end
  end
  #--------------------------------------------------------------------------
  # Reset active input
  #--------------------------------------------------------------------------
  def reset_active_input
    case @active_input
    when 0
      @input_window[0].active = true
    when 1
      @input_window[1].active = true
    when 2
      @input_window[2].active = true
    else
      @map_text_window.active = true
    end
  end
  #--------------------------------------------------------------------------
  # Adjust X
  #--------------------------------------------------------------------------
  def adjust_x(adj_x)
    Sound.play_cursor
    index = @input_window[1].index
    @input_window[1].number += adj_x
    @input_window[1].index = index
    @input_window[1].update_cursor
    if @input_window[1].number > 4
      @map_x = (@input_window[1].number - 5) * 256
    else
      @map_x = 0
    end
    if @map_x > ((@map.width * 256) - 2816)
      @map_x = ((@map.width * 256) - 2816)
    end
    dispose_target_map
    @map_text_window.refresh
    create_target(@map.data, @map_x, @map_y)
  end
  #--------------------------------------------------------------------------
  # Adjust Y
  #--------------------------------------------------------------------------
  def adjust_y(adj_y)
    Sound.play_cursor
    index = @input_window[2].index
    @input_window[2].number += adj_y
    @input_window[2].index = index
    @input_window[2].update_cursor
    if @input_window[2].number > 4
      @map_y = (@input_window[2].number - 5) * 256
    else
      @map_y = 0
    end
    if @map_y > ((@map.height * 256) - 2816)
      @map_y = ((@map.height * 256) - 2816)
    end
    dispose_target_map
    @map_text_window.refresh
    create_target(@map.data, @map_x, @map_y)
  end
  #--------------------------------------------------------------------------
  # Calc X
  #--------------------------------------------------------------------------
  def calc_x
    x = @input_window[1].number
    if x > 4 and x < (@map.width - 5)
      x = 5
    elsif x > 4
      x -= (@map.width - 11)
    end
    x *= 32
    return x
  end
  #--------------------------------------------------------------------------
  # Calc Y
  #--------------------------------------------------------------------------
  def calc_y
    y = @input_window[2].number
    if y > 4 and y < (@map.height - 5)
      y = 5
    elsif y > 4
      y -= (@map.height - 11)
    end
    y *= 32
    return y
  end
end

#==============================================================================
# Scene_ItemsGoldParty
#==============================================================================

class Scene_ItemsGoldParty < Scene_Base
  #--------------------------------------------------------------------------
  # Initialize
  #--------------------------------------------------------------------------
  def initialize
    @itemsgoldparty = 0
    @text = []
    @sub_text = []
    @text[0] = 'Add/Remove Items ...'
    @text[1] = 'Add/Remove Weapons ...'
    @text[2] = 'Add/Remove Armor & Accessories ...'
    @text[3] = "Increase/Decrease 'Gold' ..."
    @text[4] = 'Add/Remove Actors & Adjust Actor Stats ...'
    @sub_text[0] = 'Select Item & Add or Remove ...'
    @sub_text[1] = 'Select Weapon & Add or Remove ...'
    @sub_text[2] = 'Select Armor/Accessory & Add or Remove ...'
    @sub_text[3] = 'Add or Remove Gold ...'
    @sub_text[4] = 'Add or Remove Actors ...'
    @sub_text[5] = 'Increase/Decrease Stats ...'
    @stat_mode = false
  end
  #--------------------------------------------------------------------------
  # Start
  #--------------------------------------------------------------------------
  def start
    create_menu_background
    @help_window = Window_Help.new
    @display_window = Misc_Window.new(160, 56, 384, 360)
    @gold_window = Window_Gold.new(160, 56)
    @gold_window.z = @display_window.z + 1
    @gold_window.opacity = 0
    @gold_window.visible = false
    com1 = ' Items '
    com2 = ' Weapons '
    com3 = ' Armor '
    com4 = ' Gold '
    com5 = ' Actors '
    @command_window = Window_Command.new(160, [com1, com2, com3, com4, com5])
    @command_window.y = 56
    @key_window = Item_Keys_Window.new
    @command_window.active = true
  end
  #--------------------------------------------------------------------------
  # Terminate
  #--------------------------------------------------------------------------
  def terminate
    dispose_menu_background
    @help_window.dispose
    @gold_window.dispose
    @display_window.dispose
    @key_window.dispose
    @command_window.dispose
    if @item_window != nil
      @item_window.dispose
      @item_window = nil
    end
  end
  #--------------------------------------------------------------------------
  # Update
  #--------------------------------------------------------------------------
  def update
    update_menu_background
    @help_window.update
    if @itemsgoldparty == 0
      @help_window.set_text(@text[@command_window.index], 1)
    else
      @help_window.set_text(@sub_text[@itemsgoldparty - 1], 1) unless @stat_mode
      @help_window.set_text(@sub_text[@itemsgoldparty], 1) if @stat_mode
    end
    @gold_window.update
    @display_window.update
    @key_window.update
    @command_window.update
    if @item_window != nil
      @item_window.update
    end
    update_keys
    case @itemsgoldparty
    when 0       # main
      @display_window.active = false
      @command_window.active = true
      update_main
    when 1, 2, 3 # items
      @command_window.active = false
      @item_window.active = true
      update_inventory
    when 4       # gold
      @command_window.active = false
      @display_window.active = true
      update_gold
    when 5       # party
      @command_window.active = false
      @display_window.active = true
      update_party unless @stat_mode
      update_stats if @stat_mode
    end
  end
  #--------------------------------------------------------------------------
  # Update Main
  #--------------------------------------------------------------------------
  def update_main
    if Input.trigger?(PadConfig.cancel)     # Exit
      Sound.play_cancel
      $scene = Scene_Map.new
    elsif Input.trigger?(PadConfig.decision)  # Select
      Sound.play_decision
      case @command_window.index
      when 0 # items
        @data = $data_items
        @itemsgoldparty = 1
        if @item_window != nil
          @item_window.dispose
        end
        @item_window = Item_Display_Window.new(@data)
      when 1 # weapons
        @data = $data_weapons
        @itemsgoldparty = 2
        if @item_window != nil
          @item_window.dispose
        end
        @item_window = Item_Display_Window.new(@data)
      when 2 # armor & accessories
        @data = $data_armors
        @itemsgoldparty = 3
        if @item_window != nil
          @item_window.dispose
        end
        @item_window = Item_Display_Window.new(@data)
      when 3 # gold
        if @item_window != nil
          @item_window.dispose
          @item_window = nil
        end
        @itemsgoldparty = 4
        @gold_window.visible = true
      when 4 # party
        if @item_window != nil
          @item_window.dispose
          @item_window = nil
        end
        @itemsgoldparty = 5
        draw_party
        @select_window = Party_Member_Select_Window.new(160, 60, 384, 360)
      end
    end
  end
  #--------------------------------------------------------------------------
  # Update Inventory
  #--------------------------------------------------------------------------
  def update_inventory
    if Input.trigger?(PadConfig.cancel)      # Return
      Sound.play_cancel
      @itemsgoldparty = 0
      @item_window.dispose
      @item_window = nil
    elsif Input.repeat?(PadConfig.decision)    # +1
      Sound.play_decision
      $game_party.gain_item(@data[@item_window.index + 1], 1)
      @item_window.draw_item(@item_window.index)
    elsif Input.repeat?(PadConfig.hud)    # -1
      Sound.play_decision
      $game_party.lose_item(@data[@item_window.index + 1], 1)
      @item_window.draw_item(@item_window.index)
    elsif Input.repeat?(Input.Z)    # +10
      Sound.play_decision
      $game_party.gain_item(@data[@item_window.index + 1], 10)
      @item_window.draw_item(@item_window.index)
    elsif Input.repeat?(PadConfig.hud)    # -10
      Sound.play_decision
      $game_party.lose_item(@data[@item_window.index + 1], 10)
      @item_window.draw_item(@item_window.index)
    end
  end
  #--------------------------------------------------------------------------
  # Update Gold
  #--------------------------------------------------------------------------
  def update_gold
    if Input.trigger?(PadConfig.cancel)      # Return
      Sound.play_cancel
      @gold_window.visible = false
      @itemsgoldparty = 0
    elsif Input.repeat?(PadConfig.up)   # +100
      Sound.play_cursor
      $game_party.gain_gold(100)
      @gold_window.refresh
    elsif Input.repeat?(PadConfig.down) # -100
      Sound.play_cursor
      $game_party.lose_gold(100)
      @gold_window.refresh
    elsif Input.repeat?(PadConfig.page_up)    # +1,000
      Sound.play_cursor
      $game_party.gain_gold(1000)
      @gold_window.refresh
    elsif Input.repeat?(PadConfig.page_down)    # -1,000
      Sound.play_cursor
      $game_party.lose_gold(1000)
      @gold_window.refresh
    elsif Input.repeat?(PadConfig.hud)    # +10,000
      Sound.play_cursor
      $game_party.gain_gold(10000)
      @gold_window.refresh
    elsif Input.repeat?(PadConfig.hud)    # -10,000
      Sound.play_cursor
      $game_party.lose_gold(10000)
      @gold_window.refresh
    end
  end
  #--------------------------------------------------------------------------
  # Update Party
  #--------------------------------------------------------------------------
  def update_party
    @select_window.update
    if Input.trigger?(PadConfig.cancel)       # Return
      Sound.play_cancel
      draw_party(true)
      @select_window.dispose
      @select_window = nil
      @itemsgoldparty = 0
    elsif Input.trigger?(PadConfig.decision)    # Stats
      Sound.play_decision
      @actor = $game_actors[@select_window.index + 1]
      draw_party(true)
      @select_window.dispose
      @select_window = Party_Member_Select_Window.new(160, 58, 384, 360, true)
      draw_stats
      @stat_mode = true
    elsif Input.trigger?(PadConfig.page_up)  # Add
      if !$game_party.members.include?($game_actors[@select_window.index + 1])
        Sound.play_cursor
        $game_party.add_actor(@select_window.index + 1)
        draw_party
      end
    elsif Input.trigger?(PadConfig.page_down) # Remove
      if $game_party.members.include?($game_actors[@select_window.index + 1])
        Sound.play_cursor
        $game_party.remove_actor(@select_window.index + 1)
        draw_party
      end
    end
  end
  #--------------------------------------------------------------------------
  # Update Stats
  #--------------------------------------------------------------------------
  def update_stats
    @select_window.update
    if Input.trigger?(PadConfig.cancel)       # Return
      Sound.play_cancel
      draw_stats(true)
      @select_window.dispose
      @select_window = Party_Member_Select_Window.new(160, 60, 384, 360)
      @select_window.index = @actor.id - 1
      @stat_mode = false
      draw_party
    elsif Input.repeat?(PadConfig.dash)    # +1
      change_stat(1)
      draw_stats
    elsif Input.repeat?(Input.Z)    # -1
      change_stat(-1)
      draw_stats
    elsif Input.repeat?(PadConfig.page_up)    # +10
      change_stat(10)
      draw_stats
    elsif Input.repeat?(PadConfig.page_down)    # -10
      change_stat(-10)
      draw_stats
    elsif Input.repeat?(PadConfig.hud)    # +100
      change_stat(100)
      draw_stats
    elsif Input.repeat?(PadConfig.hud)    # -100
      change_stat(-100)
      draw_stats
    end
  end
  #--------------------------------------------------------------------------
  # Change Stats
  #--------------------------------------------------------------------------
  def change_stat(amount)
    case @select_window.index
    when 0 # Level
      if @actor.level + amount >= 1 #and @actor.level + amount <= 99
        Sound.play_cursor
        @actor.change_level(@actor.level + amount, false)
      end
    when 1 # max Hp
      if @actor.maxhp + amount >= 1 #and @actor.maxhp + amount <= 9999
        Sound.play_cursor
        @actor.maxhp += amount
      end
    when 2 # Hp
      if @actor.hp + amount >= 1 #and @actor.hp + amount <= @actor.maxhp
        Sound.play_cursor
        @actor.hp += amount
      end
    when 3 # max Mp
      if @actor.maxmp + amount >= 0 #and @actor.maxmp + amount <= 9999
        Sound.play_cursor
        @actor.maxmp += amount
      end
    when 4 # Mp
      if @actor.mp + amount >= 0 #and @actor.mp + amount <= @actor.maxmp
        Sound.play_cursor
        @actor.mp += amount
      end
    when 5 # ATK
      if @actor.atk + amount >= 1 #and @actor.atk + amount <= 999
        Sound.play_cursor
        @actor.atk += amount
      end
    when 6 # DEF
      if @actor.def + amount >= 1 #and @actor.def + amount <= 999
        Sound.play_cursor
        @actor.def += amount
      end
    when 7 # SPI
      if @actor.spi + amount >= 1 #and @actor.spi + amount <= 999
        Sound.play_cursor
        @actor.spi += amount
      end
    when 8 # AGI
      if @actor.agi + amount >= 1 #and @actor.agi + amount <= 999
        Sound.play_cursor
        @actor.agi += amount
      end
    end
  end
  #--------------------------------------------------------------------------
  # Update Keys
  #--------------------------------------------------------------------------
  def update_keys
    @key_window.contents.clear
    case @itemsgoldparty
    when 1, 2, 3                 # items
      @key_window.refresh_items
    when 4                       # gold
      @key_window.refresh_gold
    when 5                       # actors
      @key_window.refresh_actors unless @stat_mode
      @key_window.refresh_actors_stats if @stat_mode
    else
      @key_window.unfresh
    end
  end
  #--------------------------------------------------------------------------
  # Draw Party
  #--------------------------------------------------------------------------
  def draw_party(erase = false)
    @display_window.contents.clear
    unless erase
      for i in 1..4
        actor = $game_actors[i]
        if $game_party.members.include?(actor)
          @display_window.draw_actor_graphic(actor, 24, i * 40)
          @display_window.draw_actor_name(actor, 60, i * 40 - 28)
        else
          @display_window.draw_actor_graphic(actor, 328, i * 40)
          @display_window.draw_actor_name(actor, 208, i * 40 - 28)
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # Draw Stats
  #--------------------------------------------------------------------------
  def draw_stats(erase = false)
    @display_window.contents.clear
    unless erase
      actr_lvl = sprintf("Level: %3d", @actor.level)
      actr_mhp = sprintf("Max Hp: %5d", @actor.maxhp)
      actr_chp = sprintf("Hp: %5d", @actor.hp)
      actr_mmp = sprintf("Max Mp: %5d", @actor.maxmp)
      actr_cmp = sprintf("Mp: %5d", @actor.mp)
      actr_atk = sprintf("Off: %5d", @actor.atk)
      actr_def = sprintf("Def: %5d", @actor.def)
      actr_spi = sprintf("Int:  %5d", @actor.spi)
      actr_agi = sprintf("Agi: %5d", @actor.agi)
      spc = 36
      @display_window.contents.draw_text(4, spc * 0 + 8, 352, 24, actr_lvl, 0)
      @display_window.contents.draw_text(4, spc * 1 + 8, 352, 24, actr_mhp, 0)
      @display_window.contents.draw_text(4, spc * 2 + 8, 352, 24, actr_chp, 0)
      @display_window.contents.draw_text(4, spc * 3 + 8, 352, 24, actr_mmp, 0)
      @display_window.contents.draw_text(4, spc * 4 + 8, 352, 24, actr_cmp, 0)
      @display_window.contents.draw_text(4, spc * 5 + 8, 352, 24, actr_atk, 0)
      @display_window.contents.draw_text(4, spc * 6 + 8, 352, 24, actr_def, 0)
      @display_window.contents.draw_text(4, spc * 7 + 8, 352, 24, actr_spi, 0)
      @display_window.contents.draw_text(4, spc * 8 + 8, 352, 24, actr_agi, 0)
    end
  end
end

#==============================================================================
# Scene_Icon_ID_Find
#==============================================================================

class Scene_Icon_ID_Find < Scene_Base
  #--------------------------------------------------------------------------
  # Initialize
  #--------------------------------------------------------------------------
  def initialize
    @iconset = 'IconSet'
  end
  #--------------------------------------------------------------------------
  # Start
  #--------------------------------------------------------------------------
  def start
    create_menu_background
    bitmap = Cache.system(@iconset)
    cols = bitmap.width / 24
    rows = bitmap.height / 24
    bitmap.dispose
    commands = []
    for i in 0..(cols * rows) - 1
      commands.push(i.to_s) 
    end
    @info_window = Icon_Info_Window.new
    @icon_window = Icon_Window.new($screen_width, commands, 16, ((cols * rows) / 16), 8)
    @icon_window.height = 368
    @icon_window.y = 48
  end
  #--------------------------------------------------------------------------
  # Terminate
  #--------------------------------------------------------------------------
  def terminate
    dispose_menu_background
    @info_window.dispose
    @icon_window.dispose
  end
  #--------------------------------------------------------------------------
  # Update
  #--------------------------------------------------------------------------
  def update
    update_menu_background
    @icon_window.update
    @info_window.set_text('Icon ID: ' + @icon_window.index.to_s, 1)
    if Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      $scene = Scene_Map.new
    end
  end
end