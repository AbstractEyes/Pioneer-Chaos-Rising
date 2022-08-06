#==============================================================================
# ** Scene_Title
#------------------------------------------------------------------------------
#  This class performs the (2)title screen processing.
#==============================================================================
###############
# Module Cache#
###############
module Cache
  def self.title_new(filename)
    load_bitmap("Graphics/Title/", filename)
  end
end
class Scene_Title < Scene_Base
  #--------------------------------------------------------------------------
  # * Main Processing
  #--------------------------------------------------------------------------
  def main
    if $BTEST                         # If battle test
      battle_test                     # Start battle test
    else                              # If normal play
      super                           # Usual main processing
    end
  end
  #--------------------------------------------------------------------------
  # * Start processing
  #--------------------------------------------------------------------------
  def start
    super
    load_database                     # Load database
    create_game_objects               # Create game objects
    #check_continue                    # Determine if continue is enabled
    Graphics.setDefaultWindow
    # Runs the intro if enabled, else jumps to menu
#~     if $TEST == true
#~       create_graphics         		    # Create (2)title graphic
#~       create_command_window             # Create command window
#~       play_title_music                  # Play (2)title screen music
#~     else
    $main_window_option_selected = false if $main_window_option_selected == nil

    #Todo: Remove auto new-game later
    command_new_game_lite
    #create_graphics

    #create_command_window             # Create command window
#~     end
  end
  #--------------------------------------------------------------------------
  # * Execute Transition
  #--------------------------------------------------------------------------
  def perform_transition
    Graphics.transition(20)
  end
  #--------------------------------------------------------------------------
  # * Post-Start Processing
  #--------------------------------------------------------------------------
  def post_start
    super
    #todo: Enable again
    #open_command_window
  end
  #--------------------------------------------------------------------------
  # * Pre-termination Processing
  #--------------------------------------------------------------------------
  def pre_terminate
    super
    #Todo: Enable again.
    #close_command_window
  end
  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  def terminate
    super
    #Todo: Enable again.
    #dispose_command_window
    #snapshot_for_background
    #dispose_title_graphic
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    return
    #Todo: Enable again.
    @command_window.update
    if Input.trigger?(PadConfig.decision)
      case @command_window.index
      when 0    #New game
        $main_window_option_selected = true
        command_new_game
      when 1    # Continue
        $main_window_option_selected = true
        command_continue
      when 2
        $main_window_option_selected = true
        command_options
      when 3    # Shutdown
        command_shutdown
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Load Database
  #--------------------------------------------------------------------------
  def load_database
    $data_actors        = load_data("Data/Actors.rvdata")
    $data_classes       = load_data("Data/Classes.rvdata")
    $data_skills        = load_data("Data/Skills.rvdata")
    $data_items         = load_data("Data/Items.rvdata")
    $data_weapons       = load_data("Data/Weapons.rvdata")
    $data_armors        = load_data("Data/Armors.rvdata")
    $data_enemies       = load_data("Data/Enemies.rvdata")
    $data_troops        = load_data("Data/Troops.rvdata")
    $data_states        = load_data("Data/States.rvdata")
    $data_animations    = load_data("Data/Animations.rvdata")
    $data_common_events = load_data("Data/CommonEvents.rvdata")
    $data_system        = load_data("Data/System.rvdata")
    $data_areas         = load_data("Data/Areas.rvdata")
    Sound.create_sounds
    #initialize_item_params
    initialize_weapon_params
    initialize_armor_params
    #initialize_enemy_params
  end
  #--------------------------------------------------------------------------
  # * Load Battle Test Database
  #--------------------------------------------------------------------------
  def load_bt_database
    $data_actors        = load_data("Data/BT_Actors.rvdata")
    $data_classes       = load_data("Data/BT_Classes.rvdata")
    $data_skills        = load_data("Data/BT_Skills.rvdata")
    $data_items         = load_data("Data/BT_Items.rvdata")
    $data_weapons       = load_data("Data/BT_Weapons.rvdata")
    $data_armors        = load_data("Data/BT_Armors.rvdata")
    $data_enemies       = load_data("Data/BT_Enemies.rvdata")
    $data_troops        = load_data("Data/BT_Troops.rvdata")
    $data_states        = load_data("Data/BT_States.rvdata")
    $data_animations    = load_data("Data/BT_Animations.rvdata")
    process_character_animations
    $data_common_events = load_data("Data/BT_CommonEvents.rvdata")
    $data_system        = load_data("Data/BT_System.rvdata")
  end
  def initialize_item_params
    for item in $data_items
      next if item.nil?
      item.setup_list_for_self
    end
  end
  def initialize_weapon_params
    for weapon in $data_weapons
      next if weapon.nil?
      weapon.setup_list_for_self
    end
  end
  def initialize_armor_params
    for armor in $data_armors
      next if armor.nil?
      armor.setup_list_for_self
    end
  end
  def initialize_enemy_params
    for enemy in $data_enemies
      next if enemy.nil?
      enemy.setup_list_for_self
    end
  end

  def process_character_animations
    $data_character_animations = {}
    for animation in $data_animations
      $data_character_animations[animation.id] = []
      for timing in animation.timings
        if timing.se.name == '0CHAR_DIR'
          $data_character_animations[animation.id].push [timing.frame, Coord.new(timing.color.red, timing.color.green)]
        end
      end
    end
  end

  #--------------------------------------------------------------------------
  # * Create Game Objects
  #--------------------------------------------------------------------------
  alias old_create_objects create_game_objects if
      self.methods.include?('create_game_objects')
  def create_game_objects
    old_create_objects if self.methods.include?('old_create_objects')
    $game_temp          = Game_Temp.new
    $game_message       = Game_Message.new
    $game_system        = Game_System.new
    $game_switches      = Game_Switches.new
    $game_variables     = Game_Variables.new
    $game_self_switches = Game_SelfSwitches.new
    $game_actors        = Game_Actors.new
    $game_party         = Game_Party.new
    $game_troop         = Game_Troop.new
    $game_map           = Game_Map.new
#~     $game_caterpillar   = Game_Caterpillar.new
    $game_player        = Game_Player.new
    $input_config       = Game_InputConfig.new
    $game_options       = Game_Options.new
    $game_index         = Game_Index.new
    $hotspot_container  = Hotspot_Manager.new
    $quests             = Pioneer_Book.new
    $v_maps             = V_Maps.new
    $map_extra_events   = {}
  end
  #--------------------------------------------------------------------------
  # * Determine if Continue is Enabled
  #--------------------------------------------------------------------------
  def check_continue
    @continue_enabled = (Dir.glob('Save*.rvdata').size > 0)
  end

  def skip_title_intro
    @sprite = Sprite.new
    @sprite.bitmap = Cache.system('Title')
  end
  
  def create_graphics
    @sprite = Sprite.new
    @sprite.bitmap = Cache.system('Title')
    @sprite.opacity = 0
    if $main_window_option_selected
      @sprite.opacity = 255
    end
    @company_logo = Sprite.new
    @company_logo.bitmap = Cache.system('Game_Logo')
    @company_logo.opacity = 0
#~     for i in 0...255
#~       @company_logo.opacity += 1
#~       Graphics.wait(1) if i % 5
#~     end
#~     @company_logo.visible = false
#~     @sprite.visible = true
  end

  #--------------------------------------------------------------------------
  # * Dispose of Title Graphic
  #--------------------------------------------------------------------------
  def dispose_title_graphic
    @company_logo.bitmap.dispose if @company_logo != nil
    @company_logo.dispose if @company_logo != nil
    @sprite.bitmap.dispose if @sprite != nil
    @sprite.dispose if @sprite != nil
  end
  #--------------------------------------------------------------------------
  # * Create Command Window
  #--------------------------------------------------------------------------
  def create_command_window
    s1 = Vocab::new_game
    s2 = Vocab::continue
    s3 = "Options"
    s4 = Vocab::shutdown
    @command_window = Window_Command.new(142, [s1, s2, s3, s4])
    @command_window.x = ($screen_width - @command_window.width) - 30
    @command_window.y = ($screen_height - @command_window.height) - 30
    w = @command_window.width
    @version_window = Window_Version.new($screen_width-184,4,180,60)
    @version_window.opacity = 0
    if @continue_enabled                    # If continue is enabled
      @command_window.index = 1             # Move cursor over command
    else                                    # If disabled
      @command_window.draw_item(1, false)   # Make command semi-transparent
    end
    @version_window.openness = 0
    @version_window.open
    @command_window.openness = 0
    @command_window.open
  end
  #--------------------------------------------------------------------------
  # * Dispose of Command Window
  #--------------------------------------------------------------------------
  def dispose_command_window
    @command_window.dispose unless @command_window.nil?
    @version_window.dispose unless @version_window.nil?
  end
  #--------------------------------------------------------------------------
  # * Open Command Window
  #--------------------------------------------------------------------------
  def open_command_window
    @command_window.open
    @version_window.open
    if $main_window_option_selected == false
      begin 
        @company_logo.opacity += 5
        Graphics.update
      end until @company_logo.opacity == 255
      
      cout = 0
      begin
        cout += 1
        Graphics.wait(1)
        Graphics.update
      end until cout == 20
      
      PHI::SE.menu_se(80,50)
      
      cout = 0
      begin
        cout += 1
        Graphics.wait(1)
        Graphics.update
      end until cout == 30
      
      begin
        @company_logo.opacity -= 5
        Graphics.update
      end until @company_logo.opacity == 0
      
      begin
        @sprite.opacity += 5
        Graphics.update
      end until @sprite.opacity == 255
      
      begin
        @command_window.update
        @version_window.update
        Graphics.update
      end until @command_window.openness == 255
      play_title_music                  # Play (2)title screen music
    else
      begin
        @command_window.update
        @version_window.update
        Graphics.update
      end until @command_window.openness == 255
      @sprite.opacity = 255
      play_title_music                  # Play (2)title screen music
    end

  end
  #--------------------------------------------------------------------------
  # * Close Command Window
  #--------------------------------------------------------------------------
  def close_command_window
    @command_window.close
    @version_window.close
    begin
      @command_window.update
      Graphics.update
    end until @command_window.openness == 0
    begin
      @version_window.update
      Graphics.update
    end until @version_window.openness == 0
  end
  #--------------------------------------------------------------------------
  # * Play Title Screen Music
  #--------------------------------------------------------------------------
  def play_title_music
    $data_system.title_bgm.play
    RPG::BGS.stop
    RPG::ME.stop
  end
  #--------------------------------------------------------------------------
  # * Check Player Start Location Existence
  #--------------------------------------------------------------------------
  def confirm_player_location
    if $data_system.start_map_id == 0
      print "Player start location not set."
      exit
    end
  end

  def command_new_game_lite
    confirm_player_location
    $game_party.setup_starting_members            # Initial party
    $game_map.setup($data_system.start_map_id)    # Initial map position
    $game_party.moveto($data_system.start_x, $data_system.start_y)
    $game_party.refresh
    $scene = Scene_Map.new
    $game_party.prepare_line
    $game_party.snap_line
    Graphics.frame_count = 0
    RPG::BGM.stop
    $game_map.autoplay
  end
  #--------------------------------------------------------------------------
  # * Command: New Game
  #--------------------------------------------------------------------------
  def command_new_game
    confirm_player_location
    Sound.play_decision
    $game_party.setup_starting_members            # Initial party
    $game_map.setup($data_system.start_map_id)    # Initial map position
    $game_party.moveto($data_system.start_x, $data_system.start_y)
    $game_party.refresh
    $scene = Scene_Map.new
    $game_party.prepare_line
    $game_party.snap_line
    RPG::BGM.fade(1500)
    close_command_window
    Graphics.fadeout(60)
    Graphics.wait(40)
    Graphics.frame_count = 0
    RPG::BGM.stop
    $game_map.autoplay
  end
  #--------------------------------------------------------------------------
  # * Command: Continue
  #--------------------------------------------------------------------------
  def command_continue
    if @continue_enabled
      Sound.play_decision
      $scene = Scene_File.new(false, true, false)
    else
      Sound.play_buzzer
    end
  end
  
  def command_options
    Sound.play_decision
    $scene = Scene_Title_Options.new
  end
  #--------------------------------------------------------------------------
  # * Command: Shutdown
  #--------------------------------------------------------------------------
  def command_shutdown
    Sound.play_decision
    RPG::BGM.fade(800)
    RPG::BGS.fade(800)
    RPG::ME.fade(800)
    $scene = nil
  end
  #--------------------------------------------------------------------------
  # * Battle Test
  #--------------------------------------------------------------------------
  def battle_test
    load_bt_database                  # Load battle test database
    create_game_objects               # Create game objects
    Graphics.frame_count = 0          # Initialize play time
    $game_party.setup_battle_test_members
    $game_troop.setup($data_system.test_troop_id)
    $game_troop.can_escape = true
    $game_system.battle_bgm.play
    snapshot_for_background
    $scene = Scene_Battle.new
  end
end
class Title_Option_Controller < Window_Selectable
  
  def initialize(x,y,width,height)
    super(x,y,width,height)
    @column_max = 2
    self.index = 0
    @fullscreen = ["Disable", "Enable"]
    refresh
  end
  
  def refresh
    create_contents
    @item_max = @fullscreen.size
    for i in 0...@item_max
      rect = item_rect(i)
      self.contents.draw_text(rect,"#{@fullscreen[i]}")
    end
  end
  
end

class Title_Option_Background < Window_Base
  
  def initialize(x,y,width,height)
    super(x,y,width,height)
    refresh
  end
  
  def refresh
    self.contents.font.color = system_color
    self.contents.draw_text(0,10,width,WLH, "Xbox Controller:")
  end
  
end

class Title_Option_Header < Window_Base
  
  def initialize(x,y,width,height)
    super(x,y,width,height)
    self.contents.draw_text(0,0,width,WLH,"Menu Options:")
  end
  
end

class Scene_Title_Options < Scene_Base
  
  def start
    super
    @header = Title_Option_Header.new(0,0,$screen_width,60)
    
    @background = Title_Option_Background.new(0,60,$screen_width,$screen_height-60)
    
    @controller_enable = Title_Option_Controller.new(140,70,$screen_width/2,60)
    @controller_enable.active = false
    @controller_enable.opacity = 0
    @controller_enable.index = $use_controller
    @controller_enable.active = true
    
  end
  
  def terminate
    super
    @header.dispose
    @background.dispose
    @controller_enable.dispose
  end
  
  def update
    @controller_enable.update
    if @controller_enable.active
      update_controller_selection
    end
  end
  
  def return_scene
    $scene = Scene_Title.new
  end
  
  def update_controller_selection
    if Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      return_scene
    elsif Input.trigger?(PadConfig.decision)
      if @controller_enable.index != $use_controller
        Sound.play_equip
        $use_controller = @controller_enable.index
        $system.save_config
      else
        Sound.play_buzzer
      end
    end
  end
    
end