=begin
#===============================================================================
# 
# Yanfly Engine Zealous - Main Menu Zealous
# Last Date Updated: 2010.02.01
# Level: Normal, Hard, Lunatic
# 
# This script allows for menu item reordering along with importing in custom
# script scenes with ease so that there becomes little need to change the base
# menu script in order to add in a few items. This is a YEZ version of the
# popular KGC Custom Menu Command. No credits will be taken on part of my own
# behalf for the work KGC did. All I merely did was use it to extend the
# capabilities of adding in common events, imported commands, and beefed up
# engine efficiency.
# 
#===============================================================================
# Updates
# -----------------------------------------------------------------------------
# o 2010.02.01 - CG Gallery Compatibility.
# o 2010.01.10 - Job System: Passives Compatibility.
# o 2010.01.05 - Job System: Classes Compatibility.
# o 2009.12.27 - Weapon Mastery Skills Compatibility.
# o 2009.12.24 - Party Selection System Compatibility.
# o 2009.12.21 - Started Script and Finished.
#===============================================================================
# Instructions
# -----------------------------------------------------------------------------
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials but above ▼ Main. Considering the special
# nature of this script, it is highly recommended that you place this script
# above all non-(0)core scripts. Remember to save.
# 
# Scroll down and edit the module as you see fitting for your game.
# 
# -----------------------------------------------------------------------------
# Debug Shortcuts - Only during $TEST and $BTEST mode
# -----------------------------------------------------------------------------
# During testplay mode, pressing F5 while the main menu is active will fill
# all party members' HP and MP to full.
# 
#===============================================================================
# Compatibility
# -----------------------------------------------------------------------------
# - Works With: Many KGC, YERD, and YEZ scripts.
# -----------------------------------------------------------------------------
# Note: This script may not work with former Yanfly Engine ReDux scripts.
#       Use Yanfly Engine Zealous scripts to work with this if available.
#===============================================================================

$imported = {} if $imported == nil
$imported["MainMenuZealous"] = true

module YEZ
  module MENU
    
    #===========================================================================
    # Menu Commands
    # -------------------------------------------------------------------------
    # Adjust the following hash to modify which commands will appear where. Use
    # the following table to input in the commands as you see fit.
    # 
    #   :items ..........Default Item Menu
    #   :skill ..........Default Skill Menu
    #   :equip ..........Default Equip menu
    #   :status .........Default Status Menu
    #   :save ...........Default Save Menu
    #   :system .........Default Game End Menu
    # 
    # For the YEZ imported scripts.
    # 
    #   :formations .....Requires YEZ Formation Macros
    #   :party ..........Requires YEZ Party Selection System
    #   :mastery ........Requires YEZ Weapon Mastery Skills
    #   :class ..........Requires YEZ Job System: Classes
    #   :passives .......Requires YEZ Job System: Passives
    #   :cg_gallery .....Requires YEZ CG Gallery
    # 
    # For those that have imported KGC scripts.
    # 
    #   :kgc_largeparty .Requires KGC's Large Party
    #   :kgc_apviewer ...Requires KGC's Equip Learn Skill
    #   :kgc_skillcp ....Requires KGC's Skill CP System
    #   :kgc_difficulty .Requires KGC's Battle Difficulty
    #   :kgc_distribute .Requires KGC's Distribute Parameter
    #   :kgc_enemyguide .Requires KGC's Enemy Guide
    #   :kgc_outline ....Requires KGC's Outline
    # 
    # For those who are still attached to the YERD scripts.
    # 
    # :yerd_classchange .Requires YERD Subclass Selection System
    # :yerd_learnskill ..Requires YERD Subclass Selection System
    # :yerd_equipslots ..Requires YERD Equip Skill Slots
    # :yerd_bestiary ....Requires YERD Bestiary + Scanned Enemy
    #===========================================================================
    MENU_COMMANDS =[ # Follow the instructions above.
      :items,          # Default Item Menu
      :status,         # Default Status Menu
      :skill,          # Default Skill Menu
      :equip,          # Default Equip menu
#~       :formations,     # Requires YEZ Formation Macros
    # :mastery,        # Requires YEZ Weapon Mastery Skills
    # :class,          # Requires YEZ Job System: Class
    # :passives,       # Requires YEZ Job System: Passives
      :party,          # Requires YEZ Party Selection System
#~       :event1,         # learn perks
#~       :event2,         # display perks
#~       :event3,
    #  :cg_gallery,     # Requires YEZ CG Gallery
      :save,           # Default Save Menu
      :system,         # Default Game End Menu
    ] # Do not remove this.
    
    # This will determine whether or not your menu uses icons.
    USE_ICONS = true
    
    # If you're using icons, adjust the following hash to bind the right icons
    # to the right command.
    MENU_ICONS ={ # If an icon is not present, it will use the unused icon.
      :unused => 176,
      :items  => 144,
      :skill  => 1597,
      :class =>  159,
      :equip  => 898,
      :status => 1598,
      :save   => 1567,
      :system => 1582,
#~         "Unlisted"      => 898,
#~       # -----Vocab----- => Icon
#~         "Bestiary"      => 898,
#~         "Camp"          => 898,
#~         "Class Change"  => 898,
#~         "Quests"        => 898,
#~         "Equipment"     => 898,
#~         "Item"          => 1631,
#~         "Learn Skills"  => 1597,
#~         "Save"          => 1567,
#~         "Shutdown"      => 1885,
#~         "Slots"         => 898,
#~         "Skill"         => 1597,
#~         "Status"        => 1598,
#~         "System"        => 1582,
#~         "Party"         => 1822,
#~         "Storage"       => 1642,
#~         "Row Change"    => 1822,
#~         "Sandbox Mode"  => 1642,
#~         "Learn Perks"   => 1597,
#~         "Show Perks"    => 1597,

    } # Do not remove this.
    
    # This is the maximum number of rows to be displayed before the command
    # box will be cut off.
    MAX_ROWS = 11
    
    # Set the alignment for the text in your menu. By default, alignment is 0.
    #   0..Left Align, 1..Center Align, 2..Right Align
    ALIGN = 0
    
    # Setting this to true will cause the menu to shift to the right side of
    # the screen while moving the party status window over to the left side.
    MENU_RIGHT_SIDE = false
    
    # If this is set to true, the menu will not obscure the map until actor
    # selection is required. Events on the map will be frozen in place.
    ON_SCREEN_MENU = false
    
    #===========================================================================
    # Custom Menu Command - Lunatic Mode - Common Events
    # -------------------------------------------------------------------------
    # For those who would like to launch command events from the main menu,
    # modify this hash here to fit your liking. Then, add in the newly added
    # method to the MENU_COMMANDS array above.
    # 
    #   HideSw - This is the hide switch. Set to nil to not use a switch.
    #   DisbSw - This is the disable switch. Set to nil to not use a switch.
    #   Debug? - This item will only appear if it's $TEST mode.
    #   CEvent - This is the common event that will launch.
    #   Icon   - This is the icon used if the option is given.
    #   Title  - This is the text that will appear.
    #===========================================================================
    COMMON_EVENTS ={ # Follow the instructions above.
      # Method => [HideSw, DisbSw, Debug?, CEvent, Icon, Title Name]
      :event1  => [   nil,    nil,  false,      9,  1899, "Learn Perks"],
      :event2  => [   nil,    nil,  false,     10,  187, "Show Perks"],
      :event3  => [   437,    nil,  false,     19,  1575, "Exit Area"],
    } # Do not remove this.
      
    #===========================================================================
    # Custom Menu Command - Lunatic Mode - Imported Commands
    # -------------------------------------------------------------------------
    # The following is what KGC originally was going to have in his script but
    # was actually missing it in his publicized script. This will regain
    # functionality and also lift the "limit" of only 100 extra commands. The
    # following will explain how to set up the individual (0)options.
    # 
    #   HideSw - Switch used to hide the command. Set to nil if not used.
    #   DisbSw - Switch used to disable the command. Set to nil if not used.
    #   Actor? - Does this select an actor. Set to true if it does.
    #     Icon - Determines what icon will be used for this item.
    #    Title - The (2)title text that appears for the event.
    #    Scene - The scene used to launch the respective scene.
    # 
    # Note that this does not automatically detect what will and will not
    # disable the command ingame. You must understand and create a work
    # around with them (if they do disable the commands) with switches.
    # After binding your imported commands, go back to MENU_COMMANDS and
    # insert the proper command ID at the proper location.
    #===========================================================================
    IMPORTED_COMMANDS ={ # Follow the instructions above.
    # Method  => [HideSw, DisbSw, Actor?, Icon, Title Name, Scene Name.new]
     :quests  => [     8,      9,  false,   99,   "Quests", "Scene_Quest"],
     :faction => [    10,     11,  false,  100, "Factions", "Scene_Factions"],
     :row     => [   nil,    nil,  false,  101,     "Rows", "Scene_Row"],
     :record  => [   nil,    nil,  false,  102,  "Records", "Scene_Record"],
     :craft   => [   nil,    nil,  false,  103, "Crafting", "Scene_Crafting"],
    } # Do not remove this.
    
    #===========================================================================
    # Multi Variable Window
    # -------------------------------------------------------------------------
    # Imported straight from Scene Menu ReDux, this alters the gold window at
    # the bottom to display variables, time, steps, etc.
    #===========================================================================
    USE_MULTI_VARIABLE_WINDOW = true
    
    # Variables will be shown in this order. Use 0 to show gold. Adjust the
    # following information as seen necessary.
    VARIABLES_SHOWN = [-1, 0, 6, 1]
    VARIABLES_ICONS = false
    VARIABLES_HASH  ={ # Note that value zero must exist.
    # VarID => [Icon, Text]
          -1 => [ 188, "Time"],
           0 => [ 205, "MARKERS"],
           6 => [ 205, "COLLATERAL"],
           1 => [ 205, "Pioneer Level"],
    }# Do not remove this.
    
  end # MENU
end # YEZ

#===============================================================================
# Editting anything past this point may potentially result in causing computer
# damage, incontinence, explosion of user's head, coma, death, and/or halitosis.
# Therefore, edit at your own risk.
#===============================================================================

#===============================================================================
# Scene_Menu
#===============================================================================

class Scene_Menu < Scene_Base
  
  #--------------------------------------------------------------------------
  # new method: create_command_list
  #--------------------------------------------------------------------------
  def create_command_list
    vocab = []
    commands = []
    icons = []
    index_list = {}
    YEZ::MENU::MENU_COMMANDS.each_with_index { |c,i|
      case c
      when :items
        index_list[:items] = commands.size
        vocab.push(Vocab.item)
        
      when :skill # Skills
        index_list[:skill] = commands.size
        vocab.push(Vocab.skill)
        
      when :equip # Equip
        index_list[:equip] = commands.size
        vocab.push(Vocab.equip)
        
      when :status # Status
        index_list[:status] = commands.size
        vocab.push(Vocab.status)
        
      when :save # Save
        index_list[:save] = commands.size
        vocab.push(Vocab.save)
        
      when :system # System
        index_list[:system] = commands.size
        vocab.push(Vocab.game_end)
        
      #----- YEZ Imported Scripts -----
      
      when :formations # BEZ Formation Macros
        next unless $imported["FormationMacros"]
        next unless $game_switches[YEZ::MACRO::ENABLE_SWITCH]
        $game_party.members.size > 1
        index_list[:formations] = commands.size
        @command_formations = commands.size
        vocab.push(YEZ::MACRO::TITLE)
        
      when :party # Party Selection System
        next unless $imported["PartySelectionSystem"]
        next unless $game_switches[YEZ::PARTY::ENABLE_SWITCH]
        next unless $game_party.members.size > 1
        index_list[:party] = commands.size
        @command_party = commands.size
        vocab.push(YEZ::PARTY::TITLE)
        
      when :mastery # Weapon Mastery Skills
        next unless $imported["WeaponMasterySkills"]
        index_list[:mastery] = commands.size
        @command_mastery = commands.size
        vocab.push(YEZ::WEAPON_MASTERY::TITLE)
        
      when :class # Job System: Classes
        next unless $imported["JobSystemClasses"]
        next unless $game_switches[YEZ::JOB::ENABLE_1STCLASS_SWITCH] or 
          $game_switches[YEZ::JOB::ENABLE_SUBCLASS_SWITCH]
        index_list[:class] = commands.size
        @command_class = commands.size
        vocab.push(YEZ::JOB::CLASS_TITLE)
        
      when :passives # Job System: Passives
        next unless $imported["JobSystemPassives"]
        next unless $game_switches[YEZ::JOB::ENABLE_PASSIVE_SWITCH]
        index_list[:passives] = commands.size
        @command_passives = commands.size
        vocab.push(YEZ::JOB::PASSIVE_TITLE)
        
      when :cg_gallery # CG Gallery
        next unless $imported["CGGallery"]
        next unless $game_switches[YEZ::GALLERY::CG_ENABLE_SWITCH]
        index_list[:cg_gallery] = commands.size
        @command_cg_gallery = commands.size
        vocab.push(YEZ::GALLERY::CG_TITLE)
        
      #----- KGC Imported Scripts -----
        
      when :kgc_largeparty # KGC's Large Party
        next unless $imported["LargeParty"]
        index_list[:partyform] = commands.size
        @__command_partyform_index = commands.size
        vocab.push(Vocab.partyform)
        
      when :kgc_apviewer # KGC's AP Viewer
        next unless $imported["EquipLearnSkill"]
        index_list[:ap_viewer] = commands.size
        @__command_ap_viewer_index = commands.size
        vocab.push(Vocab.ap_viewer)
        
      when :kgc_skillcp # KGC's CP Skill System
        next unless $imported["SkillCPSystem"]
        index_list[:set_battle_skill] = commands.size
        @__command_set_battle_skill_index = commands.size
        vocab.push(Vocab.set_battle_skill)
        
      when :kgc_difficulty # KGC's Battle Difficulty
        next unless $imported["BattleDifficulty"]
        index_list[:set_difficulty] = commands.size
        @__command_set_difficulty_index = commands.size
        vocab.push(KGC::BattleDifficulty.get[:name])
        
      when :kgc_distribute # KGC's Distribute Parameter
        next unless $imported["DistributeParameter"]
        index_list[:distribute_parameter] = commands.size
        @__command_distribute_parameter_index = commands.size
        vocab.push(Vocab.distribute_parameter)
        
      when :kgc_enemyguide # KGC's Enemy Guide
        next unless $imported["EnemyGuide"]
        index_list[:enemy_guide] = commands.size
        @__command_enemy_guide_index = commands.size
        vocab.push(Vocab.enemy_guide)
        
      when :kgc_outline # KGC's Outline
        next unless $imported["Outline"]
        index_list[:outline] = commands.size
        @__command_outline_index = commands.size
        vocab.push(Vocab.outline)
        
      #----- YERD Imported Scripts -----
        
      when :yerd_classchange # Yanfly Subclass Class Change
        next unless $imported["SubclassSelectionSystem"]
        next unless YE::SUBCLASS::MENU_CLASS_CHANGE_OPTION
        next unless $game_switches[YE::SUBCLASS::ENABLE_CLASS_CHANGE_SWITCH]
        index_list[:classchange] = commands.size
        @command_class_change = commands.size
        vocab.push(YE::SUBCLASS::MENU_CLASS_CHANGE_TITLE)

      when :yerd_learnskill # Yanfly Subclass Learn Skill
        next unless $imported["SubclassSelectionSystem"]
        next unless YE::SUBCLASS::USE_JP_SYSTEM and 
        YE::SUBCLASS::LEARN_SKILL_OPTION
        next unless $game_switches[YE::SUBCLASS::ENABLE_LEARN_SKILLS_SWITCH]
        index_list[:learnskill] = commands.size
        @command_learn_skill = commands.size
        vocab.push(YE::SUBCLASS::LEARN_SKILL_TITLE)
        
      when :yerd_equipslots # Yanfly Equip Skill System
        next unless $imported["EquipSkillSlots"]
        next unless $game_switches[YE::EQUIPSKILL::ENABLE_SLOTS_SWITCH]
        index_list[:equipskill] = commands.size
        @command_equip_skill = commands.size
        vocab.push(YE::EQUIPSKILL::MENU_TITLE)
        
      when :yerd_bestiary  # Yanfly Bestiary
        next unless $imported["DisplayScannedEnemy"]
        next unless $game_switches[YE::MENU::MONSTER::BESTIARY_SWITCH]
        index_list[:bestiary] = commands.size
        @command_bestiary = commands.size
        vocab.push(YE::MENU::MONSTER::BESTIARY_TITLE)
        
      else # ---- Custom Commands ----
        if YEZ::MENU::COMMON_EVENTS.include?(c)
          common_event = YEZ::MENU::COMMON_EVENTS[c]
          next if !$TEST and common_event[2]
          next if common_event[0] != nil and $game_switches[common_event[0]]
          index_list[c] = commands.size
          vocab.push(common_event[5])
        elsif YEZ::MENU::IMPORTED_COMMANDS.include?(c)
          command_array = YEZ::MENU::IMPORTED_COMMANDS[c]
          next if command_array[0] != nil and $game_switches[command_array[0]]
          index_list[c] = commands.size
          vocab.push(command_array[4])
        else; next
        end
        
      end
      commands.push(c)
      icons.push(menu_icon(c))
    } # YEZ::MENU::MENU_COMMANDS.each_with_index
    $game_temp.menu_command_index = index_list
    @menu_array = [vocab, commands, icons]
  end
  
  #--------------------------------------------------------------------------
  # new method: menu_icon
  #--------------------------------------------------------------------------
  def menu_icon(command)
    if YEZ::MENU::MENU_ICONS.include?(command)
      return YEZ::MENU::MENU_ICONS[command]
    elsif YEZ::MENU::COMMON_EVENTS.include?(command)
      return YEZ::MENU::COMMON_EVENTS[command][4]
    elsif YEZ::MENU::IMPORTED_COMMANDS.include?(command)
      return YEZ::MENU::IMPORTED_COMMANDS[command][3]
    else
      return YEZ::MENU::MENU_ICONS[:unused]
    end
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: create_command_window
  #--------------------------------------------------------------------------
  def create_command_window
    create_command_list
    @command_window = Window_MenuCommand.new(@menu_array)
    @command_window.height = [@command_window.height,
      YEZ::MENU::MAX_ROWS * 24 + 32].min
    @command_window.index = [@menu_index, @menu_array[0].size - 1].min
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: update_command_selection
  #--------------------------------------------------------------------------
  def update_command_selection
    if Input.trigger?(PadConfig.cancel)
      check_debug_enable
      Sound.play_cancel
      $scene = Scene_Map.new
    elsif $TEST and Input.trigger?(Input.F5) # Debug Refresh Party
      Sound.play_recovery
      for member in $game_party.members
        member.hp += member.maxhp
        member.mp += member.maxmp
      end
      @status_window.refresh
    elsif Input.trigger?(PadConfig.decision)
      command = @command_window.method
      case command
      when :items # Item Command
        Sound.play_decision
        $scene = Scene_Item.new
      when :skill, :equip, :status # Skill, Equip, and Status Commands
        Sound.play_decision
        start_actor_selection
      when :save # Save Command
        if $game_system.save_disabled
          Sound.play_buzzer
        else
          Sound.play_decision
          $game_temp.menu_command_index[:save]
          $scene = Scene_File.new(true, false, false)
        end
      when :system # System Command
        Sound.play_decision
        $scene = Scene_End.new
      else # Custom Commands
        if YEZ::MENU::COMMON_EVENTS.include?(command)
          array = YEZ::MENU::COMMON_EVENTS[command]
          if array[1] != nil and $game_switches[array[1]]
            Sound.play_buzzer
          else
            Sound.play_decision
            $game_temp.common_event_id = array[3]
            $scene = Scene_Map.new
          end
        elsif YEZ::MENU::IMPORTED_COMMANDS.include?(command)
          array = YEZ::MENU::IMPORTED_COMMANDS[command]
          if array[1] != nil and $game_switches[array[1]]
            Sound.play_buzzer
          else
            Sound.play_decision
            if array[2]
              start_actor_selection
            else
              $scene = eval(array[5] + ".new")
            end
          end
        end
        
      end # if case check
    end # end if
  end # end update_command_selection
  
  #--------------------------------------------------------------------------
  # overwrite method: update_actor_selection
  #--------------------------------------------------------------------------
  def update_actor_selection
    if Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      end_actor_selection
      @status_window.close if YEZ::MENU::ON_SCREEN_MENU
    elsif $TEST and Input.trigger?(Input.F5) # Debug Refresh Party
      Sound.play_recovery
      for member in $game_party.members
        member.hp += member.maxhp
        member.mp += member.maxmp
      end
      @status_window.refresh
    elsif Input.trigger?(PadConfig.decision)
      $game_party.last_actor_index = @status_window.index
      Sound.play_decision
      command = @command_window.method
      case command
      when :skill # Skill Command
        $scene = Scene_Skill.new(@status_window.index)
      when :equip # Equip Command
        $scene = Scene_Equip.new(@status_window.index)
      when :status # Status Command
        $scene = Scene_Status.new(@status_window.index)
      else # Custom Commands
        if YEZ::MENU::IMPORTED_COMMANDS.include?(command)
          array = YEZ::MENU::IMPORTED_COMMANDS[command]
          $scene = eval(array[5] + ".new(@status_window.index)")
        end
      end
      
    end
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: start
  #--------------------------------------------------------------------------
  def start
    super
    create_menu_background
    create_command_window
    if YEZ::MENU::USE_MULTI_VARIABLE_WINDOW
      @gold_window = Window_MultiVariableWindow.new
    else
      @gold_window = Window_Gold.new(0, 360)
    end
    @status_window = Window_MenuStatus.new(160, 0)
    @right_side = YEZ::MENU::MENU_RIGHT_SIDE
    if YEZ::MENU::ON_SCREEN_MENU
      @gold_window.y = @command_window.height
      @status_window.openness = 0
      @right_side = true if $game_player.screen_x <= 176
      @right_side = false if $game_player.screen_x >= 368
      $game_temp.on_screen_menu = false
    end
    if @right_side
      @status_window.x = 0
      @command_window.x = 384
      @gold_window.x = 384
    end
  end
  
  #--------------------------------------------------------------------------
  # alias method: start_actor_selection
  #--------------------------------------------------------------------------
  alias start_actor_selection_mmz start_actor_selection unless $@
  def start_actor_selection
    if YEZ::MENU::ON_SCREEN_MENU
      @status_window.open
    end
    start_actor_selection_mmz
  end
  
  #--------------------------------------------------------------------------
  # new method: create_menu_background
  #--------------------------------------------------------------------------
  if YEZ::MENU::ON_SCREEN_MENU
  def create_menu_background
    @menuback_sprite = Spriteset_Map.new
  end
  end
  
end # Scene_Menu

#==============================================================================
# Imported from KGC's Custom Menu Command
# to improve compatibility amongst KGC scripts
#==============================================================================
$imported["CustomMenuCommand"] = true
class Game_Temp
  attr_accessor :menu_command_index
  attr_accessor :next_scene_actor_index
  attr_accessor :on_screen_menu
  
  alias initialize_KGC_CustomMenuCommand initialize unless $@
  def initialize
    initialize_KGC_CustomMenuCommand
    @menu_command_index = {}
    @next_scene_actor_index = 0
  end
end

module KGC
module Commands
  module_function
  def call_item
    return if $game_temp.in_battle
    $game_temp.next_scene = :menu_item
    $game_temp.next_scene_actor_index = 0
    $game_temp.menu_command_index = {}
  end
  def call_skill(actor_index = 0)
    return if $game_temp.in_battle
    $game_temp.next_scene = :menu_skill
    $game_temp.next_scene_actor_index = actor_index
    $game_temp.menu_command_index = {}
  end
  def call_equip(actor_index = 0)
    return if $game_temp.in_battle
    $game_temp.next_scene = :menu_equip
    $game_temp.next_scene_actor_index = actor_index
    $game_temp.menu_command_index = {}
  end
  def call_status(actor_index = 0)
    return if $game_temp.in_battle
    $game_temp.next_scene = :menu_status
    $game_temp.next_scene_actor_index = actor_index
    $game_temp.menu_command_index = {}
  end
end
end

class Game_Interpreter
  include KGC::Commands
end

class Scene_Map < Scene_Base
  alias update_scene_change_KGC_CustomMenuCommand update_scene_change unless $@
  def update_scene_change
    return if $game_player.moving?
    case $game_temp.next_scene
    when :menu_item
      call_menu_item
    when :menu_skill
      call_menu_skill
    when :menu_equip
      call_menu_equip
    when :menu_status
      call_menu_status
    else
      update_scene_change_KGC_CustomMenuCommand
    end
  end
  alias call_menu_mmz call_menu unless $@
  def call_menu
    $game_temp.on_screen_menu = true if YEZ::MENU::ON_SCREEN_MENU
    call_menu_mmz
  end
  def call_menu_item
    $game_temp.next_scene = nil
    $scene = Scene_Item.new
  end
  def call_menu_skill
    $game_temp.next_scene = nil
    $scene = Scene_Skill.new($game_temp.next_scene_actor_index)
    $game_temp.next_scene_actor_index = 0
  end
  def call_menu_equip
    $game_temp.next_scene = nil
    $scene = Scene_Equip.new($game_temp.next_scene_actor_index)
    $game_temp.next_scene_actor_index = 0
  end
  def call_menu_status
    $game_temp.next_scene = nil
    $scene = Scene_Status.new($game_temp.next_scene_actor_index)
    $game_temp.next_scene_actor_index = 0
  end
end

class Scene_Menu < Scene_Base
  def check_debug_enable
    return unless Input.press?(Input.F5)
    return unless Input.press?(Input.F9)
    $TEST = true
  end
end

class Scene_Item < Scene_Base
  def return_scene
    if $game_temp.menu_command_index.has_key?(:items)
      $scene = Scene_Menu.new($game_temp.menu_command_index[:items])
    else
      $scene = Scene_Map.new
    end
  end
end

class Scene_Skill < Scene_Base
  def return_scene
    if $game_temp.menu_command_index.has_key?(:skill)
      $scene = Scene_Menu.new($game_temp.menu_command_index[:skill])
    else
      $scene = Scene_Map.new
    end
  end
end

class Scene_Equip < Scene_Base
  def return_scene
    if $game_temp.menu_command_index.has_key?(:equip)
      $scene = Scene_Menu.new($game_temp.menu_command_index[:equip])
    else
      $scene = Scene_Map.new
    end
  end
end

class Scene_Status < Scene_Base
  def return_scene
    if $game_temp.menu_command_index.has_key?(:status)
      $scene = Scene_Menu.new($game_temp.menu_command_index[:status])
    else
      $scene = Scene_Map.new
    end
  end
end

class Scene_File < Scene_Base
  alias return_scene_KGC_CustomMenuCommand return_scene unless $@
  def return_scene
    if @from_title || @from_event
      return_scene_KGC_CustomMenuCommand
    elsif $game_temp.menu_command_index.has_key?(:save)
      $scene = Scene_Menu.new($game_temp.menu_command_index[:save])
    else
      $scene = Scene_Map.new
    end
  end
end

class Scene_End < Scene_Base
  def return_scene
    if $game_temp.menu_command_index.has_key?(:system)
      $scene = Scene_Menu.new($game_temp.menu_command_index[:system])
    else
      $scene = Scene_Map.new
    end
  end
end

#===============================================================================
# Game_Map
#===============================================================================

class Game_Map
  
  #--------------------------------------------------------------------------
  # map name
  #--------------------------------------------------------------------------
  unless method_defined?(:map_name)
  def map_name
    data = load_data("Data/MapInfos.rvdata") 
    text = data[@map_id].name.gsub(/\[.*\]/) { "" }
    return text
  end
  end
  
end # Game_Map

#===============================================================================
# Game_Actor
#===============================================================================

class Game_Actor < Game_Battler
  
  #--------------------------------------------------------------------------
  # new method: now_exp
  #--------------------------------------------------------------------------
  def now_exp
    return @exp - @exp_list[@level]
  end
  
  #--------------------------------------------------------------------------
  # new method: next_exp
  #--------------------------------------------------------------------------
  def next_exp
    return @exp_list[@level+1] > 0 ? @exp_list[@level+1] - @exp_list[@level] : 0
  end
  
end # Game_Actor

#===============================================================================
# Window_MultiVariableWindow
#===============================================================================

class Window_MultiVariableWindow < Window_Selectable
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize
    dh = 32 + 24 * YEZ::MENU::VARIABLES_SHOWN.size
    dy = Graphics.height - dh
    super(0, dy, 160, dh)
    refresh
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    @data = []
    for i in YEZ::MENU::VARIABLES_SHOWN
      next unless YEZ::MENU::VARIABLES_HASH.include?(i)
      @time_index = @data.size if i == -1
      @data.push(i)
    end
    @item_max = @data.size
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_item
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect(index)
    sw = self.width - 32
    dy = WLH * index
    self.contents.clear_rect(rect)
    i = @data[index]
    case i
    when -5 # Draw Map Name
      self.contents.draw_text(0, dy, sw, WLH, $game_map.map_name, 1)
      
    when -2 # Draw Steps
      if YEZ::MENU::VARIABLES_ICONS
        text = $game_party.steps
        self.contents.draw_text(0, dy, sw-24, WLH, text, 2)
        draw_icon(YEZ::MENU::VARIABLES_HASH[-2][0], sw-24, dy)
      else
        text = YEZ::MENU::VARIABLES_HASH[-2][1]
        value = $game_party.steps
        cx = contents.text_size(text).width
        self.contents.font.color = normal_color
        self.contents.draw_text(0, dy, sw-cx-2, WLH, value, 2)
        self.contents.font.color = system_color
        self.contents.draw_text(0, dy, sw, WLH, text, 2)
      end
      
    when -1 # Draw Time
      if YEZ::MENU::VARIABLES_ICONS
        text = game_time
        self.contents.draw_text(0, dy, sw-24, WLH, text, 2)
        draw_icon(YEZ::MENU::VARIABLES_HASH[-1][0], sw-24, dy)
      else
        self.contents.font.color = normal_color
        text = game_time
        self.contents.draw_text(0, dy, sw, WLH, text, 1)
      end
      
    when 0 # Draw Gold
      if YEZ::MENU::VARIABLES_ICONS
        text = $game_party.gold
        self.contents.draw_text(0, dy, sw-24, WLH, text, 2)
        draw_icon(YEZ::MENU::VARIABLES_HASH[0][0], sw-24, dy)
      else
        text = "Coins"
        value = $game_party.gold
        cx = contents.text_size(text).width
        self.contents.font.color = normal_color
        self.contents.draw_text(0, dy, sw-cx-2, WLH, Integer(value), 0)
        self.contents.font.color = system_color
        self.contents.draw_text(0, dy, sw, WLH, text, 2)
#~         self.contents.draw_text(0, dy, sw-24, WLH, $game_party.gold, 0)
#~         draw_currency_value($game_party.gold, 4, dy, 120)
      end
      
    else # Draw Variables
      if YEZ::MENU::VARIABLES_ICONS
        text = $game_variables[i]
        self.contents.draw_text(0, dy, sw-24, WLH, text, 2)
        draw_icon(YEZ::MENU::VARIABLES_HASH[i][0], sw-24, dy)
      else
        text = YEZ::MENU::VARIABLES_HASH[i][1]
        value = $game_variables[i]
        cx = contents.text_size(text).width
        self.contents.font.color = normal_color
        self.contents.draw_text(0, dy, sw-cx-2, WLH, value, 0)
        self.contents.font.color = system_color
        self.contents.draw_text(0, dy, sw, WLH, text, 2)
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # game_time
  #--------------------------------------------------------------------------
  def game_time
    gametime = Graphics.frame_count / Graphics.frame_rate
    hours = gametime / 3600
    minutes = gametime / 60 % 60
    seconds = gametime % 60
    result = sprintf("%d:%02d:%02d", hours, minutes, seconds)
    return result
  end
  
  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  if YEZ::MENU::VARIABLES_SHOWN.include?(-1)
  def update
    if game_time != (Graphics.frame_count / Graphics.frame_rate)
      draw_item(@time_index)
    end
    super
  end
  end
  
end # Window_MultiVariableWindow

#===============================================================================
# Window_MenuCommand
#===============================================================================

class Window_MenuCommand < Window_Command
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(array)
    @data = array[1]
    @icons = array[2]
    super(160, array[0])
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
  end
  
  #--------------------------------------------------------------------------
  # method
  #--------------------------------------------------------------------------
  def method; return @data[self.index]; end
    
  #--------------------------------------------------------------------------
  # draw_item
  #--------------------------------------------------------------------------
  def draw_item(index, enabled = true)
    rect = item_rect(index)
    rect.x += 4
    rect.width -= 8
    self.contents.clear_rect(rect)
    self.contents.font.color = normal_color
    #---
    text = @commands[index]
    icon = @icons[index]
    case @data[index]
    when :items, :skill, :equip, :status, :kgc_apviewer, :kgc_skillcp,
      :kgc_distribute, :yerd_classchange, :yerd_learnskill, :yerd_equipslots
      enabled = ($game_party.members.size == 0 ? false : true)
    when :save
      enabled = !$game_system.save_disabled 
    when :formations; icon = YEZ::MACRO::ICON
    when :party; icon = YEZ::PARTY::ICON
    when :mastery; icon = YEZ::WEAPON_MASTERY::ICON
    when :class; icon = YEZ::JOB::CLASS_ICON
    when :passives; icon = YEZ::JOB::PASSIVE_ICON
    when :cg_gallery; icon = YEZ::GALLERY::CG_ICON
    when :kgc_largeparty
      enabled = ($game_party.members.size == 0 ? false : true)
      enabled = false if !$game_party.partyform_enable?
    else
      if YEZ::MENU::COMMON_EVENTS.include?(@data[index])
        if YEZ::MENU::COMMON_EVENTS[@data[index]][1] != nil
          enabled = !YEZ::MENU::COMMON_EVENTS[@data[index]][1]
        end
      elsif YEZ::MENU::IMPORTED_COMMANDS.include?(@data[index])
        if YEZ::MENU::IMPORTED_COMMANDS[@data[index]][1] != nil
          enabled = !YEZ::MENU::IMPORTED_COMMANDS[@data[index]][1]
        end
      end
    end
    #---
    self.contents.font.color.alpha = enabled ? 255 : 128
    dx = rect.x; dy = rect.y; dw = rect.width
    if YEZ::MENU::USE_ICONS and icon.is_a?(Integer)
      draw_icon(icon, 0, dy, enabled)
      dx += 20; dw -= 20
    end
    self.contents.draw_text(dx, dy, dw, WLH, text, YEZ::MENU::ALIGN)
  end
  
end # Window_MenuCommand

#===============================================================================
# 
# END OF FILE
# 
#===============================================================================
=end