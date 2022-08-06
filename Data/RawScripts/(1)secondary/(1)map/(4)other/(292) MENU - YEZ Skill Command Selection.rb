=begin
#===============================================================================
# 
# Yanfly Engine Zealous - Skill Command Selection
# Last Date Updated: 2010.01.28
# Level: Normal
# 
# This script basically functions as a bridge inbetween many YEZ scripts in
# addition to making all of the skill-related YEZ scripts accessible from one
# common place. Menu searching and surfing can become quite annoying for the
# player and this script's main purpose is to minimize that annoyance.
# 
#===============================================================================
# Updates
# -----------------------------------------------------------------------------
# o 2010.01.28 - Efficiency update.
# o 2010.01.20 - Passive equipping efficiency update.
# o 2010.01.12 - Job System: Passives Compatibility.
# o 2010.01.05 - Job System: Classes Compatibility.
# o 2010.01.03 - Mastery refresh window bugfix.
# o 2009.01.01 - Job System: Skill Levels Compatibility.
#              - Efficiency update.
# o 2009.12.30 - Started Script and Finished Script.
#===============================================================================
# Instructions
# -----------------------------------------------------------------------------
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials but above ▼ Main. Remember to save.
# 
# -----------------------------------------------------------------------------
# Debug Shortcuts - Only during $TEST and $BTEST mode
# -----------------------------------------------------------------------------
# During testplay mode, pressing F5 during the command window selection process
# or the skill selection process will recover all of the actor's MP.
# 
#===============================================================================
# Compatibility
# -----------------------------------------------------------------------------
# - Works With: YEZ Status Command Menu, YEZ Job System: Base
# -----------------------------------------------------------------------------
# Note: This script may not work with former Yanfly Engine ReDux scripts.
#       Use Yanfly Engine Zealous scripts to work with this if available.
#===============================================================================

$imported = {} if $imported == nil
$imported["SkillCommandSelection"] = true

module YEZ
  module SKILL
    
    #===========================================================================
    # Basic Settings
    # --------------------------------------------------------------------------
    # The following below will adjust the basic settings and vocabulary that
    # will display throughout the script. Change them as you see fit.
    #===========================================================================
    
    # The following array determines the commands that appear in the command
    # window at the skill scene's upper left corner.
    COMMANDS =[
      :view_skills, # View all skills.
      :learn_skill, # Requires Job System: Base
      :level_skill, # Requires Job System: Skill Levels
      :equip_state, # Requires Job System: Passives
      :learn_state, # Requires Job System: Passives
    # :mastery,     # Requires Weapon Mastery Skills
    ] # Do not remove this.
    
    # If you would like the command window to have centered alignment for text,
    # set this to true. Otherwise, setting it to false will have left alignment.
    CENTERED_COMMAND = true
    
    # The following determines the vocabulary used for the remade skill scene.
    VOCAB ={
      :view_skills => "View All",
      :equip_state => "Add Passive",
      :learn_state => "New Passive",
    } # Do not remove this.
    
  end # SKILL
end # YEZ

#===============================================================================
# Editting anything past this point may potentially result in causing computer
# damage, incontinence, explosion of user's head, coma, death, and/or halitosis.
# Therefore, edit at your own risk.
#===============================================================================

#===============================================================================
# Game_Temp
#===============================================================================

class Game_Temp
  
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :scs_on
  attr_accessor :scs_oy
  
end # Game_Temp

#===============================================================================
# Scene_Skill
#===============================================================================

class Scene_Skill < Scene_Base
  
  #--------------------------------------------------------------------------
  # alias method: initialize
  #--------------------------------------------------------------------------
  alias initialize_scs initialize unless $@
  def initialize(actor_index = 0, last_index = 0)
    initialize_scs(actor_index, last_index)
    @last_index = last_index
    $game_temp.scs_on = true
  end

  #--------------------------------------------------------------------------
  # overwrite method: start
  #--------------------------------------------------------------------------
  def start
    super
    create_menu_background
    @actor = $game_party.members[@actor_index]
    $game_party.last_actor_index = @actor_index
    @viewport = Viewport.new(0, 0, 544, 416)
    @help_window = Window_Help.new
    @help_window.viewport = @viewport
    @help_window.y = 128
    if $imported["JobSystemBase"]
      @status_window = Window_JP_Actor.new(@actor)
    elsif $imported["StatusCommandMenu"]
      @status_window = Window_Status_Actor.new(@actor)
    else
      @status_window = Window_Skill_Actor.new(@actor)
    end
    @status_window.viewport = @viewport
    if $imported["JobSystemClasses"] and @actor.all_unlocked_classes.size > 1
      @class_window = Window_Class_List.new(@actor, 0, @help_window.y + 
      @help_window.height)
      @class_window.help_window = @help_window
      @classdata_window = Window_Class_Info.new(@class_window.width, 
        @class_window.y, @actor)
      @class_window.y = 416*3
      @classdata_window.y = @class_window.y
    end
    create_command_window
    @target_window = Window_MenuStatus.new(0, 0)
    hide_target_window
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: terminate
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_menu_background
    @help_window.dispose if @help_window != nil
    @status_window.dispose if @status_window != nil
    @target_window.dispose if @target_window != nil
    @command_window.dispose if @command_window != nil
    @learndata_window.dispose if @learndata_window != nil
    @leveldata_window.dispose if @leveldata_window != nil
    @class_window.dispose if @class_window != nil
    @classdata_window.dispose if @classdata_window != nil
    @stapas_window.dispose if @stapas_window != nil
    @eqpaslist_window.dispose if @eqpaslist_window != nil
    @eqpasstat_window.dispose if @eqpasstat_window != nil
    @lepasdata_window.dispose if @lepasdata_window != nil
    @clpasdata_window.dispose if @clpasdata_window != nil
    dispose_mini_windows
  end
  
  #--------------------------------------------------------------------------
  # new method: create_command_window
  #--------------------------------------------------------------------------
  def create_command_window
    commands = []; @data = []; @mini_windows = {}
    for command in YEZ::SKILL::COMMANDS
      case command
      when :view_skills
        @skill_window = Window_Skill.new(0, 184, 544, 232, @actor)
        @skill_window.viewport = @viewport
        @skill_window.help_window = @help_window
        @skill_window.active = false
        @mini_windows[@data.size] = @skill_window
        commands.push(YEZ::SKILL::VOCAB[command])
        
      when :learn_skill
        next unless $imported["JobSystemBase"]
        next unless $game_switches[YEZ::JOB::LEARN_ENABLE_SWITCH]
        dy = @status_window.height + @help_window.height
        @learnskill_window = Window_LearnSkill.new(0, dy, @actor)
        @learndata_window = Window_LearnData.new(@learnskill_window.width,
          @learnskill_window.y, @learnskill_window.skill, @actor, @actor.class_id)
        @learnskill_window.help_window = @help_window
        @learnskill_window.active = false
        @mini_windows[@data.size] = @learnskill_window
        commands.push(YEZ::JOB::LEARN_TITLE)
        
      when :level_skill
        next unless $imported["JobSystemSkillLevels"]
        next unless $game_switches[YEZ::JOB::LEVEL_ENABLE_SWITCH]
        dy = @status_window.height + @help_window.height
        @levelskill_window = Window_LevelSkill.new(0, dy, @actor)
        @leveldata_window = Window_LevelData.new(@levelskill_window.width,
          @levelskill_window.y, @levelskill_window.skill, @actor, @actor.class_id)
        @levelskill_window.help_window = @help_window
        @levelskill_window.active = false
        @mini_windows[@data.size] = @levelskill_window
        commands.push(YEZ::JOB::LEVEL_TITLE)
        
      when :equip_state
        next unless $imported["JobSystemPassives"]
        next unless $game_switches[YEZ::JOB::ENABLE_PASSIVE_SWITCH]
        create_passive_windows
        @equippas_window = Window_PassiveEquip.new(0, @help_window.y +
          @help_window.height, @actor)
        @equippas_window.help_window = @help_window
        @eqpaslist_window = Window_PassiveEquipList.new(0, @equippas_window.y,
          @actor)
        @eqpaslist_window.help_window = @help_window
        @eqpasstat_window = Window_PassiveEquipStat.new(@eqpaslist_window.width,
          @eqpaslist_window.y, @actor)
        @mini_windows[@data.size] = @equippas_window
        commands.push(YEZ::SKILL::VOCAB[command])
        
      when :learn_state
        next unless $imported["JobSystemPassives"]
        next unless $game_switches[YEZ::JOB::ENABLE_PASSIVE_SWITCH]
        create_passive_windows
        @learnpas_window = Window_LearnPassive.new(0, @help_window.y +
          @help_window.height, @actor)
        @learnpas_window.help_window = @help_window
        @lepasdata_window = Window_LearnPassiveData.new(@learnpas_window.width,
        @learnpas_window.y, @learnpas_window.passive, @actor)
        @learnpas_window.active = false
        @clpasdata_window = Window_Class_PassiveInfo.new(@class_window.width, 
          @learnpas_window.y, @actor) if @class_window != nil
        @mini_windows[@data.size] = @learnpas_window
        commands.push(YEZ::SKILL::VOCAB[command])
        
      when :mastery
        next unless $imported["WeaponMasterySkills"]
        @mastery_window = Window_Mastery.new(0, 128, @actor, true)
        @mini_windows[@data.size] = @mastery_window
        commands.push(YEZ::WEAPON_MASTERY::TITLE)
        
      else; next
      end
      @data.push(command)
    end
    if YEZ::SKILL::CENTERED_COMMAND
      @command_window = Window_Command_Centered.new(160, commands)
    else
      @command_window = Window_Command.new(160, commands)
    end
    @command_window.height = 128
    @command_window.oy = $game_temp.scs_oy if $game_temp.scs_oy != nil
    @command_window.index = @last_index
    @command_window.active = true
    @command_window.viewport = @viewport
    update_mini_windows
  end
  
  #--------------------------------------------------------------------------
  # new method: update_mini_windows
  #--------------------------------------------------------------------------
  def update_mini_windows
    @last_index = @command_window.index
    @status_window.y = 0
    @class_window.y = 416*3 if @class_window != nil
    @classdata_window.y = @class_window.y if @classdata_window != nil
    @learndata_window.y = 416*3 if @learndata_window != nil
    @leveldata_window.y = 416*3 if @leveldata_window != nil
    @eqpaslist_window.y = 416*3 if @eqpaslist_window != nil
    @eqpasstat_window.y = 416*3 if @eqpasstat_window != nil
    @stapas_window.y = 416*3 if @stapas_window != nil
    @lepasdata_window.y = 416*3 if @lepasdata_window != nil
    @clpasdata_window.y = 416*3 if @clpasdata_window != nil
    class_id = @status_window.class
    for i in 0..(@mini_windows.size-1)
      @mini_windows[i].y = 416*3
    end
    case @mini_windows[@last_index]
    when @skill_window
      @help_window.visible = true
      @skill_window.refresh
      @mini_windows[@last_index].update_help
      @mini_windows[@last_index].y = @status_window.height
      @mini_windows[@last_index].y += @help_window.height if @help_window.visible
    when @learnskill_window
      @help_window.visible = true
      if @class_window != nil
        @class_window.y = @status_window.height + @help_window.height
        @classdata_window.y = @class_window.y
        @class_window.update_help
        return
      end
      @learnskill_window.refresh(class_id)
      @learndata_window.y = @status_window.height + @help_window.height
      @learndata_window.refresh(@learnskill_window.skill, @status_window.class)
      @mini_windows[@last_index].update_help
      @mini_windows[@last_index].y = @status_window.height
      @mini_windows[@last_index].y += @help_window.height if @help_window.visible
    when @levelskill_window
      @help_window.visible = true
      if @class_window != nil
        @class_window.y = @status_window.height + @help_window.height
        @classdata_window.y = @class_window.y
        @class_window.update_help
        return
      end
      @levelskill_window.refresh(class_id)
      @leveldata_window.y = @status_window.height + @help_window.height
      @leveldata_window.refresh(@levelskill_window.skill, @status_window.class)
      @mini_windows[@last_index].update_help
      @mini_windows[@last_index].y = @status_window.height
      @mini_windows[@last_index].y += @help_window.height if @help_window.visible
    when @equippas_window
      @equippas_window.refresh
      @stapas_window.refresh
      @eqpasstat_window.refresh
      @help_window.visible = true
      @stapas_window.y = 0
      @status_window.y = 416*3
      @equippas_window.y = @help_window.height + @help_window.y
      @eqpasstat_window.y = @equippas_window.y
      @equippas_window.update_help
    when @learnpas_window
      @learnpas_window.refresh(@stapas_window.class)
      @help_window.visible = true
      @stapas_window.y = 0
      @status_window.y = 416*3
      if @class_window != nil
        @class_window.y = @status_window.height + @help_window.height
        @clpasdata_window.y = @class_window.y
        @class_window.update_help
        return
      end
      @learnpas_window.y = @help_window.height + @help_window.y
      @lepasdata_window.y = @learnpas_window.y
      @learnpas_window.update_help
      
    when @mastery_window
      @help_window.visible = false
      @mini_windows[@last_index].y = @status_window.height
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: dispose_mini_windows
  #--------------------------------------------------------------------------
  def dispose_mini_windows
    for i in 0..(@mini_windows.size-1)
      next if @mini_windows[i] == nil
      @mini_windows[i].dispose
      @mini_windows[i] = nil
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: refresh_windows
  #--------------------------------------------------------------------------
  def refresh_windows(class_id = nil)
    @status_window.refresh(class_id) if @status_window != nil
    @class_window.refresh if @class_window != nil
    @classdata_window.refresh(class_id) if @classdata_window != nil
  end
  
  #--------------------------------------------------------------------------
  # new method: old_refresh_windows
  #--------------------------------------------------------------------------
  def old_refresh_windows(class_id = nil)
    @status_window.refresh(class_id) if @status_window != nil
    @skill_window.refresh if @skill_window != nil
    @class_window.refresh if @class_window != nil
    @classdata_window.refresh(class_id) if @classdata_window != nil
    @learnskill_window.refresh(class_id) if @learnskill_window != nil
    @levelskill_window.refresh(class_id) if @levelskill_window != nil
    @equippas_window.refresh if @equippas_window != nil
    @stapas_window.refresh if @stapas_window != nil
    @eqpasstat_window.refresh if @eqpasstat_window != nil
    @learnpas_window.refresh(@stapas_window.class) if @learnpas_window != nil
  end
  
  #--------------------------------------------------------------------------
  # alias method: return_scene
  #--------------------------------------------------------------------------
  alias return_scene_scs return_scene
  def return_scene
    $game_temp.scs_oy = nil
    $game_temp.scs_on = nil
    return_scene_scs
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: next_actor
  #--------------------------------------------------------------------------
  def next_actor
    $game_temp.scs_oy = @command_window.oy
    @actor_index += 1
    @actor_index %= $game_party.members.size
    $scene = Scene_Skill.new(@actor_index, @last_index)
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: prev_actor
  #--------------------------------------------------------------------------
  def prev_actor
    $game_temp.scs_oy = @command_window.oy
    @actor_index += $game_party.members.size - 1
    @actor_index %= $game_party.members.size
    $scene = Scene_Skill.new(@actor_index, @last_index)
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: update
  #--------------------------------------------------------------------------
  def update
    super
    update_menu_background
    @help_window.update
    if @command_window.active
      update_command_selection
    elsif @subskill_window != nil and @subskill_window.active
      update_subskill_window
    elsif @learnskill_window != nil and @learnskill_window.active
      update_learnskill_selection
    elsif @levelskill_window != nil and @levelskill_window.active
      update_levelskill_selection
    elsif @equippas_window != nil and @equippas_window.active
      update_equippas_selection
    elsif @eqpaslist_window != nil and @eqpaslist_window.active
      update_equiplist_selection
    elsif @learnpas_window != nil and @learnpas_window.active
      update_learnpassive_selection
    elsif @class_window != nil and @class_window.active
      update_class_selection
    elsif @skill_window.active
      @skill_window.update
      update_skill_selection
    elsif @target_window.active
      @target_window.update
      update_target_selection
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: update_command_selection
  #--------------------------------------------------------------------------
  def update_command_selection
    @command_window.update
    update_mini_windows if @last_index != @command_window.index
    if Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      return_scene
    elsif $TEST and Input.trigger?(Input.F5)  # Debug MP Recovery
      Sound.play_recovery
      @actor.mp += @actor.maxmp
      @status_window.refresh
      @skill_window.refresh if @skill_window.visible
    elsif Input.repeat?(PadConfig.right)
      Sound.play_cursor
      next_actor
    elsif Input.repeat?(PadConfig.left)
      Sound.play_cursor
      prev_actor
    elsif Input.trigger?(PadConfig.decision)
      Sound.play_decision
      case @data[@command_window.index]
      when :view_skills
        @command_window.active = false
        @skill_window.active = true
      when :mastery
        $scene = Scene_Mastery.new(@actor_index, @command_window.index)
      when :learn_skill
        if @class_window != nil
          @command_window.active = false
          @class_window.active = true
        else
          start_learnskill_selection
        end
      when :level_skill
        if @class_window != nil
          @command_window.active = false
          @class_window.active = true
        else
          start_levelskill_selection
        end
      when :equip_state
        Sound.play_decision
        @command_window.active = false
        @equippas_window.active = true
      when :learn_state
        if @class_window != nil
          @command_window.active = false
          @class_window.active = true
        else
          start_learn_passives
        end
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: update_skill_selection
  #--------------------------------------------------------------------------
  def update_skill_selection
    if Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      @command_window.active = true
      @skill_window.active = false
    elsif $TEST and Input.trigger?(Input.F5)  # Debug MP Recovery
      Sound.play_recovery
      @actor.mp += @actor.maxmp
      @status_window.refresh
      @skill_window.refresh
    elsif Input.trigger?(PadConfig.decision)
      @skill = @skill_window.skill
      if @skill != nil
        @actor.last_skill_id = @skill.id
      end
      if @actor.skill_can_use?(@skill)
        Sound.play_decision
        determine_skill
      else
        Sound.play_buzzer
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: update_class_selection
  #--------------------------------------------------------------------------
  def update_class_selection
    @class_window.update
    if @class_window.class != @status_window.class
      @status_window.refresh(@class_window.class)
      @stapas_window.refresh(@class_window.class) if @stapas_window != nil
      @classdata_window.refresh(@class_window.class)
      @clpasdata_window.refresh(@class_window.class) if @clpasdata_window != nil
    end
    if Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      @command_window.active = true
      @class_window.active = false
    elsif Input.repeat?(Input.F8) and $TEST # Debug increase JP
      Sound.play_equip
      value = YEZ::JOB::JP_COST * 10
      value *= 10 if Input.press?(Input.SHIFT)
      for class_id in @actor.all_unlocked_classes
        @actor.gain_jp(value + rand(value), class_id)
      end
      @class_window.refresh
      @status_window.refresh(@class_window.class)
    elsif Input.repeat?(Input.F7) and $TEST # Debug increase JP
      Sound.play_equip
      value = YEZ::JOB::JP_COST * 10
      value *= 10 if Input.press?(Input.SHIFT)
      for class_id in @actor.all_unlocked_classes
        @actor.lose_jp(value + rand(value), class_id)
      end
      @class_window.refresh
      @status_window.refresh(@class_window.class)
    elsif Input.trigger?(PadConfig.decision)
      Sound.play_decision
      refresh_windows(@status_window.class)
      class_id = @status_window.class
      case @data[@command_window.index]
      when :learn_skill
        start_learnskill_selection
        @learnskill_window.refresh(class_id)
        @learndata_window.y = @status_window.height + @help_window.height
        @learndata_window.refresh(@learnskill_window.skill, @status_window.class)
      when :level_skill
        start_levelskill_selection
        @levelskill_window.refresh(class_id)
        @leveldata_window.y = @status_window.height + @help_window.height
        @leveldata_window.refresh(@levelskill_window.skill, @status_window.class)
      when :learn_state
        start_learn_passives
        @learnpas_window.refresh(@stapas_window.class)
        @clpasdata_window.y = 416*3 if @clpasdata_window != nil
      end
      @class_window.y = 416*3
      @classdata_window.y = @class_window.y
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: create_passive_windows
  #--------------------------------------------------------------------------
  def create_passive_windows
    return if @stapas_window != nil
    @stapas_window = Window_Passive_Actor.new(@actor)
  end
  
  #--------------------------------------------------------------------------
  # new method: update_equippas_selection
  #--------------------------------------------------------------------------
  def update_equippas_selection
    @equippas_window.update
    if @equip_index != @equippas_window.index
      @equip_index = @equippas_window.index
    end
    if Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      @command_window.active = true
      @equippas_window.active = false
    elsif Input.trigger?(PadConfig.decision) or ($TEST and Input.trigger?(Input.F5))
      if @equip_index <= @equippas_window.auto_size - 1
        Sound.play_buzzer
        return
      end
      Sound.play_decision
      @equippas_window.active = false
      @equippas_window.y = 416*3
      @eqpaslist_window.active = true
      @eqpaslist_window.y = @help_window.height + @stapas_window.height
      @eqpaslist_window.refresh(@equippas_window.passive)
      @eqpasstat_window.y = @help_window.height + @stapas_window.height
      refresh_equipstat_window
      @eqpaslist_window.update_help
    elsif Input.trigger?(PadConfig.dash)
      if @equip_index <= @equippas_window.auto_size - 1
        Sound.play_buzzer
        return
      end
      return if @equippas_window.passive == nil
      Sound.play_equip
      slot = @equippas_window.index - @equippas_window.auto_size
      passive = 0
      last_hp = @actor.maxhp
      last_mp = @actor.maxmp
      @actor.equip_passive(passive, slot)
      @actor.hp += @actor.maxhp - last_hp
      @actor.mp += @actor.maxmp - last_mp
      @equippas_window.refresh
      @equippas_window.update_help
      @stapas_window.refresh
    end
  end
  
  #--------------------------------------------------------------------------
  # refresh_equipstat_window
  #--------------------------------------------------------------------------
  def refresh_equipstat_window
    @equiplist_last_index = @eqpaslist_window.index
    passive = @eqpaslist_window.passive
    slot = @equippas_window.index - @equippas_window.auto_size
    if passive == @equippas_window.passive or passive == nil
      passive = 0 
    elsif @actor.equipped_passives.include?(passive.id)
      passive = @actor.equipped_passives[slot]
    end
    @eqpasstat_window.refresh(passive, slot)
  end
  
  #--------------------------------------------------------------------------
  # update_equiplist_selection
  #--------------------------------------------------------------------------
  def update_equiplist_selection
    @eqpaslist_window.update
    refresh_equipstat_window if @equiplist_last_index != @eqpaslist_window.index
    if Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      @equippas_window.active = true
      @equippas_window.y = @help_window.height + @stapas_window.height
      @eqpaslist_window.active = false
      @eqpaslist_window.y = 416*3
      refresh_windows
      @equippas_window.refresh
      @equippas_window.update_help
    elsif $TEST and Input.repeat?(Input.F5)  # Debug Force Equip
      Sound.play_equip
      passive = @eqpaslist_window.passive
      slot = @equippas_window.index - @equippas_window.auto_size
      passive = 0 if passive == nil or passive == @equippas_window.passive
      last_hp = @actor.maxhp
      last_mp = @actor.maxmp
      @actor.equip_passive(passive, slot)
      @actor.hp += @actor.maxhp - last_hp
      @actor.mp += @actor.maxmp - last_mp
      @equippas_window.active = true
      @equippas_window.y = @help_window.height + @stapas_window.height
      @eqpaslist_window.active = false
      @eqpaslist_window.y = 416*3
      refresh_windows
      @equippas_window.refresh
      @stapas_window.refresh
      @eqpasstat_window.refresh
      @equippas_window.update_help
    elsif Input.trigger?(PadConfig.decision)
      passive = @eqpaslist_window.passive
      if passive != nil and !@eqpaslist_window.enabled_passive?(passive)
        Sound.play_buzzer
        return
      end
      Sound.play_equip
      slot = @equippas_window.index - @equippas_window.auto_size
      passive = 0 if passive == nil or passive == @equippas_window.passive
      last_hp = @actor.maxhp
      last_mp = @actor.maxmp
      @actor.equip_passive(passive, slot)
      @actor.hp += @actor.maxhp - last_hp
      @actor.mp += @actor.maxmp - last_mp
      @equippas_window.active = true
      @equippas_window.y = @help_window.height + @stapas_window.height
      @eqpaslist_window.active = false
      @eqpaslist_window.y = 416*3
      refresh_windows
      @equippas_window.refresh
      @stapas_window.refresh
      @eqpasstat_window.refresh
      @equippas_window.update_help
    elsif Input.trigger?(PadConfig.dash)
      Sound.play_equip
      slot = @equippas_window.index - @equippas_window.auto_size
      passive = 0
      last_hp = @actor.maxhp
      last_mp = @actor.maxmp
      @actor.equip_passive(passive, slot)
      @actor.hp += @actor.maxhp - last_hp
      @actor.mp += @actor.maxmp - last_mp
      @equippas_window.active = true
      @equippas_window.y = @help_window.height + @stapas_window.height
      @eqpaslist_window.active = false
      @eqpaslist_window.y = 416*3
      refresh_windows
      @equippas_window.refresh
      @stapas_window.refresh
      @eqpasstat_window.refresh
      @equippas_window.update_help
    end
  end
  
  #--------------------------------------------------------------------------
  # start_learn_passives
  #--------------------------------------------------------------------------
  def start_learn_passives
    @learnpas_window.y = @help_window.height + @stapas_window.height
    @learnpas_window.active = true
    @lepasdata_window.y = @help_window.height + @stapas_window.height
    @lepasdata_window.refresh(@learnpas_window.passive, @stapas_window.class)
  end
  
  #--------------------------------------------------------------------------
  # update_learnpassive_selection
  #--------------------------------------------------------------------------
  def update_learnpassive_selection
    @learnpas_window.update
    if @last_learn_index != @learnpas_window.index
      @last_learn_index = @learnpas_window.index
      @lepasdata_window.refresh(@learnpas_window.passive, @stapas_window.class)
    end
    if Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      if @class_window != nil
        @class_window.y = @learnpas_window.y
        @class_window.active = true
        @class_window.update_help
        @clpasdata_window.y = @class_window.y
        @learnpas_window.active = false
        @learnpas_window.y = 416*3
        @lepasdata_window.y = 416*3
      else
        @learnpas_window.active = false
        @command_window.active = true
      end
    elsif $TEST and Input.repeat?(Input.F8)  # Debug JP Increase
      Sound.play_equip
      value = YEZ::JOB::DEFAULT_PASSIVE_JP_COST * 10
      value *= 10 if Input.press?(Input.SHIFT)
      @actor.gain_jp(value + rand(value), @stapas_window.class)
      @stapas_window.refresh
      @equippas_window.refresh if @equippas_window != nil
      @lepasdata_window.refresh(@learnpas_window.passive, @stapas_window.class)
      @class_window.refresh if @class_window != nil
      @learnpas_window.refresh
    elsif $TEST and Input.repeat?(Input.F7)  # Debug JP Decrease
      Sound.play_equip
      value = YEZ::JOB::DEFAULT_PASSIVE_JP_COST * 10
      value *= 10 if Input.press?(Input.SHIFT)
      @actor.lose_jp(value + rand(value), @stapas_window.class)
      @stapas_window.refresh
      @equippas_window.refresh if @equippas_window != nil
      @lepasdata_window.refresh(@learnpas_window.passive, @stapas_window.class)
      @class_window.refresh if @class_window != nil
      @learnpas_window.refresh
    elsif $TEST and Input.repeat?(Input.F5)  # Debug Force Learn
      passive = @learnpas_window.passive
      return if passive == nil
      YEZ::JOB::LEARN_SOUND.play
      @actor.learn_passive(passive)
      @stapas_window.refresh
      @learnpas_window.refresh
      @equippas_window.refresh if @equippas_window != nil
      @lepasdata_window.refresh(passive, @stapas_window.class)
      @clpasdata_window.refresh(@class_window.class) if @clpasdata_window != nil
    elsif Input.trigger?(PadConfig.decision)
      passive = @learnpas_window.passive
      if passive == nil or !@learnpas_window.enabled_state?(passive)
        Sound.play_buzzer
        return
      end
      YEZ::JOB::LEARN_SOUND.play
      @actor.learn_passive(passive)
      @actor.lose_jp(passive.jp_cost, @stapas_window.class)
      @stapas_window.refresh
      @learnpas_window.refresh
      @equippas_window.refresh if @equippas_window != nil
      @lepasdata_window.refresh(passive, @stapas_window.class)
      @clpasdata_window.refresh(@class_window.class) if @clpasdata_window != nil
    end
  end
  
end # Scene_Skill

#===============================================================================
# Window_Command_Centered
#===============================================================================

class Window_Command_Centered < Window_Command
  
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
    self.contents.draw_text(rect, @commands[index], 1)
  end
  
end # Window_Command_Centered

#===============================================================================
# Window_Skill_Actor
#===============================================================================

class Window_Skill_Actor < Window_Base
  
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
    y = WLH / 2
    draw_actor_name(@actor, x, y)
    draw_actor_class(@actor, x + 120, y)
    draw_actor_level(@actor, x, y + WLH * 1)
    draw_actor_state(@actor, x, y + WLH * 2)
    draw_actor_hp(@actor, x + 120, y + WLH * 1)
    draw_actor_mp(@actor, x + 120, y + WLH * 2)
  end
  
end # Window_Skill_Actor

#===============================================================================
# 
# END OF FILE
# 
#===============================================================================
=end