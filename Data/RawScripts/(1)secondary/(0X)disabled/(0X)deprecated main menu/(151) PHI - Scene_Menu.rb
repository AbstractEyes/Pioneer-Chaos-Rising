#==============================================================================
# ** Scene_Menu
#------------------------------------------------------------------------------
#  This class performs the menu screen processing.
#==============================================================================
=begin
class Scene_Menu < Scene_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     menu_index : command cursor's initial position
  #--------------------------------------------------------------------------
  def initialize(menu_index = 0)
    @menu_index = menu_index
  end
  #--------------------------------------------------------------------------
  # * Start processing
  #--------------------------------------------------------------------------
  def start
    super
    create_menu_background
    @command_window = Window_MenuCommands.new(0,0,$screen_width,32+32)
    @command_window.index = @menu_index
    @gold_window = Window_Gold.new(0, 360)
    @status_window = Window_MenuStatus.new(160, 64, 384, $screen_height-64)
    @help_window = Window_Help_Better.new(0,64,160,64)
  end
  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_menu_background
    @command_window.dispose
    @gold_window.dispose
    @status_window.dispose
    @help_window.dispose
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    update_menu_background
    @command_window.update
    @gold_window.update
    @status_window.update
    @help_window.update
    if @backup_index != @command_window.index
      @help_window.set_text(@command_window.command)
    end
    if @command_window.active
      update_command_selection
    elsif @status_window.active
      update_actor_selection
    end
  end
  #--------------------------------------------------------------------------
  # * Update Command Selection
  #--------------------------------------------------------------------------
  def update_command_selection
    if Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      $scene = Scene_Map.new
    elsif Input.trigger?(PadConfig.decision)
      if $game_party.members.size == 0 and @command_window.index < 4
        Sound.play_buzzer
        return
      elsif $game_system.save_disabled and @command_window.index == 4
        Sound.play_buzzer
        return
      end
      Sound.play_decision
      case @command_window.index
        when 0      # Item
          $scene = Scene_Item.new
        when 1,2,3  # Skill, equipment, status
          start_actor_selection
        when 4      # Party
          $scene = Scene_Party.new
          #$scene = Scene_File.new(true, false, false)
        when 5
          $scene = Scene_Formation.new
        when 6
          $scene = Scene_Options.new
        when 6
          $scene = Scene_Map.new
        end
    end
  end
  #--------------------------------------------------------------------------
  # * Start Actor Selection
  #--------------------------------------------------------------------------
  def start_actor_selection
    @command_window.active = false
    @status_window.active = true
    if $game_party.last_actor_index < @status_window.item_max
      @status_window.index = $game_party.last_actor_index
    else
      @status_window.index = 0
    end
  end
  #--------------------------------------------------------------------------
  # * End Actor Selection
  #--------------------------------------------------------------------------
  def end_actor_selection
    @command_window.active = true
    @status_window.active = false
  end
  #--------------------------------------------------------------------------
  # * Update Actor Selection
  #--------------------------------------------------------------------------
  def update_actor_selection
    if Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      $game_party.last_actor_index = @status_window.index
      end_actor_selection
    elsif Input.trigger?(PadConfig.decision)
      $game_party.last_actor_index = @status_window.index
      Sound.play_decision
      case @command_window.index
      when 1  # skill
        $scene = Scene_Skill.new(@status_window.index)
      when 2  # equipment
        $scene = Scene_Equip.new(@status_window.index)
      when 3  # status
        $scene = Scene_Status.new(@status_window.index)
      end
    end
  end
end
=end