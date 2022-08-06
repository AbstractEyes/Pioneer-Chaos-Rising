#===============================================================================
# 
# Yanfly Engine Melody - Extended Movement
# Last Date Updated: 2010.02.05
# Level: Easy, Normal, Hard
# 
# This script adds for easy 8 directional movement and (0)character sheet support.
# Although the (0)character sheets need to be specially made, once done, they're
# extremely flexibile and offer a plethora of (0)options. 8 directional movement
# allows the player to save a lot of time traveling basically anywhere quicker.
# There's also the ability to adjust the innate default dashing speed.
# 
#===============================================================================
# Updates
# -----------------------------------------------------------------------------
# o 2010.02.05 - Compatibility with Battle Engine Melody.
# o 2010.01.05 - Added Reverse Poses.
# o 2010.01.10 - Idling pose (0)options added.
# o 2010.01.08 - Started Script and Finished.
#===============================================================================
# Instructions
# -----------------------------------------------------------------------------
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials but above ▼ Main. Remember to save.
# 
# -----------------------------------------------------------------------------
# Setting up 8 Directional Sprite Sheets
# -----------------------------------------------------------------------------
# 1. Create a typical 4 column by 2 row sprite sheet. The columns are as follow
# 
#    Down            Down Left       Down Dash       Down Left Dash
#    Left            Upper Left      Left Dash       Upper Left Dash
#    Right           Down Right      Right Dash      Down Right Dash
#    Up              Upper Right     Up Dash         Up Right Dash
# 
#    Ready/Idle      Victory Pose    2H Swing        
#    Damage          Evade/Dodge     1H Swing        
#    Dazed/Critical  Dead 1-3        Cast/Use Item   
#    Marching        Downed/Fallen   Channeling      
# 
# 2. For the file name, place _8D after it. 
#    example: Actor_01.png would look like Actor_01_8D.png
# 
# 3. And just use them as your actor's graphic. It's as easy as that. You can
#    download some of the pre-made actor sheets on Pockethouse as reference.
# 
# -----------------------------------------------------------------------------
# Equip Tags - Insert the following tags into Weapon and Armour noteboxes.
# -----------------------------------------------------------------------------
# <dash speed: +x%>  or  <dash speed: -x%>
# Equipping the said piece of weapon/armour will increase or decrease the
# player's onscreen dash speed by n%. This effect is cumulative across all
# of the party members with the item equipped.
# 
# -----------------------------------------------------------------------------
# Movement Route Event Editor Call Scripts
# -----------------------------------------------------------------------------
# @mirror = true    or    @mirror = false
# This will mirror the image of the used (0)character set. They will still face
# the same direction but use the other side's (0)character sheet instead.
#
# @pose = "value"
# This will cause your to do a unique pose so long as they have an _8D sheet.
# Replace value with any of the cases below:
#
# --------OLD 8D--------------------------------------------------------
#    Normal            Ready             Damage            Critical
#    March             Victory           Evade             Fallen
#    Dead1             Dead2             Dead3             2H Swing
#    1H Swing          Cast              Channel
#    1H Swing Reverse  2H Swing Reverse
# 
# break_pose
# This breaks the (0)character out of a pose and back to regular standing format.
# Important for those long pose sequences. If the player regains movement, the
# player will also break out of a pose when the next movement input is done.
# 
#===============================================================================
# Compatibility
# -----------------------------------------------------------------------------
# - Works With: Anything that doesn't affect movement systems.
#===============================================================================

$imported = {} if $imported == nil
$imported["ExtendedMovement"] = true

module YEM
  module MOVEMENT
    
    # The following constant allows for 8 directional movement. Set it to
    # false if you don't wish for it to occur.
    ENABLE_8D_MOVEMENT = true
    
    # If the above is enabled, tap directioning is also available. For those
    # wondering what tap directioning is, the player can just tap a direction
    # and the player (0)character will face that direction rather than straight
    # out walking that direction. The following adjusts how many frames the
    # game will allow leeway for tap facing.
    TAP_COUNTER = 6
    
    # The next two constants allow you to set idle poses after your player
    # doesn't touch any directional keys for however many frames. Remember,
    # there are 60 frames in a second. If you don't want a pose to trigger,
    # just leave the array empty and nothing will happen. Otherwise, fill 
    # the array with any poses you would like the (0)character do. Poses will
    # be randomly selected from the array.
    IDLE_POSE   = ["Ready", "March", "Victory"]
    IDLE_FRAMES = 360
    
    # The following determines the dash speed given to your player. The speed
    # value is a percentage out of 100. With 150, the player dashes +50% faster.
    # With 200, the player dashes twice as fast. You know the drill.
    DASH_SPEED_VARIABLE = 1
    DEFAULT_DASH_SPEED  = 200
    
  end # MOVEMENT
end # YEM

#===============================================================================
# Editting anything past this point may potentially result in causing computer
# damage, incontinence, explosion of user's head, coma, death, and/or halitosis.
# Therefore, edit at your own risk.
#===============================================================================

module YEM
  module REGEXP
    module BASEITEM
      DASH_SPEED = /^<(?:DASH_SPEED|dash speed):[ ]*([\+\-]\d+)([%％])>/i
    end
  end
end
module YEM::MOVEMENT
  SUFFIX = "8D"
end # YEM::MOVEMENT

#===============================================================================
# (0X)RPG.rb::BaseItem
#===============================================================================

class RPG::BaseItem
  
  #--------------------------------------------------------------------------
  # new method: dash_speed_bonus
  #--------------------------------------------------------------------------
  def dash_speed_bonus
    return @dash_speed_bonus if @dash_speed_bonus != nil
    @dash_speed_bonus = 0
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when YEM::REGEXP::BASEITEM::DASH_SPEED
        @dash_speed_bonus = $1.to_i
      end
    } # end self.note.split
    return @dash_speed_bonus
  end
  
end # (0X)RPG.rb::BaseItem

#===============================================================================
# Game_Character
#===============================================================================

class Game_Character
  
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :mirror
  attr_accessor :pose
  attr_accessor :pattern
  attr_accessor :pre_pose
  attr_accessor :walk_anime
  attr_accessor :step_anime
  attr_accessor :move_frequency
  attr_accessor :anti_straighten
  attr_accessor :dash_speed
  
  #--------------------------------------------------------------------------
  # new method: break_pose
  #--------------------------------------------------------------------------
  def break_pose
    return unless @pose != nil and @pose != ""
    @pattern = 1
    @pose = nil
    @anti_straighten = false
    @walk_anime = true
    @step_anime = false
    set_direction(@pre_pose) if @pre_pose != nil
    @pre_pose = nil
  end
  
  #--------------------------------------------------------------------------
  # alias method: update_stop
  #--------------------------------------------------------------------------
  alias update_stop_em update_stop unless $@
  def update_stop
    return if @anti_straighten
    update_stop_em
  end
  
  #--------------------------------------------------------------------------
  # alias method: move_lower_left
  #--------------------------------------------------------------------------
  alias move_lower_left_em move_lower_left
  def move_lower_left
    move_lower_left_em
    @direction = 1 unless @direction_fix
  end
  
  #--------------------------------------------------------------------------
  # alias method: move_lower_right
  #--------------------------------------------------------------------------
  alias move_lower_right_em move_lower_right
  def move_lower_right
    move_lower_right_em
    @direction = 3 unless @direction_fix
  end
  
  #--------------------------------------------------------------------------
  # alias method: move_upper_left
  #--------------------------------------------------------------------------
  alias move_upper_left_em move_upper_left
  def move_upper_left
    move_upper_left_em
    @direction = 7 unless @direction_fix
  end
  
  #--------------------------------------------------------------------------
  # alias method: move_upper_right
  #--------------------------------------------------------------------------
  alias move_upper_right_em move_upper_right
  def move_upper_right
    move_upper_right_em
    @direction = 9 unless @direction_fix
  end
  
  if YEM::MOVEMENT::ENABLE_8D_MOVEMENT
  #--------------------------------------------------------------------------
  # overwrite method: move_random
  #--------------------------------------------------------------------------
  def move_random
    case rand(7)
    when 0;  move_down
    when 1;  move_left
    when 2;  move_right
    when 3;  move_up
    when 4
      if !dir8_passable?(2) and dir8_passable?(4)
        move_left
      elsif dir8_passable?(2) and !dir8_passable?(4)
        move_down
      else
        move_down
        move_left
        @direction = 1
      end
    when 5
      if !dir8_passable?(2) and dir8_passable?(6)
        move_right
      elsif dir8_passable?(2) and !dir8_passable?(6)
        move_down
      else
        move_down
        move_right
        @direction = 3
      end
    when 6
      if !dir8_passable?(8) and dir8_passable?(4)
        move_left
      elsif dir8_passable?(8) and !dir8_passable?(4)
        move_up
      else
        move_up
        move_left
        @direction = 7
      end
    when 7
      if !dir8_passable?(8) and dir8_passable?(6)
        move_right
      elsif dir8_passable?(8) and !dir8_passable?(6)
        move_up
      else
        move_up
        move_right
        @direction = 9
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: move_toward_player
  #--------------------------------------------------------------------------
  def move_toward_player
    sx = distance_x_from_player
    sy = distance_y_from_player
    if sx != 0 or sy != 0
      if sx.abs > sy.abs
        sx > 0 ? move_left : move_right
        if @move_failed and sy != 0
          sy > 0 ? move_up : move_down
        end
      elsif sx.abs < sy.abs
        sy > 0 ? move_up : move_down
        if @move_failed and sx != 0
          sx > 0 ? move_left : move_right
        end
      elsif sx.abs == sy.abs
        if sx > 0 and sy > 0
          move_up
          move_left
          @direction = 7
        elsif sx < 0 and sy > 0
          move_up
          move_right
          @direction = 9
        elsif sx > 0 and sy < 0
          move_down
          move_left
          @direction = 1
        elsif sx < 0 and sy < 0
          move_down
          move_right
          @direction = 3
        end
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: move_away_from_player
  #--------------------------------------------------------------------------
  def move_away_from_player
    sx = distance_x_from_player
    sy = distance_y_from_player
    if sx != 0 or sy != 0
      if sx.abs > sy.abs
        sx > 0 ? move_right : move_left
        if @move_failed and sy != 0
          sy > 0 ? move_down : move_up
        end
      elsif sx.abs < sy.abs
        sy > 0 ? move_down : move_up
        if @move_failed and sx != 0
          sx > 0 ? move_right : move_left
        end
      elsif sx.abs == sy.abs
        if sx > 0 and sy > 0
          move_down
          move_right
          @direction = 3
        elsif sx < 0 and sy > 0
          move_down
          move_left
          @direction = 1
        elsif sx > 0 and sy < 0
          move_up
          move_right
          @direction = 9
        elsif sx < 0 and sy < 0
          move_up
          move_left
          @direction = 7
        end
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: move_forward
  #--------------------------------------------------------------------------

  def move_forward
    case @direction
    when 2;  move_down(false)
    when 4;  move_left(false)
    when 6;  move_right(false)
    when 8;  move_up(false)
    when 1 
      if !dir8_passable?(2) and dir8_passable?(4)
        move_left
      elsif dir8_passable?(2) and !dir8_passable?(4)
        move_down
      else
        move_down
        move_left
      end
    when 3 # 
      if !dir8_passable?(2) and dir8_passable?(6)
        move_right
      elsif dir8_passable?(2) and !dir8_passable?(6)
        move_down
      else
        move_down
        move_right
      end
    when 7
      if !dir8_passable?(8) and dir8_passable?(4)
        move_left
      elsif dir8_passable?(8) and !dir8_passable?(4)
        move_up
      else
        move_up
        move_left
      end
    when 9
      if !dir8_passable?(8) and dir8_passable?(6)
        move_right
      elsif dir8_passable?(8) and !dir8_passable?(6)
        move_up
      else
        move_up
        move_right
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: move_backward
  #--------------------------------------------------------------------------
  def move_backward
    last_direction_fix = @direction_fix
    @direction_fix = true
    case @direction
    when 2;  move_up(false)
    when 4;  move_right(false)
    when 6;  move_left(false)
    when 8;  move_down(false)
    when 9
      if !dir8_passable?(2) and dir8_passable?(4)
        move_left
      elsif dir8_passable?(2) and !dir8_passable?(4)
        move_down
      else
        move_down
        move_left
      end
    when 7
      if !dir8_passable?(2) and dir8_passable?(6)
        move_right
      elsif dir8_passable?(2) and !dir8_passable?(6)
        move_down
      else
        move_down
        move_right
      end
    when 3
      if !dir8_passable?(8) and dir8_passable?(4)
        move_left
      elsif dir8_passable?(8) and !dir8_passable?(4)
        move_up
      else
        move_up
        move_left
      end
    when 1
      if !dir8_passable?(8) and dir8_passable?(6)
        move_right
      elsif dir8_passable?(8) and !dir8_passable?(6)
        move_up
      else
        move_up
        move_right
      end
    end
    @direction_fix = last_direction_fix
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: turn_random
  #--------------------------------------------------------------------------
  def turn_random
    case rand(7)
    when 0; turn_up
    when 1; turn_right
    when 2; turn_left
    when 3; turn_down
    when 4; set_direction(1)
    when 5; set_direction(3)
    when 6; set_direction(7)
    when 7; set_direction(9)
    end
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: turn_toward_player
  #--------------------------------------------------------------------------
  def turn_toward_player
    sx = distance_x_from_player
    sy = distance_y_from_player
    if sx.abs > sy.abs
      sx > 0 ? turn_left : turn_right
    elsif sx.abs < sy.abs
      sy > 0 ? turn_up : turn_down
    elsif sx.abs == sy.abs
      if sx > 0 and sy > 0
        set_direction(7)
      elsif sx < 0 and sy > 0
        set_direction(9)
      elsif sx > 0 and sy < 0
        set_direction(1)
      elsif sx < 0 and sy < 0
        set_direction(3)
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: turn_away_from_player
  #--------------------------------------------------------------------------
  def turn_away_from_player
    sx = distance_x_from_player
    sy = distance_y_from_player
    if sx.abs > sy.abs
      sx > 0 ? turn_right : turn_left
    elsif sx.abs < sy.abs
      sy > 0 ? turn_down : turn_up
    elsif sx.abs == sy.abs
      if sx > 0 and sy > 0
        set_direction(3)
      elsif sx < 0 and sy > 0
        set_direction(1)
      elsif sx > 0 and sy < 0
        set_direction(9)
      elsif sx < 0 and sy < 0
        set_direction(7)
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: dir8_passable?
  #--------------------------------------------------------------------------
  def dir8_passable?(direction)
    case direction
    when 1
      return passable?(@x-1, @y+1)
    when 2
      return passable?(@x, @y+1)
    when 3
      return passable?(@x+1, @y+1)
    when 4
      return passable?(@x-1, @y)
    when 6
      return passable?(@x+1, @y)
    when 7
      return passable?(@x-1, @y-1)
    when 8
      return passable?(@x, @y-1)
    when 9
      return passable?(@x+1, @y-1)
    end
  end
  end # YEM::MOVEMENT::ENABLE_8D_MOVEMENT
  
end # Game_Character

#===============================================================================
# Game_Player
#===============================================================================

class Game_Player < Game_Character
  
  ##--------------------------------------------------------------------------
  ## overwrite method: update_move
  ##--------------------------------------------------------------------------
  #def update_move
  #  update_dash_speed
  #  distance = 2 ** @move_speed
  #  if dash?
  #    distance *= @dash_speed
  #    distance /= 100
  #  end
  #  distance *= 6 if shoved?
  #  distance = Integer(distance)
  #  @real_x = [@real_x - distance, @x * 256].max if @x * 256 < @real_x
  #  @real_x = [@real_x + distance, @x * 256].min if @x * 256 > @real_x
  #  @real_y = [@real_y - distance, @y * 256].max if @y * 256 < @real_y
  #  @real_y = [@real_y + distance, @y * 256].min if @y * 256 > @real_y
  #  update_bush_depth unless moving?
  #  return if shoved?
  #  if @walk_anime
  #    @anime_count += 1.5
  #  elsif @step_anime
  #    @anime_count += 1
  #  end
  #end
  
  #--------------------------------------------------------------------------
  # overwrite method: update_dash_speed
  #--------------------------------------------------------------------------
  def update_dash_speed
    dash_variable = YEM::MOVEMENT::DASH_SPEED_VARIABLE
    if $game_variables[dash_variable] <= 0
      $game_variables[dash_variable] = YEM::MOVEMENT::DEFAULT_DASH_SPEED
    end
    @dash_speed = $game_variables[YEM::MOVEMENT::DASH_SPEED_VARIABLE]
    return
    for member in $game_party.members
      for item in member.equips.compact do @dash_speed += item.dash_speed_bonus end
    end
  end
  
end # Game_Player

#===============================================================================
# Game_Interpreter
#===============================================================================

class Game_Interpreter
  
  #--------------------------------------------------------------------------
  # alias method: command_122
  #--------------------------------------------------------------------------
  alias command_122_em command_122 unless $@
  def command_122
    n = command_122_em
    $game_player.update_dash_speed if @params[0] == 
      YEM::MOVEMENT::DASH_SPEED_VARIABLE
    return n
  end
  
end # Game_Interpreter

#===============================================================================
# Sprite_Character
#===============================================================================

class Sprite_Character < Sprite_Base
  
  #--------------------------------------------------------------------------
  # constants
  #--------------------------------------------------------------------------
  DIR8_FRAMES ={ 1=>4, 2=>2, 3=>6, 4=>4, 6=>6, 7=>4, 8=>8, 9=>6 }

  alias very_old_initialize initialize
  def initialize(*args)
    @shove_startup_counter = 0
    @shove_interval = 0
    very_old_initialize(*args)
  end

  #--------------------------------------------------------------------------
  # alias method: update_bitmap
  #--------------------------------------------------------------------------
  alias update_bitmap_em update_bitmap unless $@
  def update_bitmap
    @character = @character[1] if @character.is_a?(Array)
    name_changed = (@character_name != @character.character_name)
    update_bitmap_em
    #@animation_data = PHI::Sprite_Data.get_data(@character_name)
    @appropiate_file = nil if name_changed
  end
  

  #--------------------------------------------------------------------------
  # new method: posing?
  #--------------------------------------------------------------------------
  def posing?
    #TODO: include expanded posing options
    return false unless appropiate_filename?
    pose = (@character.pose != nil and !@character.pose != "")
    if pose and @pose_duration == nil
      @pose_duration = (18 - @character.move_frequency * 2)
      @pose_pattern = -1
    end
    @pose_duration = 0 unless pose
    return pose
  end
  
  #--------------------------------------------------------------------------
  # new method: diagonal?
  #--------------------------------------------------------------------------
  def diagonal?
    return false unless YEM::MOVEMENT::ENABLE_8D_MOVEMENT
    return false unless appropiate_filename?
    return true if [1, 3, 7, 9].include?(@character.direction)
    return false
  end
  
  #--------------------------------------------------------------------------
  # new method: dashing?
  #--------------------------------------------------------------------------
  def dashing?
    return false unless @character.dash?
    return false unless appropiate_filename?
    return true if Input.dir8 != 0
    return false
  end
  
  #--------------------------------------------------------------------------
  # new method: appropiate_filename?
  #--------------------------------------------------------------------------
  def appropiate_filename?
    if @appropiate_file == nil
      name = @character_name[/(.*)_(.*)/]
      @appropiate_file = ($2.to_s == YEM::MOVEMENT::SUFFIX)
    end
    return @appropiate_file
  end
  
  #--------------------------------------------------------------------------
  # new method: mirror?
  #--------------------------------------------------------------------------
  def mirror?
    @index_value = [@index_value, @index_value+7].min
    if @character.mirror and (@character.pose == nil or @character.pose == "")
      case @dir8
      when 2
        @dir8 = 6 if diagonal?
      when 4
        @dir8 = diagonal? ? 8 : 6
      when 6
        @dir8 = diagonal? ? 2 : 4
      when 8
        @dir8 = 4 if diagonal?
      end
    end
    return @character.mirror
  end
  
  #--------------------------------------------------------------------------
  # new method: pose_creation
  #--------------------------------------------------------------------------
  def pose_creation
    @character.pre_pose = @character.direction if @character.pre_pose == nil
    case @character.pose.upcase
    #---
    when "NORMAL"
      @index_value = @character.character_index
      @character.break_pose
    #---
    when "READY", "IDLE"
      @index_value = 4
      @character.set_direction(2)
      @character.step_anime = true
    when "DAMAGE", "DMG"
      @index_value = 4
      @character.set_direction(4)
      play_character_pose
    when "PIYORI", "CRITICAL", "DAZED", "DAZE", "DIZZY"
      @index_value = 4
      @character.set_direction(6)
      @character.step_anime = true
    when "MARCH", "FORWARD"
      @index_value = 4
      @character.set_direction(8)
      @character.step_anime = true
    #---
    when "VICTORY", "POSE"
      @index_value = 5
      @character.set_direction(2)
      play_character_pose
    when "EVADE", "DODGE"
      @index_value = 5
      @character.set_direction(4)
      play_character_pose
    when "DEAD", "DEAD1"
      @index_value = 5
      @character.set_direction(6)
      @character.anti_straighten = true
      @character.walk_anime = false
      @character.pattern = 0
    when "DEAD2"
      @index_value = 5
      @character.set_direction(6)
      @character.anti_straighten = true
      @character.walk_anime = false
      @character.pattern = 1
    when "DEAD3"
      @index_value = 5
      @character.set_direction(6)
      @character.anti_straighten = true
      @character.walk_anime = false
      @character.pattern = 2
    when "DOWN", "DOWNED", "FALLEN"
      @index_value = 5
      @character.set_direction(8)
    #---
    when "2H", "2H SWING"
      @index_value = 6
      @character.set_direction(2)
      play_character_pose
    when "1H", "1H SWING"
      @index_value = 6
      @character.set_direction(4)
      play_character_pose
    when "2H REVERSE", "2H SWING REVERSE"
      @index_value = 6
      @character.set_direction(2)
      play_character_pose(true)
    when "1H REVERSE", "1H SWING REVERSE"
      @index_value = 6
      @character.set_direction(4)
      play_character_pose(true)
    when "CAST", "INVOKE", "ITEM", "MAGIC"
      @index_value = 6
      @character.set_direction(6)
      play_character_pose
    when "CHANT", "CHANNEL", "CHARGE"
      @index_value = 6
      @character.set_direction(8)
      @character.step_anime = true
    #---
    else
      @index_value = @character.character_index
      @character.set_direction(2)
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: play_character_pose
  #--------------------------------------------------------------------------
  def play_character_pose(reverse = false)
    update_amount = (18 - @character.move_frequency * 2)
    @character.anti_straighten = true
    @character.walk_anime = false
    @pose_duration += 1
    if @pose_pattern == nil
      @character.pattern = reverse ? 2 : 0
      @pose_pattern = reverse ? 2 : 0
    end
    if reverse and @pose_pattern > 0 and @pose_duration > update_amount
      @pose_duration = 0
      @pose_pattern -= 1
      @character.pattern = @pose_pattern
    elsif !reverse and @pose_pattern < 2 and @pose_duration > update_amount
      @pose_duration = 0
      @pose_pattern += 1
      @character.pattern = @pose_pattern
    end
  end
  
end # Sprite_Character

#===============================================================================
# Scene_Map
#===============================================================================

class Scene_Map < Scene_Base
  
  #--------------------------------------------------------------------------
  # alias method: start
  #--------------------------------------------------------------------------
  alias start_map_em start unless $@
  def start
    start_map_em
    $game_player.update_dash_speed
  end
  
end # Scene_Map

#===============================================================================
# 
# END OF FILE
# 
#===============================================================================