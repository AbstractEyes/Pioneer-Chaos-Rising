class Window_Instruction < Window_Base
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  # actor : actor
  #--------------------------------------------------------------------------
  def initialize
    super( 0, 336, $screen_height, 80)
    self.contents = Bitmap.new(width - 32, height - 32)
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.name = "Arial"
    self.contents.font.size = 18
    self.contents.font.color = normal_color
    #Change this text to whatever instructions you want to have!
    self.contents.draw_text(000, 9, 404, 32, "Enter = Confirm,")
    self.contents.draw_text(120, 9, 404, 32, "Backspace = Delete,")
    self.contents.draw_text(275, 9, 404, 32, "Keyboard = Text,")
    self.contents.draw_text(400, 9, 404, 32, "Shift = Capital")
  end
end

#==============================================================================
# ** Window_TextName
#------------------------------------------------------------------------------
# super ( 224, 32, 224, 80)
#==============================================================================
class Window_TextName < Window_Base
  
  def initialize
    if DRAW_FACE
      super (164, 0, 224, 128)
    else
      super (164, 66, 224, 62)
    end
    self.contents = Bitmap.new(width - 32, height - 32)
    @actor = $game_actors[$game_temp.name_actor_id]
    refresh
  end
  
  def refresh
    self.contents.clear
    self.contents.font.name = "Arial"
    self.contents.font.size = 32
    self.contents.font.color = normal_color
    if DRAW_FACE
      draw_actor_face(@actor, 2, @actor.index * 96 + 2, 92)
      self.contents.draw_text(112, 32, 64, 32, "Name:")
    else
      draw_actor_graphic(@actor, 32, 32)
      self.contents.draw_text(64, 0, 64, 32, "Name:")
    end
  end

end

#==============================================================================
# ** Window_NameEdit
#------------------------------------------------------------------------------
# This window is used to edit your name on the input name screen.
#==============================================================================
class Window_NameEdit < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  # actor : actor
  # max_char : maximum number of characters
  #--------------------------------------------------------------------------
  def initialize(actor, max_char)
    super(16, 128, 512, 96)
    self.contents = Bitmap.new(width - 32, height - 32)
    @actor = actor
    @name = actor.name
    @max_char = max_char
    # Fit name within maximum number of characters
    name_array = @name.split(//)[0...@max_char]
    @name = ""
    for i in 0...name_array.size
      @name += name_array[i]
    end
    @default_name = @name
    @index = name_array.size
    refresh
    update_cursor_rect
  end
  #--------------------------------------------------------------------------
  # * Return to Default Name
  #--------------------------------------------------------------------------
  def restore_default
    @name = @default_name
    @index = @name.split(//).size
    refresh
    update_cursor_rect
  end
  #--------------------------------------------------------------------------
  # * Add Character
  # (0)character : text (0)character to be added
  #--------------------------------------------------------------------------
  def add(character)
    if @index < @max_char and character != ""
    @name += character
    @index += 1
    refresh
    update_cursor_rect
    end
  end
  #--------------------------------------------------------------------------
  # * Delete Character
  #--------------------------------------------------------------------------
  def back
    if @index > 0
    # Delete 1 text (0)character
    name_array = @name.split(//)
    @name = ""
    for i in 0...name_array.size-1
      @name += name_array[i]
    end
    @index -= 1
    refresh
    update_cursor_rect
    end
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    # Draw name
    self.contents.font.size = 42
    name_array = @name.split(//)
    for i in 0...@max_char
      c = name_array[i]
      if c == nil
        c = "_"
      end
      x = 258 - @max_char * 14 + i * 26
      self.contents.draw_text(x, 15, 28, 42, c, 1)
    end
  end
  #--------------------------------------------------------------------------
  # * Cursor Rectangle Update
  #--------------------------------------------------------------------------
  def update_cursor_rect
    x = 262 - @max_char * 14 + @index * 26
    self.cursor_rect.set(x, 46, 20, 5)
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    update_cursor_rect
  end

end

#==============================================================================
# ** Window_NameInput
#------------------------------------------------------------------------------
# This window is used to select text characters on the input name screen.
#==============================================================================
class Window_NameInput < Window_Base
CHARACTER_TABLE =
[
"", ""
]
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(0, 128, $screen_height, 0)
    self.contents = Bitmap.new(width - 32, height - 32)
    @index = 0
    refresh
  end
  #--------------------------------------------------------------------------
  # * Text Character Acquisition
  #--------------------------------------------------------------------------
  def character
    return CHARACTER_TABLE[@index]
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
  end

end

#==============================================================================
# ** Scene_Name
#------------------------------------------------------------------------------
# This class performs name input screen processing.
#==============================================================================
class Scene_Name
  #--------------------------------------------------------------------------
  # * Main Processing
  #--------------------------------------------------------------------------
  def main
    # Get actor
    @actor = $game_actors[$game_temp.name_actor_id]
    # Make windows
    @edit_window = Window_NameEdit.new(@actor, $game_temp.name_max_char)
    @edit_window.back_opacity = 160
    @input_window = Window_NameInput.new
    @inst_window = Window_Instruction.new
    @inst_window.back_opacity = 160
    @nametext_window = Window_TextName.new
    @nametext_window.back_opacity = 160
    @spriteset = Spriteset_Map.new
    # Execute transition
    Graphics.transition
    # Main loop
    loop do
      # Update game screen
      Graphics.update
      # Update input information
      Input.update
      # Frame update
      update
      # Abort loop if screen is changed
      if $scene != self
        break
      end
    end
    # Prepare for transition
    Graphics.freeze
    # Dispose of windows
    @edit_window.dispose
    @input_window.dispose
    @inst_window.dispose
    @nametext_window.dispose
    @spriteset.dispose
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
  # Update windows
  @edit_window.update
  @input_window.update
  @nametext_window.update
  @inst_window.update
  # If C button was pressed
  if Input.trigger?(Input.C)
  # If cursor position is at [OK]
  if @input_window.character == nil
  # If name is empty
  if @edit_window.name == ""
  # If name is empty
  if @edit_window.name == ""
  # Play buzzer SE
  Sound.play_buzzer
  return
  end
  # Play decision SE
  Sound.play_cursor
  return
  end
  # Change actor name
  @actor.name = @edit_window.name
  # Play decision SE
  Sound.play_cursor
  # Switch to map screen
  $scene = Scene_Map.new
  return
  end
  # If cursor position is at maximum
  if @edit_window.index == $game_temp.name_max_char
  # Play buzzer SE
  Sound.play_buzzer
  return
  end
  # If text (0)character is empty
  if @input_window.character == ""
  # Play buzzer SE
  Sound.play_buzzer
  return
  end
  # Play decision SE
  Sound.play_cursor
  # Add text (0)character
  @edit_window.add(@input_window.character)
  return
  end
  end
end

#~ #==============================================================================
#~ # ** Scene_Name Leters Modification Made By Nattmath and Improved Cyclope
#~ #------------------------------------------------------------------------------
#~ # Makes you imput stuf with the keyboard
#~ #==============================================================================
#~ class Scene_Name
#~   alias name_input_update update
#~   def update
#~     if @edit_window.index != $game_temp.name_max_char
#~       (65...91).each{|i|
#~       if Input.trigger?(i)
#~         Sound.play_cursor
#~         let = Input::Key.index(i)
#~         let = let.downcase unless Input.press?(Input::Key['Shift'])
#~         @edit_window.add(let)
#~       end}
#~       (48...58).each{|i|
#~         if Input.trigger?(i)
#~         Sound.play_cursor
#~         let = Input::Key.index(i)
#~         @edit_window.add(let)
#~       end}
#~       (186...192).each{|i|
#~         if Input.trigger?(i)
#~         Sound.play_cursor
#~         let = Input::Key.index(i)
#~         @edit_window.add(let)
#~       end}
#~       (219...222).each{|i|
#~       if Input.trigger?(i)
#~         Sound.play_cursor
#~         let = Input::Key.index(i)
#~         @edit_window.add(let)
#~       end}
#~     end
#~     if @edit_window.name != ""
#~       if Input.trigger?(Input::Key['Backspace'])
#~         @edit_window.back
#~         Sound.play_cancel
#~       elsif Input.trigger?(Input::Key['Arrow Left'])
#~         @edit_window.back
#~         Sound.play_cancel
#~       end
#~     end
#~     if Input.trigger?(Input::Key['Enter'])
#~       if @edit_window.name != "" and @edit_window.name != " " and @edit_window.name != "  " and @edit_window.name != "   " and @edit_window.name != "	" and @edit_window.name != "	 " and @edit_window.name != "	  " and @edit_window.name != "	   " and @edit_window.name != "		" and @edit_window.name != "		 " and @edit_window.name != "		  " and @edit_window.name != "		   " and @edit_window.name != "			" and @edit_window.name != "			 " and @edit_window.name != "			  " and @edit_window.name != "			   " and @edit_window.name != "				"
#~       # Change actor name
#~       @actor.name = @edit_window.name
#~       # Play decision SE
#~       Sound.play_decision
#~       # Switch to map screen
#~       $scene = Scene_Map.new
#~       return
#~     else
#~       # If name is empty return to default name
#~       # Play buzzer SE
#~       @edit_window.restore_default
#~       Sound.play_buzzer
#~       return
#~       end
#~     end
#~     if Input.trigger?(Input::Key['Space'])
#~       if @edit_window.index != $game_temp.name_max_char
#~       @actor.name = @edit_window.name
#~       Sound.play_cursor
#~       @edit_window.add(" ")
#~       end
#~     end
#~   end
#~ end