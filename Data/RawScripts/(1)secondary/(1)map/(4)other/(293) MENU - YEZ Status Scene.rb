#===============================================================================
# 
# Yanfly Engine Zealous - Status Command Menu
# Last Date Updated: 2009.12.29
# Level: Normal, Hard, Lunatic
# 
# The status menu in (0X)RPG.rb Maker games don't get used much. That's mostly because
# a lot of the information it displays can be seen elsewhere with a lot more
# functionality at those other locations. This script rewrites the status scene
# to not only display even more information, but to also function as a bridge
# to many other scenes.
# 
#===============================================================================
# Updates
# -----------------------------------------------------------------------------
# o 2009.12.29 - Stable command window oy switching.
# o 2009.12.27 - Weapon Mastery Skills Compatibility.
# o 2009.12.20 - Parameter window now lines up stats through all actors.
#                More efficient import command searching method.
# o 2009.12.16 - Class Stat: LUK Compatibility
# o 2009.12.14 - Formation Macros Compatibility
# o 2009.12.12 - Finished Script.
# o 2009.12.11 - Started Script.
#===============================================================================
# Instructions
# -----------------------------------------------------------------------------
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials but above ▼ Main. Remember to save.
# 
#===============================================================================
# Compatibility
# -----------------------------------------------------------------------------
# - Works With: YEZ Battler Stat DEX, Battler Stat RES, Class Stat DUR
#               YEZ Formation Macros
# - Overwrites: The entire Status Menu scene.
# -----------------------------------------------------------------------------
# Note: This script may not work with former Yanfly Engine ReDux scripts.
#       Use Yanfly Engine Zealous scripts to work with this if available.
#===============================================================================

$imported = {} if $imported == nil
$imported["StatusCommandMenu"] = true

module YEZ
  module STATUS
    
    #===========================================================================
    # Command Window Options
    # -------------------------------------------------------------------------
    # The status scene's command window now offers a selection of items to view
    # different data and the ability to venture to different menus. However,
    # there may be some menu items that not every user wants or would like to
    # add. Adjust the COMMANDS constant to modify the command menu order.
    #      :parameters  - Basic stats such as ATK, DEF, SPI, and AGI.
    #      :affinities  - Elemental and Status resistances.
    #      :skills      - Actor's battle skill list.
    #      :equips      - Actor's worn equipment.
    #      :formations  - Requires BEZ Formation Macros.
    #      :mastery     - Requires YEZ Weapon Mastery Skills
    #      :biography   - A biography of the actor.
    #===========================================================================
    COMMANDS =[
      :parameters,  # Basic stats such as ATK, DEF, SPI, and AGI.
      :affinities,  # Elemental and Status resistances.
    # :skills,      # Actor's battle skill list.
    # :equips,      # Actor's worn equipment.
    # :formations,  # Requires BEZ Formation Macros.
    # :mastery,     # Requires YEZ Weapon Mastery Skills
    # :biography,   # A biography of the actor.
    ] # Do not remove this.
    
    # Do you want your commands to use icons? If you do, set this to true and
    # adjust the settings below to use the appropiate icons for your menu.
    USE_ICONS = false
    
    # This determines the colour of the EXP bars used for the actor's exp
    # gauge in the status menu.
    EXP_TEXT    = "EXP"      # Text used for EXP
    PERCENT_EXP = "%1.2f%%"  # Text format used for EXP percentage
    EXP_GAUGE_1 = 28         # Colour 1 for the EXP Gauge
    EXP_GAUGE_2 = 29         # Colour 2 for the EXP Gauge
    
    # The following will determine whether or not your Status Menu will use a
    # background image instead of the typical window skin. Place the BG Image
    # in the Graphics\System folder if you plan to use it.
    USE_BG_IMAGE = false
    BG_FILE_NAME = "MenuStatus"
    
    # Parameters Status Mini Window. This window displays the primary stats of
    # the actor being viewed. If KGC Parameter Distribution is installed, this
    # command will also take the player to the stat distribution scene.
    PARAMETERS ={
      :'(2)title' => "Parameter",
      :icon  => 103,
      # The following adjusts the stats shown in each column. Adjust the array
      # for each column to list what order you'd like for the stats to appear.
      # :hp, :mp, :blank, :atk, :def, :spi, :res, :dex, :agi
      # :hit, :eva, :cri, :dur, :luk, :odds
      :page_title    => "Basic Parameters",
      :column1_stats => [:hp, :mp, :blank, :atk, :agi, :spi, :def, :cri],
      :column2_stats => [],
    } # Do not remove this.
    
    # Affinities Mini Window. This window will display the actor's elemental
    # and status resistances. 
    AFFINITIES ={
      :'(2)title' => "Affinity",
      :icon  => 100,
      # The following adjusts what elements and states are shown. Adjust the
      # array to meet the state and element ID's. And since elements don't have
      # an innate icon associated with them, use the following below to adjust
      # the elements used for the elements.
      :states_shown   => [],
      :states_title   => "Status Resistance",
      :elements_shown => ['Physical Damage / Resistance', 1..6, 'Element Damage / Resistance', 7..14],
      :elements_title => "Element Resistance",
      :element_icons  => {
          1 => 3,
          2 => 3,
          3 => 3,
          4 => 3,
          5 => 3,
          6 => 1864,
          7 => 1865,
          8 => 1866,
          9 => 1867,
          10 => 1868,
          11 => 1869,
          12 => 1870,
          13 => 1871,
          14 => 1901,
          #15 => 1901,
      }, # Do not remove this.
      # The rank colour adjusts the different colours used for each milestone
      # percentile achieved by the actor. Values below are text colours.
      :rank_colour => {
        :srank => 2,
        :arank => 2,
        :brank => 14,
        :crank => 6,
        :drank => 3,
        :erank => 3,
        :frank => 3,
      }, # Do not remove this.
      :rank_size => 24,  # This adjusts the font size used for ranks.
      :absorb    => "*", # This adjusts symbol used for absorbed elements.
    } # Do not remove this.
    
    # Skills Mini Window.This will display a short list of the actor's skills.
    # If :battle_only is set to true, the skills will be highlightened and lit
    # up like they are usable in battle and don't have the disabled colour.
    SKILLS ={
      :'(2)title' => "Skills",
      :icon  => 159,
      :battle_only => true,  
    } # Do not remove this.
    
    # Equips Mini Window. This mini window will show the actor's equipment
    # and the total stat boost accumulated from the equipment. Stat list:
    # :hp, :mp, :blank, :atk, :def, :spi, :res, :dex, :agi
    # :hit, :eva, :cri, :dur, :luk, :odds
    EQUIPS ={
      :'(2)title' => "Equipment",
      :icon  => 44,
      :page_title => "Equipment",
      :param => [:hp, :mp, :atk, :def, :spi, :res, :dex, :agi, :dur, :luk, :hit,]
    } # Do not remove this.
    
    # Biography Mini Window. The following will allow you to adjust biographies
    # for actors and (0)classes. If an actor does not have a personal biography,
    # then the description of the (0)character's class will be displayed instead.
    # If the (0)character's class does not have a description, then this option
    # will not appear at all in the status menu.
    BIOGRAPHY ={
      :'(2)title' => "Biography",
      :icon  => 141,
      :font_size => 18,
      :actor_bio => "%s's Biography",
      :class_des => "%s Description",
    } # Do not remove this.
    
    # When typing out biographies and descriptions, use \\N[x] to write out
    # the actor's name if the game allows renaming. For line splits, use |
    # at the each position you would want the description to start a new line.
    ACTOR_BIOS ={ # If an actor ID is not listed here, then refer to class bio.
    # ID => Bio
       1 => '\\N[1] is a very hot blooded young male whom|' +
            'embarked on a journey to save Don Miguel.|' +
            'But given his reckless behaviour and actions,|' +
            '\\N[1] is known to give his team lots of trouble.',
       2 => '\\N[2] trained as a warrior since she was|' +
            'quite young. Due to her militant past, she has|' +
            'developed a rather tomboy-ish personality.|' +
            '\\N[2] loves training and is also a health nut.',
       3 => '\\N[3] is the overzealous priest of \\N[1]\'s|' +
            'party. His actions speak louder than his words|' +
            'and his words are already loud enough. \\N[3]|' +
            'is definitely one who choose the wrong class.',
       4 => '\\N[4] is the team\'s walking encyclopedia.|' +
            'She just about knows everything for each and|' +
            'every situation. But aside from that, \\N[4]|' +
            'just doesn\'t have the actual life experience.',
    } # Do not remove this.
    
    # Just like the actor biographies, use \\N[x] to write out a changeable
    # actor's name and \\V[x] to write out variables. Use | to enforce a
    # line break. If a class bio is not listed, it will not be shown.
    CLASS_BIOS ={ # If a class does not have a bio, it becomes unlisted.
    # ID => Bio
       1 => 'Knights are quick and powerful characters|' +
            'that excel in both melee and magic.',
       2 => 'Warriors are very dedicated to close ranged|' +
            'physical combat.',
       3 => 'Priests focus on healing and aiding their|' +
            "party members. Don't let \\N[3] fool you.",
       4 => 'Magicians excel in the magical arts and also|' +
            'excel at blasting their enemies to bits.',
    } # Do not remove this.
    
  end # STATUS
end # YEZ

#===============================================================================
# Status Command Menu - Lunatic Mode - Scene Linking
# ----------------------------------------------------------------------------
# For the Lunatics who would love to add in their own categories and/or windows
# without worrying about breaking the script, the following hash will give you
# a simplified way of doing just that.
#===============================================================================

module YEZ
  module STATUS
    
    # The following hash governs the imported data used. Adjust the data
    # properly to meet the demands of the hash.
    #   method - This is the key used to place at the top.
    #   switch - If it uses a switch, place the ID. If it doesn't set to nil.
    #    (2)title - The (2)title used for the command window.
    #     icon - The icon used for the command window.
    #   window - Window name used. Type it out fully.
    #    scene - The scene's class name.
    IMPORTED_COMMANDS ={
    # :method => [Switch, "Title", Icon, Window, Scene's Name]
#~     :class    => [    67, "Class",  131,    nil, "Scene_Class_Change"],
    :learn    => [    68, "Learn",  133,    nil, "Scene_Learn_Skill"],
    :slots    => [    69, "Slots",  103,    nil, "Scene_Equip_Skill"],
    } # Do not remove this.
    
  end # STATUS
end # YEZ

#===============================================================================
# Editting anything past this point may potentially result in causing computer
# damage, incontinence, explosion of user's head, coma, death, and/or halitosis.
# Therefore, edit at your own risk.
#===============================================================================

module YEZ::STATUS
  module_function
  #--------------------------------------------------------------------------
  # convert_integer_array
  #--------------------------------------------------------------------------
  def convert_integer_array(array)
    result = []
    array.each { |i|
      case i
      when Range; result |= i.to_a
        when Integer; result |= [i]
          when String; result.push i
      end }
    return result
  end
  #--------------------------------------------------------------------------
  # converted arrays
  #--------------------------------------------------------------------------
  AFFINITIES[:states_shown] = convert_integer_array(AFFINITIES[:states_shown])
  AFFINITIES[:elements_shown] = convert_integer_array(AFFINITIES[:elements_shown])
end # YEZ::STATUS

module Vocab
  def self.hit; return "HIT"; end
  def self.eva; return "EVA"; end
  def self.cri; return "CRI"; end
  def self.odds;return "AGR"; end
end # Vocab

#===============================================================================
# Scene_Status
#===============================================================================

class Scene_Status < Scene_Base

  #--------------------------------------------------------------------------
  # overwrite method: start
  #--------------------------------------------------------------------------
  def start
    super
    $game_temp.status_index = 0 if $game_temp.status_index == nil
    @actor = $game_party.members[@actor_index]
    @command_window = Window_Status_Command.new(@actor)
    @actor_window = Window_Status_Actor.new(@actor)
    @dummy_window = Window_Base.new(0, 128, $screen_width, 288)
    create_menu_background
    create_mini_windows
    $game_party.last_actor_index = @actor_index
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: create_menu_background
  #--------------------------------------------------------------------------
  def create_menu_background
    if YEZ::STATUS::USE_BG_IMAGE
      @menuback_sprite = Sprite.new
      @menuback_sprite.bitmap = Cache.system(YEZ::STATUS::BG_FILE_NAME)
      @command_window.opacity = 0
      @actor_window.opacity = 0
      @dummy_window.opacity = 0
      update_menu_background
    else
      super
    end
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: terminate
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_menu_background
    dispose_mini_windows
    @command_window.dispose
    @actor_window.dispose
    @dummy_window.dispose
  end
  
  #--------------------------------------------------------------------------
  # alias method: return_scene
  #--------------------------------------------------------------------------
  alias return_scene_status_scm return_scene unless $@
  def return_scene
    $game_temp.status_oy = nil
    $game_temp.status_index = nil
    $game_temp.status_calc_width = nil
    return_scene_status_scm
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: update
  #--------------------------------------------------------------------------
  def update
    update_menu_background
    update_mini_windows if $game_temp.status_index != @command_window.index
    @command_window.update
    if Input.trigger?(PadConfig.decision)
      determine_scene_change
    elsif Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      return_scene
    elsif Input.repeat?(PadConfig.right)
      Sound.play_cursor
      $game_temp.status_oy = @command_window.oy
      next_actor
    elsif Input.repeat?(PadConfig.left)
      Sound.play_cursor
      $game_temp.status_oy = @command_window.oy
      prev_actor
    end
    super
  end
  
  #--------------------------------------------------------------------------
  # new method: create_mini_windows
  #--------------------------------------------------------------------------
  def create_mini_windows
    @mini_windows = {}; n = 0
    for command in YEZ::STATUS::COMMANDS
      case command
      #--- Defaults ---  
      when :parameters
        @parameter_window = Window_Status_Parameter.new(@actor)
        @mini_windows[n] = @parameter_window
      when :affinities
        @affinity_window = Window_Status_Affinity.new(@actor)
        @mini_windows[n] = @affinity_window
      when :skills
        @skill_window = Window_Status_Skill.new(@actor)
        @mini_windows[n] = @skill_window
      when :equips
        @equip_window = Window_Status_Equips.new(@actor)
        @mini_windows[n] = @equip_window
      when :biography
        @biography_window = Window_Status_Biography.new(@actor)
        @mini_windows[n] = @biography_window
      #--- Imports ---  
      when :formations
        next unless $imported["FormationMacros"]
        next unless $game_switches[YEZ::MACRO::ENABLE_SWITCH]
        @formation_window = Window_Formation.new(@actor)
        @formation_window.opacity = 0
        @mini_windows[n] = @formation_window
      when :mastery
        next unless $imported["WeaponMasterySkills"]
        @mastery_window = Window_Mastery.new(0, 128, @actor, true)
        @mastery_window.opacity = 0
        @mini_windows[n] = @mastery_window
        
      else
        return_check = true
        for key in YEZ::STATUS::IMPORTED_COMMANDS
          if key[0] == command
            return_check = false
            found_key = key[0]
          end
        end
        next if return_check
        command_array = YEZ::STATUS::IMPORTED_COMMANDS[found_key]
        if command_array[0] != nil
          next unless $game_switches[command_array[0]]
        end
        if command_array[3] != nil
          window = eval(command_array[3])
          window.x = 0
          window.y = 128
          window.width = $screen_width
          window.height = 288
          window.create_contents
          window.refresh
        else
          window = Window_Base.new(0, 128, $screen_width, 288)
          
        end
        window.opacity = 0
        @mini_windows[n] = window
        
      end
      n += 1
    end
    update_mini_windows
  end
  
  #--------------------------------------------------------------------------
  # new method: update_mini_windows
  #--------------------------------------------------------------------------
  def update_mini_windows
    $game_temp.status_index = @command_window.index
    for i in 0..(@mini_windows.size-1)
      @mini_windows[i].visible = false
    end
    return unless @mini_windows.include?($game_temp.status_index)
    @mini_windows[$game_temp.status_index].visible = true
  end
  
  #--------------------------------------------------------------------------
  # new method: dispose_mini_windows
  #--------------------------------------------------------------------------
  def dispose_mini_windows
    for i in 0..(@mini_windows.size-1)
      @mini_windows[i].dispose
      @mini_windows[i] = nil
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: determine_scene_change
  #--------------------------------------------------------------------------
  def determine_scene_change
    case @command_window.item
    when :skills
      Sound.play_decision
      $scene = Scene_Skill.new(@actor.index)
    when :equips
      Sound.play_decision
      $scene = Scene_Equip.new(@actor.index)
    when :formations
      return unless $imported["FormationMacros"]
      return unless $game_switches[YEZ::MACRO::ENABLE_SWITCH]
      Sound.play_decision
      $scene = Scene_Formation.new(@actor.index)
    when :mastery
      return unless $imported["WeaponMasterySkills"]
      Sound.play_decision
      $scene = Scene_Mastery.new(@actor.index)
      
    else
      return unless YEZ::STATUS::IMPORTED_COMMANDS.include?(@command_window.item)
      command_array = YEZ::STATUS::IMPORTED_COMMANDS[@command_window.item]
      if command_array[4] != nil
        Sound.play_decision
        $scene = eval(command_array[4] + ".new(@actor_index)")
      end
      
    end
  end
  
end # Scene_Status

#===============================================================================
# Scene_Skill
#===============================================================================

class Scene_Skill < Scene_Base
  
  #--------------------------------------------------------------------------
  # alias method: return_scene
  #--------------------------------------------------------------------------
  alias return_scene_skill_scm return_scene unless $@
  def return_scene
    if $game_temp.status_index != nil
      $scene = Scene_Status.new(@actor_index)
    else
      return_scene_skill_scm
    end
  end
  
end # Scene_Skill

#===============================================================================
# Scene_Equip
#===============================================================================

class Scene_Equip < Scene_Base
  
  #--------------------------------------------------------------------------
  # alias method: return_scene
  #--------------------------------------------------------------------------
  alias return_scene_equip_scm return_scene unless $@
  def return_scene
    if $game_temp.status_index != nil
      $scene = Scene_Status.new(@actor_index)
    else
      return_scene_equip_scm
    end
  end
  
end # Scene_Skill

#===============================================================================
# Game_Temp
#===============================================================================

class Game_Temp
  
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :status_index
  attr_accessor :status_oy
  attr_accessor :status_calc_width
  attr_accessor :status_ele_width
  attr_accessor :status_st_width
  
end # Game_Temp

#===============================================================================
# Game_Actor
#===============================================================================

class Game_Actor < Game_Battler

  def now_exp
    return @exp - @exp_list[@level]
  end

  def next_exp
    return @exp_list[@level+1] > 0 ? @exp_list[@level+1] - @exp_list[@level] : 0
  end
  
end

#===============================================================================
# Window_Status_Actor
#===============================================================================

class Window_Status_Actor < Window_Base
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(actor)
    super(160, 0, 384, 128)
    @actor = actor
    refresh
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    draw_actor_face(@actor, 0, 0, size = 96)
    x = 104
    y = 0
    draw_actor_name(@actor, x, y)
    draw_actor_class(@actor, x + 120, y)
    draw_actor_level(@actor, x, y + WLH * 1)
    draw_actor_state(@actor, x, y + WLH * 2)
    draw_actor_hp(@actor, x + 120, y + WLH * 1, 120)
    draw_actor_mp(@actor, x + 120, y + WLH * 2, 120)
    draw_actor_exp(@actor, x + 120, y + WLH * 3, 120)
  end
  
  #--------------------------------------------------------------------------
  # draw_actor_exp
  #--------------------------------------------------------------------------
  def draw_actor_exp(actor, x, y, size = 120)
    if actor.next_exp != 0
      gw = size * actor.now_exp
      gw /= actor.next_exp
    else
      gw = size
    end
    gc1 = text_color(YEZ::STATUS::EXP_GAUGE_1)
    gc2 = text_color(YEZ::STATUS::EXP_GAUGE_2)
    self.contents.fill_rect(x, y + WLH - 8, size, 6, gauge_back_color)
    self.contents.gradient_fill_rect(x, y + WLH - 8, gw, 6, gc1, gc2)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 40, WLH, YEZ::STATUS::EXP_TEXT)
    self.contents.font.color = normal_color
    if actor.next_exp != 0
      expercent = actor.now_exp * 100.000
      expercent /= actor.next_exp
    else
      expercent = 100.000
    end
    expercent = 100.000 if expercent > 100.000
    text = sprintf(YEZ::STATUS::PERCENT_EXP, expercent)
    self.contents.draw_text(x, y, size, WLH, text, 2)
  end
  
end # Window_Status_Actor

#===============================================================================
# Window_Status_Parameter
#===============================================================================

class Window_Status_Parameter < Window_Base
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(actor)
    super(0, 128, $screen_width, 288)
    self.opacity = 0
    @actor = actor
    refresh
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    sw = self.width - 32
    self.contents.font.color = system_color
    text = YEZ::STATUS::PARAMETERS[:page_title]
    self.contents.draw_text(48, 0, sw/2-48, WLH, text, 0)
    draw_exp_info(sw/2+24, 0)
    dx = 0; dy = WLH
    array = YEZ::STATUS::PARAMETERS[:column1_stats]
    draw_column(dx, dy, array)
    dx = (self.width - 32) / 2
    array = YEZ::STATUS::PARAMETERS[:column2_stats]
    draw_column(dx-24, dy*4, array)
  end
  
  #--------------------------------------------------------------------------
  # draw_exp_info
  #--------------------------------------------------------------------------
  def draw_exp_info(x, y)
    s1 = @actor.exp_s
    s2 = @actor.next_rest_exp_s
    s_next = sprintf(Vocab::ExpNext, Vocab::level)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y + WLH * 0, 180, WLH, Vocab::ExpTotal)
    self.contents.draw_text(x, y + WLH * 2, 180, WLH, s_next)
    self.contents.font.color = normal_color
    self.contents.draw_text(x, y + WLH * 1, 180, WLH, s1, 2)
    self.contents.draw_text(x, y + WLH * 3, 180, WLH, s2, 2)
  end
  
  #--------------------------------------------------------------------------
  # draw_column
  #--------------------------------------------------------------------------
  def draw_column(dx, dy, array)
    dx += 48
    stat_width = calc_width(array)
    for item in array
      dw = 60
      text = ""
      stat = ""
      icon = 0
      case item
      when :blank
      when :hp
        text = Vocab.hp
        stat = @actor.maxhp
        icon = $imported["Icons"] ? YEZ::ICONS[:hp] : 0
      when :mp
        text = Vocab.mp
        stat = @actor.maxmp
        icon = $imported["Icons"] ? YEZ::ICONS[:mp] : 0
      when :atk
        text = Vocab.atk
        stat = @actor.atk
        icon = $imported["Icons"] ? YEZ::ICONS[:atk] : 0
      when :def
        text = Vocab.def
        stat = @actor.def
        icon = $imported["Icons"] ? YEZ::ICONS[:def] : 0
      when :spi
        text = Vocab.spi
        stat = @actor.spi
        icon = $imported["Icons"] ? YEZ::ICONS[:spi] : 0
      when :agi
        text = Vocab.agi
        stat = @actor.agi
        icon = $imported["Icons"] ? YEZ::ICONS[:agi] : 0
      when :hit
        text = Vocab.hit
        icon = $imported["Icons"] ? YEZ::ICONS[:hit] : 0
        stat = sprintf("%d%%",[[@actor.hit, 0].max, 99].min)
      when :eva
        text = Vocab.eva
        icon = $imported["Icons"] ? YEZ::ICONS[:eva] : 0
        stat = sprintf("%d%%",[[@actor.eva, 0].max, 99].min)
      when :cri
        text = Vocab.cri
        icon = $imported["Icons"] ? YEZ::ICONS[:cri] : 0
        stat = sprintf("%d%%",[[@actor.cri, 0].max, 99].min)
      else; next
      end
      draw_icon(icon, dx, dy)
      self.contents.font.color = system_color
      self.contents.draw_text(dx + 24, dy, dw, WLH, text, 0)
      self.contents.font.color = normal_color
      self.contents.draw_text(dx + 84, dy, stat_width, WLH, stat, 2)
      dy += WLH
    end
  end
  
  #--------------------------------------------------------------------------
  # calc_width
  #--------------------------------------------------------------------------
  def calc_width(array)
    return $game_temp.status_calc_width if $game_temp.status_calc_width != nil
    n = 0
    for actor in $game_party.members
      for item in array
        text = ""
        case item
        when :hp;   text = actor.maxhp
        when :mp;   text = actor.maxmp
        when :atk;  text = actor.atk
        when :def;  text = actor.def
        when :spi;  text = actor.spi
        when :agi;  text = actor.agi
        when :res;  text = actor.res if $imported["BattlerStatRES"]
        when :dex;  text = actor.dex if $imported["BattlerStatDEX"]
        when :hit;  text = sprintf("%d%%", [[actor.hit, 0].max, 99].min)
        when :eva;  text = sprintf("%d%%", [[actor.eva, 0].max, 99].min)
        when :cri;  text = sprintf("%d%%", [[actor.cri, 0].max, 99].min)
        when :dur;  text = actor.dur if $imported["ClassStatDUR"]
        when :luk;  text = actor.luk if $imported["BattlerStatLUK"]
        when :odds; text = actor.odds
        else; next
        end
        n = [n, contents.text_size(text).width].max
      end
    end
    $game_temp.status_calc_width = n
    return n
  end
  
end # Window_Status_Parameter

#===============================================================================
# Window_Status_Affinity
#===============================================================================

class Window_Status_Affinity < Window_Base
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(actor)
    super(0, 128, $screen_width, 288)
    self.opacity = 0
    @actor = actor
    refresh
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    draw_elemental_affinity
    draw_status_resistances
  end
  
  #--------------------------------------------------------------------------
  # draw_elemental_affinity
  #--------------------------------------------------------------------------
  def draw_elemental_affinity
    self.contents.font.size = Font.default_size
    affinities = YEZ::STATUS::AFFINITIES
    dx = 48; dy = 0; sw = self.width-32
    if affinities[:elements_shown].size < 10
      self.contents.font.color = system_color
      text = affinities[:elements_title]
      self.contents.draw_text(dx, dy, sw/2-24, WLH, text, 0)
      dy += WLH
    end
    dw = calc_ele_width(affinities[:elements_shown])
    for ele_id in affinities[:elements_shown]
      next if ele_id > $data_system.elements.size
      draw_icon(affinities[:element_icons][ele_id], dx, dy)
      name = $data_system.elements[ele_id]
      self.contents.font.color = normal_color
      self.contents.font.size = Font.default_size
      self.contents.draw_text(dx+24, dy, dw+10, WLH, name, 0)
      self.contents.font.color = affinity_colour(@actor.element_resistance(ele_id))
      self.contents.font.size = affinities[:rank_size]
      self.contents.draw_text(dx+34+dw, dy, 60, WLH, element_rate(ele_id), 2)
      if @actor.element_resistance(ele_id) < 0
        self.contents.draw_text(dx+94+dw, dy, 60, WLH, affinities[:absorb])
      end
      dy += WLH
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_status_resistances
  #--------------------------------------------------------------------------
  def draw_status_resistances
    self.contents.font.size = Font.default_size
    affinities = YEZ::STATUS::AFFINITIES
    dx = (self.width - 32)/2 + 24; dy = 0; sw = self.width-32
    if affinities[:states_shown].size < 10
      self.contents.font.color = system_color
      text = affinities[:states_title]
      self.contents.draw_text(dx, dy, sw/2-24, WLH, text, 0)
      dy += WLH
    end
    dw = calc_state_width(affinities[:states_shown])
    for state_id in affinities[:states_shown]
      state = $data_states[state_id]
      next if state == nil
      draw_icon(state.icon_index, dx, dy)
      self.contents.font.color = normal_color
      self.contents.font.size = Font.default_size
      self.contents.draw_text(dx+24, dy, dw+20, WLH, state.name, 0)
      self.contents.font.color = rank_colour(@actor.state_probability(state_id))
      resist = sprintf("%d%%", @actor.state_probability(state_id))
      self.contents.font.size = affinities[:rank_size]
      self.contents.draw_text(dx+44+dw, dy, 60, WLH, resist, 2)
      dy += WLH
    end
  end
  
  #--------------------------------------------------------------------------
  # calc_ele_width
  #--------------------------------------------------------------------------
  def calc_ele_width(elements)
    return $game_temp.status_ele_width if $game_temp.status_ele_width != nil
    n = 0
    for ele_id in elements
      next if ele_id > $data_system.elements.size
      text = $data_system.elements[ele_id]
      n = [n, contents.text_size(text).width].max
    end
    $game_temp.status_ele_width = n
    return n
  end
  
  #--------------------------------------------------------------------------
  # calc_state_width
  #--------------------------------------------------------------------------
  def calc_state_width(states)
    return $game_temp.status_st_width if $game_temp.status_st_width != nil
    n = 0
    for state_id in states
      state = $data_states[state_id]
      next if state == nil
      text = state.name
      n = [n, contents.text_size(text).width].max
    end
    $game_temp.status_st_width = n
    return n
  end
  
  #--------------------------------------------------------------------------
  # affinity_colour
  #--------------------------------------------------------------------------
  def affinity_colour(amount)
    if amount > 200; n = YEZ::STATUS::AFFINITIES[:rank_colour][:srank]
    elsif amount > 150; n = YEZ::STATUS::AFFINITIES[:rank_colour][:arank]
    elsif amount > 100; n = YEZ::STATUS::AFFINITIES[:rank_colour][:brank]
    elsif amount > 50; n = YEZ::STATUS::AFFINITIES[:rank_colour][:crank]
    elsif amount > 0; n = YEZ::STATUS::AFFINITIES[:rank_colour][:drank]
    elsif amount == 0; n = YEZ::STATUS::AFFINITIES[:rank_colour][:erank]
    else; n = YEZ::STATUS::AFFINITIES[:rank_colour][:frank]
    end
    return text_color(n)
  end
  
  #--------------------------------------------------------------------------
  # rank_colour
  #--------------------------------------------------------------------------
  def rank_colour(amount)
    if amount > 100; n = YEZ::STATUS::AFFINITIES[:rank_colour][:srank]
    elsif amount > 80; n = YEZ::STATUS::AFFINITIES[:rank_colour][:arank]
    elsif amount > 60; n = YEZ::STATUS::AFFINITIES[:rank_colour][:brank]
    elsif amount > 40; n = YEZ::STATUS::AFFINITIES[:rank_colour][:crank]
    elsif amount > 20; n = YEZ::STATUS::AFFINITIES[:rank_colour][:drank]
    elsif amount > 0; n = YEZ::STATUS::AFFINITIES[:rank_colour][:erank]
    else; n = YEZ::STATUS::AFFINITIES[:rank_colour][:frank]
    end
    return text_color(n)
  end
  
  #--------------------------------------------------------------------------
  # element_rate
  #--------------------------------------------------------------------------
  def element_rate(ele_id)
    rate = @actor.element_resistance(ele_id)
    if rate >= 0; text = sprintf("%+d%%", rate - 100)
    elsif rate < 0; text = sprintf("%d%%", -rate)
    end
    return text
  end
  
end # Window_Status_Affinity
=begin
#===============================================================================
# Window_Status_Skill
#===============================================================================

class Window_Status_Skill < Window_Skill

  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(actor)
    $game_temp.in_battle = true if YEZ::STATUS::SKILLS[:battle_only]
    super(0, 128, $screen_width, 288, actor)
    self.opacity = 0
    self.index = -1
    $game_temp.in_battle = false if YEZ::STATUS::SKILLS[:battle_only]
  end

end # Window_Status_Affinity
=end
#===============================================================================
# Window_Status_Equips
#===============================================================================

class Window_Status_Equips < Window_Status_Parameter
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    draw_equipments(32, 0)
    draw_column((self.width-32)/2-24, WLH, YEZ::STATUS::EQUIPS[:param])
  end
  
  #--------------------------------------------------------------------------
  # draw_equipments
  #--------------------------------------------------------------------------
  def draw_equipments(x, y)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 120, WLH, YEZ::STATUS::EQUIPS[:page_title])
    if $imported["EquipExtension"]
      item_number = [@actor.equips.size, @actor.armor_number + 1].min
      item_number.times { |i|
        draw_item_name(@actor.equips[i], x + 16, y + WLH * (i + 1)) }
    else
      for i in 0..4
        draw_item_name(@actor.equips[i], x + 16, y + WLH * (i + 1))
      end
    end
  end
  
end # Window_Status_Equips

#===============================================================================
# Window_Status_Biography
#===============================================================================

class Window_Status_Biography < Window_Base
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(actor)
    super(0, 128, $screen_width, 288)
    self.opacity = 0
    @actor = actor
    refresh
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    if YEZ::STATUS::ACTOR_BIOS.include?(@actor.id)
      draw_actor_bio
    elsif YEZ::STATUS::CLASS_BIOS.include?(@actor.class_id)
      draw_class_bio
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_actor_bio
  #--------------------------------------------------------------------------
  def draw_actor_bio
    self.contents.font.color = normal_color; dy = 0
    text = sprintf(YEZ::STATUS::BIOGRAPHY[:actor_bio], @actor.name)
    self.contents.draw_text(0, dy, self.width-32, WLH*2, text, 1)
    self.contents.font.size = YEZ::STATUS::BIOGRAPHY[:font_size]
    text = YEZ::STATUS::ACTOR_BIOS[@actor.id]
    txsize = YEZ::STATUS::BIOGRAPHY[:font_size] + 4
    nwidth = $screen_width
    dx = 48; dy = WLH*2
    text.gsub!(/\\V\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
    text.gsub!(/\\V\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
    text.gsub!(/\\N\[([0-9]+)\]/i) { $game_actors[$1.to_i].name }
    lines = text.split(/(?:[|]|\\n)/i)
    lines.each_with_index { |l, i|
      l.gsub!(/\\__(\[\d+\])/i) { "\\N#{$1}" }
      self.contents.draw_text(dx, i * txsize + dy, nwidth, WLH, l, 0)}
  end
  
  #--------------------------------------------------------------------------
  # draw_class_bio
  #--------------------------------------------------------------------------
  def draw_class_bio
    self.contents.font.color = normal_color; dy = 0
    text = sprintf(YEZ::STATUS::BIOGRAPHY[:class_des], @actor.class.name)
    self.contents.draw_text(0, dy, self.width-32, WLH*2, text, 1)
    self.contents.font.size = YEZ::STATUS::BIOGRAPHY[:font_size]
    text = YEZ::STATUS::CLASS_BIOS[@actor.class.id]
    txsize = YEZ::STATUS::BIOGRAPHY[:font_size] + 4
    nwidth = $screen_width
    dx = 48; dy = WLH*2
    text.gsub!(/\\V\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
    text.gsub!(/\\V\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
    text.gsub!(/\\N\[([0-9]+)\]/i) { $game_actors[$1.to_i].name }
    lines = text.split(/(?:[|]|\\n)/i)
    lines.each_with_index { |l, i|
      l.gsub!(/\\__(\[\d+\])/i) { "\\N#{$1}" }
      self.contents.draw_text(dx, i * txsize + dy, nwidth, WLH, l, 0)}
  end
  
end # Window_Status_Biography

#===============================================================================
# Window_Status_Command
#===============================================================================

class Window_Status_Command < Window_Command
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(actor)
    @actor = actor
    create_command_list
    super(160, @commands)
    self.height = 128
    self.oy = $game_temp.status_oy if $game_temp.status_oy != nil
    self.index = $game_temp.status_index if $game_temp.status_index != nil
    if $game_temp.status_index != nil and $game_temp.status_index > (@commands.size-1)
      self.index = @commands.size-1
    end
  end
  
  #--------------------------------------------------------------------------
  # create_command_list
  #--------------------------------------------------------------------------
  def create_command_list
    @commands = []
    for command in YEZ::STATUS::COMMANDS
      #--- Default Commands
      case command
      when :parameters; @commands.push(command)
      when :affinities; @commands.push(command)
      when :skills; @commands.push(command)
      when :equips; @commands.push(command)
      when :biography
        if !YEZ::STATUS::ACTOR_BIOS.include?(@actor.id)
          next if !YEZ::STATUS::CLASS_BIOS.include?(@actor.class_id)
        end
        @commands.push(command)
      #--- Imported Commands
      when :formations
        next unless $imported["FormationMacros"]
        next unless $game_switches[YEZ::MACRO::ENABLE_SWITCH]
        @commands.push(command)
      when :mastery
        next unless $imported["WeaponMasterySkills"]
        @commands.push(command)
        
      else
        next unless YEZ::STATUS::IMPORTED_COMMANDS.include?(command)
        if YEZ::STATUS::IMPORTED_COMMANDS[command][0] != nil
          next unless $game_switches[YEZ::STATUS::IMPORTED_COMMANDS[command][0]]
        end
        @commands.push(command)
      end
      #---
    end
  end
  
  #--------------------------------------------------------------------------
  # item
  #--------------------------------------------------------------------------
  def item; return @commands[index]; end
  
  #--------------------------------------------------------------------------
  # draw_item
  #--------------------------------------------------------------------------
  def draw_item(index, enabled = true)
    rect = item_rect(index)
    rect.x += 4
    rect.width -= 8
    self.contents.clear_rect(rect)
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    #--- Default ---
    case @commands[index]
    when :parameters
      text = YEZ::STATUS::PARAMETERS[:'(2)title']
      icon = YEZ::STATUS::PARAMETERS[:icon]
    when :affinities
      text = YEZ::STATUS::AFFINITIES[:'(2)title']
      icon = YEZ::STATUS::AFFINITIES[:icon]
    when :skills
      text = YEZ::STATUS::SKILLS[:'(2)title']
      icon = YEZ::STATUS::SKILLS[:icon]
    when :equips
      text = YEZ::STATUS::EQUIPS[:'(2)title']
      icon = YEZ::STATUS::EQUIPS[:icon]
    when :biography
      text = YEZ::STATUS::BIOGRAPHY[:'(2)title']
      icon = YEZ::STATUS::BIOGRAPHY[:icon]
    #--- Imported ---
    when :formations
      return unless $imported["FormationMacros"]
      return unless $game_switches[YEZ::MACRO::ENABLE_SWITCH]
      text = YEZ::MACRO::TITLE
      icon = YEZ::MACRO::ICON
    when :mastery
      return unless $imported["WeaponMasterySkills"]
      text = YEZ::WEAPON_MASTERY::TITLE
      icon = YEZ::WEAPON_MASTERY::ICON
      
    else
      return unless YEZ::STATUS::IMPORTED_COMMANDS.include?(@commands[index])
      text = YEZ::STATUS::IMPORTED_COMMANDS[@commands[index]][1]
      icon = YEZ::STATUS::IMPORTED_COMMANDS[@commands[index]][2]
      
    end
    #---
    align = 1
    if YEZ::STATUS::USE_ICONS
      rect.x += 24
      rect.width -= 24
      align = 0
    end
    self.contents.draw_text(rect, text, align)
    return unless YEZ::STATUS::USE_ICONS
    draw_icon(icon, rect.x-24, rect.y)
  end
  
end # Window_Status_Command

#===============================================================================
# 
# END OF FILE
# 
#===============================================================================