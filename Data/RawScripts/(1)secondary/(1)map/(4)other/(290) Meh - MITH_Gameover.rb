# Checkpoint Gameover
# Version 2.4
# By Mithran at RMVX.net
# Requested by Hamstt
# Alternate graphic and gameover switch features requested by Flood_Master
# Vehicle location save, skip gameover screen, and autocheckpoint save requested
# by squareenix
# changable GameOver screen requested by justbob722
# Last update April 24, 2009
# Please do not redistribute without asking!
# Allows the creator to set a checkpoint to allow the player to continue after
# death.  Displays a menu to allow the player to select to continue.

# If no checkpoint is set, its a standard Game Over and straight to (2)title.
# If a checkpoint is set, the game checks to see whether or not it is enabled.
# If the checkpoint is not enabled, its standard Game Over.  If it is, you get
# a menu asking if you want to continue with your alternate Game Over graphic.

# Usage: Use the following Advanced > Script Commands to change the current
# checkpoint or enable/disable continue.

# Event > Advanced > Script Commands

# set_checkpoint
# Sets checkpoint to the player's current location.

# set_checkpoint_here
# Sets checkpoint to the event's current location.

# clear_checkpoint
# Clears the checkpoint.

# disable_checkpoint
# Disables the use of continue, forcing a game over if a battle is lost.
# This is different than clear_checkpoint, because the checkpoint is perserved
# and may be reenabled.

# enable_checkpoint
# Reenables the checkpoint.  Perserves the last checkpoint set.

# set_checkpoint_to(map_id, x, y, direction)
# Sets the checkpoint to the selected corrdinates.
# Directions - 2 = down, 4 = left, 6 = right, 8 = up
# Example:
# set_checkpoint_to(1, 15, 15, 2)
# Sets the checkpoint to map 1, at coordinate [15, 15] facing down

# set_checkpoint_variable(mapVar, xVar, yVar, direction)
# By using the event Event Command > Control Variable, the creator can store
# map id, x of player, y of player, and direction of player into variables
# use this command to set the checkpoint to these variables at a later time
# Example -
# set_checkpoint_variable(25, 26, 27, 28)
# sets the checkpoint to the map ID stored in variable 25, x coordinate in
# variable 26, y coordinate in variable 27, and direction saved in variable 28

# set_gameover_graphic("filename")
# use this before an just before an evented battle or evented loss to temporarily
# change the graphic.
# Filename goes in quote, as shown above.  The file must be imported into the
# graphics/system folder.  
# The next game over shown will use the picture file selected.  To revert it to
# the default scene (the one set in the module) use:
# clear_gameover_graphic
# If you do not use any argument, it will reset the graphic instead
# The temporary graphic persists over save games.  Getting a game over
# will the graphic, though, so you do not need to manually reset it.

# Install: Insert on the materials page above main and below any custom
# Game Over scenes if used.  (not tested with Custom Game Over scenes)

#=============================== CUSTOMIZATION =================================

module CheckPointGameOver
  GOLD_LOSS_PCT = 0
  # Percentage of gold to be lost when "Continue" is selected
  CUSTOM_GAMEOVER_GRAPHIC = "GameOver"
  # A second graphic that will only display when there is a valid checkpoint
  # The file must be located in the /Graphics/System folder
  # Setting this option to false (without quotes) will use the imported GameOver
  # for both
  
  CLEAR_EVENT_ON_LOSE = true
  # If set to true, getting a Game Over will end event execution.  This only
  # applies to events executed and currently running BEFORE gameover is called.
  # If set to false, the event will continue executing.
  # Unless you really need for an event to continue processing through a game
  # over, this should be left on true.
  GAMEOVER_SWITCH_ID = 80
  # This switch is turned ON after a Game Over.  You can use this to set up
  # conditional branches or a common event to execute certain events after a
  # continue.  NOTE: This only turns this switch ON after Game Over.
  # Switch must be turned off manually by the user!
  RESTORE_ALL = true
  # If set to true, the party will be completely restored on Game Over
  # If set to false, only the first party member will be revived with 1 HP
  # Using this, you can set up an event to decide what you want to be restored
  # after a game over.
  INCLUDE_SHUTDOWN = true
  # Includes a shut down command on the continue menu if set to true.
  
  SKIP_GAMEOVER = false
  # Skips the Game Over screen completley and returns to checkpoint
  # immediatley on GameOver.
  
  RETURN_VEHICLES = true
  # Returns vehicles to their locations at the time of the last checkpoint save.
  
  SET_CHECKPOINT_ON_SAVE = false
  # Sets the checkpoint to the current location automatically just before
  # the 'save' command is executed.

#====================== DO NOT CHANGE ANYTHING BELOW HERE ======================
  
end


#==============================================================================
# ** Scene_Gameover
#------------------------------------------------------------------------------
#  This class performs game over screen processing.
#==============================================================================

class Scene_Gameover < Scene_Base
  
  unless $@
  class << self
    alias new_checkpoint_gameover new
    def new
      if !$game_system.disable_checkpoint && CheckPointGameOver::SKIP_GAMEOVER
        if CheckPointGameOver::GAMEOVER_SWITCH_ID > 0
          $game_switches[CheckPointGameOver::GAMEOVER_SWITCH_ID] = true
        end
        RPG::BGM.fade(80)
        RPG::BGS.fade(80)
        RPG::ME.fade(80)
        Scene_Gameover.new_checkpoint_gameover.back_to_checkpoint
        Graphics.fadeout(30)
        Graphics.wait(15)
        return Scene_Map.new
      else
        new_checkpoint_gameover
      end
    end
  end
  end
  
  alias start_gameover_checkpoint start
  def start
    if CheckPointGameOver::GAMEOVER_SWITCH_ID > 0
      $game_switches[CheckPointGameOver::GAMEOVER_SWITCH_ID] = true
    end
    start_gameover_checkpoint
    create_command_window unless $game_system.disable_checkpoint
  end
    
  def create_command_window
    sels = [Vocab.continue, Vocab.to_title]
    sels << Vocab.shutdown if CheckPointGameOver::INCLUDE_SHUTDOWN
    @command_window = Window_Command.new(172, sels)
    @command_window.x = (Graphics.width - @command_window.width) / 2
    @command_window.y = Graphics.height - (@command_window.height + 32)
    @command_window.index = 0
    @command_window.openness = 0
    @command_window.open
  end

  alias update_inputsA update
  def update
    if @command_window
      update_inputsB
    else
      update_inputsA
    end
  end
  
  alias create_gameover_graphic_checkpoint create_gameover_graphic
  def create_gameover_graphic
    create_gameover_graphic_checkpoint
    unless $game_system.disable_checkpoint || $game_system.gameover_graphic
      @sprite.bitmap = Cache.system(CheckPointGameOver::CUSTOM_GAMEOVER_GRAPHIC) if CheckPointGameOver::CUSTOM_GAMEOVER_GRAPHIC
    end
    if $game_system.gameover_graphic != nil
      @sprite.bitmap = Cache.system($game_system.gameover_graphic)
    end
  end
  
  alias terminate_checkpoint terminate
  def terminate
    @command_window.dispose unless @command_window.nil?
    terminate_checkpoint
  end
  
  def command_shutdown
    Sound.play_decision
    RPG::BGM.fade(800)
    RPG::BGS.fade(800)
    RPG::ME.fade(800)
    $scene = nil
  end
  
  def command_continue
    Sound.play_decision
    RPG::BGM.fade(800)
    RPG::BGS.fade(800)
    RPG::ME.fade(800)
    back_to_checkpoint
    fade = (Graphics.brightness > 0)
    Graphics.fadeout(30)
    $scene = Scene_Map.new
    Graphics.wait(15)
  end
      
  def command_title
    Sound.play_decision
    RPG::BGM.fade(800)
    RPG::BGS.fade(800)
    RPG::ME.fade(800)
    $scene = Scene_Title.new
    Graphics.fadeout(120)
  end
    
  def update_inputsB
    @command_window.update unless @command_window.nil?
    if Input.trigger?(PadConfig.decision) && !@command_window.nil?
      case @command_window.index
      when 0 # Continue
        command_continue; return
      when 1 # To Title
        command_title; return
      when 2 # Shutdown
        command_shutdown; return
      end
    end
    update_inputsA
  end
  
  def back_to_checkpoint
    $game_party.clear_actions
    $game_troop.clear
    $game_temp.battle_proc = nil
    $game_system.gameover_graphic = nil
    check = $game_system.checkpoint
    recover_party
    $game_party.lose_gold($game_party.gold * CheckPointGameOver::GOLD_LOSS_PCT / 100)
    map_id = check[0]
    x = check[1]
    y = check[2]
    direction = check[3]
    move_to_checkpoint(map_id, x, y, direction)
    $game_map.autoplay              # Automatically switch BGM and BGS
    $game_map.update
    clear_events if CheckPointGameOver::CLEAR_EVENT_ON_LOSE
  end
  
  def recover_party
    if CheckPointGameOver::RESTORE_ALL
      for actor in $game_party.members
        actor.recover_all
      end
    else
      $game_party.members[0].hp = 1 unless $game_party.members[0].nil?
    end
  end
  
  def clear_events
    $game_troop.clear
    $game_map.interpreter.setup(nil)
  end
  
  def move_to_checkpoint(map_id, x, y, direction)
    if $game_player.vehicle_type > 0
      $game_player.get_off_vehicle_simple
    end
    $game_player.set_direction(direction)
    $game_map.setup(map_id)     # Move to other map
    $game_player.moveto(x, y)
    return unless CheckPointGameOver::RETURN_VEHICLES
    $game_system.vehicle_locs.each_with_index { |v, i|
      $game_map.vehicles[i].set_location(v[0], v[1], v[2])
    }
  end

end

#class Game_Player
#
#  def get_off_vehicle_simple
#    $game_map.vehicles[@vehicle_type].get_off     # Get off processing
#    @transparent = false                        # Remove transparency
#    @through = false                              # Passage OFF
#    @move_speed = 4                               # Return move speed
#    @vehicle_type = -1
#  end

#end


class Game_System
  attr_accessor :checkpoint
  attr_accessor :disable_checkpoint
  attr_accessor :vehicle_locs
  
  alias initialize_checkpoint_gameover initialize
  def initialize
    initialize_checkpoint_gameover
    @vehicle_locs = []
  end
  
  def checkpoint
    return @checkpoint
  end
  
  def disable_checkpoint
    @disable_checkpoint ||= false
    return true if checkpoint.nil?
    return @disable_checkpoint
  end    
    
end

class Game_Interpreter
  def set_checkpoint
    set_checkpoint_to($game_map.map_id, $game_player.x, $game_player.y, $game_player.direction)
  end
  
  def command_353
    $game_temp.next_scene = "gameover"
    @index += 1
    return false
  end
  
  def set_checkpoint_here
    if $game_map.events[@original_event_id] != nil
      checkx = $game_map.events[@original_event_id].x
      checky = $game_map.events[@original_event_id].y
      set_checkpoint_to(@map_id, checkx, checky, $game_player.direction)
    end
  end
  
  def clear_checkpoint
    $game_system.checkpoint = nil
  end
  
  def enable_checkpoint
    $game_system.disable_checkpoint = false
  end
  
  def disable_checkpoint
    $game_system.disable_checkpoint = true
  end
  
  def set_checkpoint_to(mapidnum, xcoord, ycoord, direct = 2)
    direct = 2 if (direct > 8) || (direct % 2 == 1) || (direct < 2)
    $game_system.checkpoint = [mapidnum, xcoord, ycoord, direct]
    $game_system.vehicle_locs = []
    $game_map.vehicles.each_with_index { |v, i|
      $game_system.vehicle_locs[i] = [v.map_id, v.x, v.y, v.direction]
    }      
  end
    
  def set_checkpoint_variable(var1, var2, var3, var4 = 0)
    direct = $game_variables[var4]
    direct = 2 if var4 == 0
    mapidnum = $game_variables[var1]
    xcoord = $game_variables[var2]
    ycoord = $game_variables[var3]
    set_checkpoint_to(mapidnum, xcoord, ycoord, direct)
  end
  
  def set_gameover_graphic(filename = nil)
    $game_system.gameover_graphic = filename
  end
  
  def clear_gameover_graphic
    set_gameover_graphic
  end
  
end

class Scene_File
  
  alias write_save_data_checkpoint_gameover write_save_data
  def write_save_data(*args)
    $game_map.interpreter.set_checkpoint if CheckPointGameOver::SET_CHECKPOINT_ON_SAVE
    write_save_data_checkpoint_gameover(*args)
  end
  
end

class Game_Vehicle
  attr_reader :map_id
end

class Game_System
  attr_accessor :gameover_graphic
end