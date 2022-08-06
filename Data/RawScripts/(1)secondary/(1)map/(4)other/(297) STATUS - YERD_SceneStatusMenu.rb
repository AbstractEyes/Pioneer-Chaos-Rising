#~ #===============================================================================
#~ #
#~ # Yanfly Engine RD - Scene Status ReDux
#~ # Last Date Updated: 2009.05.26
#~ # Level: Normal, Hard, Lunatic
#~ # 
#~ # There's not a whole lot of reason for the player to visit the status menu.
#~ # Not too much to see aside from things you can already view in other menus
#~ # such as the equipment menu for stats. This script will provide additional
#~ # functionality to the scene in addition to allowing the game maker to free
#~ # up additional space in the main menu for the not actor-oriented stuff.
#~ #
#~ #===============================================================================
#~ # Updates:
#~ # ----------------------------------------------------------------------------
#~ # o 2009.05.26 - Started script and finished.
#~ #===============================================================================
#~ # Instructions
#~ #===============================================================================
#~ #
#~ # This script is plug and play for the most part, but there's bound to be a lot
#~ # things you may want to modify so scroll down and reach each of the individual
#~ # instructions carefully for all sections and modify the constants properly.
#~ #
#~ #===============================================================================
#~ #
#~ # Compatibility
#~ # - Works With: KGC scripts and others!
#~ # - Alias: Scene_Equip: return_scene
#~ # - Alias: Scene_Skill: return_scene
#~ # - Alias: Scene_Title: create_game_objects
#~ # - Alias: Game_Temp: initialize
#~ # - Overwrites: Scene_Status: all
#~ #
#~ #===============================================================================

#~ $imported = {} if $imported == nil
#~ $imported["SceneStatusReDux"] = true

#~ module YE
#~   module REDUX
#~     module STATUS
#~       
#~       #------------------------------------------------------------------------
#~       # Instructions on how to set up the STATUS_COMMANDS order.
#~       #------------------------------------------------------------------------
#~       # This array will let you determine how you want your status window
#~       # commands to be ordered. They will appear in the number you order them.
#~       # Each command is assigned a number and these are the following numbers.
#~       #
#~       #     0..Statistics    1..Biography    2..Skills    3..Equips
#~       #
#~       # The next couple are Yanfly Engine ReDux commands and require you to
#~       # have the respective scripts before they will appear in the menu. Be
#~       # sure to add them to STATUS_COMMANDS if you wish to display them.
#~       # 
#~       #     4..Change Class .......... Requires Subclass Selection System
#~       #     5..Learn Skills .......... Requires Subclass Selection System
#~       #     6..Skill Slots ........... Requires Equip Skill Slots
#~       #
#~       # There are some pre-made imported functions for this script. Of them are
#~       # the popular and powerful KGC scripts and others which I've also found
#~       # to be rather interesting.
#~       #
#~       #   101..Distribute Parameter .. Requires KGC Distribute Parameter
#~       #   102..Equip Learn Skill ..... Requires KGC Equip Learn Skill
#~       #   103..Skill CP System ....... Requires KGC Skill CP System
#~       #   201..Skill Growth .......... Requires Garlyle's Skill Growth System
#~       #   301..Attributes ............ Requires 332211's Attribute System
#~       #   302..Soul Pieces ........... Requires 332211's Soul Pieces System
#~       #   303..Weapon by Ranks ....... Requires 332211's Weapon by Ranks System
#~       #
#~       # If you wish to add your own commands, you'll need to register them
#~       # under the lunatic mode portion of the script.
#~       #------------------------------------------------------------------------
#~       STATUS_COMMANDS =[ # Make sure you've read the instructions above.
#~           # Statistics
#~       ] # Do not remove this.
#~       
#~       # The constants below will determine the unique sound and strings made
#~       # specificly for the Scene Status ReDux script.
#~       SOUND    = (0X)RPG.rb::SE.new("Book", 80, 100)
#~       STATUS   = "Status"
#~       BIO      = ""
#~       
#~       # The following determines determines profile categories for various
#~       # profile information.
#~       BIRTHDAY = ""
#~       AGE      = ""
#~       ORIGIN   = ""
#~       GENDER   = ""
#~       HEIGHT   = ""
#~       WEIGHT   = ""
#~       UNKNOWN  = ""
#~       
#~       # This hash will let you determine what full names to give your
#~       # individual actors. Use %s to indicate where the (0X)RPG.rb name appears.
#~       ACTOR_PROFILES1 ={
#~       # Actor => [       Full Name,   Origin,   Gender, Height,   Weight]
#~             1 => [    "%s",           "",       "", "",  ""],
#~             2 => [    "%s",           "",        "", "", ""],
#~             3 => [    "%s",           "",        "", "",  ""],
#~             4 => [    "%s",           "",        "", "", ""],
#~       } # Do not remove this.
#~       
#~       # The following hash will determine the birthday information about the
#~       # actor. The VarID is what stores the birthday. Change the variable to
#~       # change the actor's age in the actual menu. The start age is what the
#~       # variable initially sets the actor's age to. The birthday is just the
#~       # date that the actor is born. Nothing else special about it.
#~       ACTOR_PROFILES2 ={
#~       # Actor => [ VarID, StartAge, Birthday]
#~             1 => [    0,       0, ""],

#~       } # Do not remove this.
#~       
#~       # This will determine the size of the font used for the biography window.
#~       BIO_FONT_SIZE = 20
#~       
#~       # This section will allow you to type out the actor biographies. To
#~       # cause a line break, use a | in the middle of the string. If the actors
#~       # do not have a biography here, it will show actor 0 instead. For that
#~       # reason, do NOT remove actor 0.
#~       ACTOR_BIOGRAPHIES ={
#~       # Actor => Biography
#~             0 => "UNKNOWN    UNKNOWN    UNKNOWN|UNKNOWN    UNKNOWN    UNKNOWN|UNKNOWN    UNKNOWN    UNKNOWN|UNKNOWN    UNKNOWN    UNKNOWN|UNKNOWN    UNKNOWN    UNKNOWN|UNKNOWN    UNKNOWN    UNKNOWN|UNKNOWN    UNKNOWN    UNKNOWN|UNKNOWN    UNKNOWN    UNKNOWN",

#~       } # Do not remove this.
#~       
#~       # The following sets the statistical information for your actors.
#~       # These are all of the information you'll see in the statistics window.
#~       ICON_LVL  = 1569           # Icon for level
#~       TEXT_LVL  = "Level"      # Text for level
#~       ICON_EXP  = 1899           # Icon for experience
#~       TEXT_EXP  = "EXP"        # Text for experience
#~       ICON_NEXT = 1915          # Icon for next level
#~       TEXT_NEXT = "Next"       # Text for next level
#~       
#~       ICON_HP   = 1745           # Icon for HP
#~       ICON_MP   = 1749         # Icon for MP
#~       
#~       ICON_ATK  = 1572            # Icon for ATK
#~       TEXT_ATK  = "ATK"        # Text for ATK
#~       ICON_DEF  = 1575           # Icon for DEF
#~       TEXT_DEF  = "DEF"        # Text for DEF
#~       ICON_SPI  = 1573           # Icon for SPI
#~       TEXT_SPI  = "SPI"        # Text for SPI
#~       ICON_AGI  = 1576           # Icon for AGI
#~       TEXT_AGI  = "AGI"        # Text for AGI
#~       
#~       ICON_HIT  = 1897          # Icon for HIT
#~       TEXT_HIT  = "HIT"        # Text for HIT
#~       SHOW_HIT  = true         # Display HIT?
#~       ICON_EVA  = 1903          # Icon for EVA
#~       TEXT_EVA  = "EVA"        # Text for EVA
#~       SHOW_EVA  = true         # Display EVA?
#~       ICON_CRI  = 1898          # Icon for CRI
#~       TEXT_CRI  = "CRI"        # Text for CRI
#~       SHOW_CRI  = true         # Display CRI?
#~       ICON_ODDS = 137          # Icon for ODDS
#~       TEXT_ODDS = "LUK"        # Text for ODDS
#~       SHOW_ODDS = false         # Display ODDS?
#~     
#~     end # STATUS
#~   end # REDUX
#~ end # YE

#~ #===============================================================================
#~ # How to Use: Lunatic Mode
#~ #===============================================================================
#~ # 
#~ # If you do not understand hashes, I -STRONGLY- recommend that you stay away
#~ # from this portion of the script as it affects the rest of the script if you
#~ # make a slight mistake.
#~ #
#~ # - First, under IMPORTED_COMMANDS, fill out the hash properly. You will have
#~ # to fill them out correctly given the categories.
#~ #
#~ #    Swch? - Does this command require a switch to be on in order to be shown?
#~ #     SwID - If the previous was true, this is the Switch ID needed to be on.
#~ #    Title - This is the text that appears on the status command window.
#~ #    Scene - This is the name of the scene you wish to load.
#~ #
#~ # - Given that you've done everything correctly, return to the top and adjust
#~ # the STATUS_COMMANDS array. Input number 101 or whatever number you've used
#~ # to determine the scene you wish to launch from the status menu.
#~ #
#~ # Note that if you exit the imported scenes, they will return to the main menu
#~ # rather than the status menu. It will remain that way until you edit those
#~ # scripts's respective return_scene definitions.
#~ #
#~ #===============================================================================

#~ module YE
#~ module REDUX
#~ module STATUS
#~       
#~   # The following hash will govern the way the status menu will treat
#~   # imported commands. If you do not follow the setup properly, do not
#~   # expect the script to function correctly.
#~   IMPORTED_COMMANDS ={
#~   # -ID => [Swch?, SwID, ----Title----, -----------Scene-----------]
#~     101 => [false,    0, "Level Up",    "Scene_DistributeParameter"],
#~     102 => [false,    0, "View AP",     "Scene_APViewer"],
#~     103 => [false,    0, "Skill CP",    "Scene_SetBattleSkill"],
#~     201 => [false,    0, "Grow Skill",  "Scene_SkillGrowth"],
#~     301 => [false,    0, "Attributes",  "Scene_Attributes"],
#~     302 => [false,    0, "Soul Pieces", "Scene_soulpieces"],
#~     303 => [false,    0, "Weapon Rank", "Scene_weapon_by_ranks"],
#~   } # Do not remove this.
#~       
#~ end # STATUS
#~ end # REDUX
#~ end # YE

#~ #===============================================================================
#~ # Editting anything past this point may potentially result in causing computer
#~ # damage, incontinence, explosion of user's head, coma, death, and/or halitosis.
#~ # Therefore, edit at your own risk.
#~ #===============================================================================

#~ #===============================================================================
#~ # Scene Status
#~ #===============================================================================

#~ class Scene_Status < Scene_Base
#~   
#~   #--------------------------------------------------------------------------
#~   # create command list
#~   # --- This portion creates the commands for the status window.
#~   #--------------------------------------------------------------------------
#~   def create_command_list
#~     commands = []
#~     index_list = {}
#~     YE::REDUX::STATUS::STATUS_COMMANDS.each_with_index { |c, i|
#~       case c
#~       when 0 # View Statistics
#~         index_list[:stats] = commands.size
#~         commands.push(YE::REDUX::STATUS::STATUS)
#~         
#~       when 1 # View Biography
#~         index_list[:bio] = commands.size
#~         commands.push(YE::REDUX::STATUS::BIO)
#~         
#~       when 2 # Skill Menu
#~         index_list[:skill] = commands.size
#~         commands.push(Vocab.skill)
#~         
#~       when 3 # Equipment
#~         index_list[:equip] = commands.size
#~         commands.push(Vocab.equip)
#~       
#~       when 4 # Change Class
#~         next unless $imported["SubclassSelectionSystem"]
#~         next unless $game_switches[YE::SUBCLASS::ENABLE_CLASS_CHANGE_SWITCH]
#~         index_list[:classchange] = commands.size
#~         commands.push(YE::SUBCLASS::MENU_CLASS_CHANGE_TITLE)
#~         
#~       when 5 # Learn Skill
#~         next unless $imported["SubclassSelectionSystem"]
#~         next unless $game_switches[YE::SUBCLASS::ENABLE_LEARN_SKILLS_SWITCH]
#~         index_list[:learnskill] = commands.size
#~         commands.push(YE::SUBCLASS::LEARN_SKILL_TITLE)
#~         
#~       when 6 # Skill Slots
#~         next unless $imported["EquipSkillSlots"]
#~         next unless $game_switches[YE::EQUIPSKILL::ENABLE_SLOTS_SWITCH]
#~         index_list[:equipskill] = commands.size
#~         commands.push(YE::EQUIPSKILL::MENU_TITLE)
#~         
#~       else
#~         command_array = YE::REDUX::STATUS::IMPORTED_COMMANDS
#~         next unless command_array.include?(c)
#~         command_array = command_array[c]
#~         next if command_array[0] and !$game_switches[command_array[1]]
#~         index_list[c] = commands.size
#~         commands.push(command_array[2])
#~         
#~       end
#~     } # Do not remove this.
#~     $game_temp.status_command_index = index_list
#~     return commands
#~   end # create_command_list
#~   
#~   #--------------------------------------------------------------------------
#~   # case_command_selection
#~   #--------------------------------------------------------------------------
#~ #  def case_command_selection(index)
#~ #    case index
#~ #    when $game_temp.status_command_index[:stats]
#~ #      YE::REDUX::STATUS::SOUND.play
#~ #      $game_temp.status_bio_flag = 0
#~ #      start_visible_windows
#~ #      
#~ #    when $game_temp.status_command_index[:bio]
#~ #      YE::REDUX::STATUS::SOUND.play
#~ #      $game_temp.status_bio_flag = 1
#~ #      start_visible_windows
#~ #    
#~ #    when $game_temp.status_command_index[:skill]
#~ #      Sound.play_decision
#~ #      $scene = Scene_Skill.new(@actor_index)
#~ #      
#~ #    when $game_temp.status_command_index[:equip]
#~ #      Sound.play_decision
#~ #      $scene = Scene_Equip.new(@actor_index)
#~ #      
#~ #    when $game_temp.status_command_index[:classchange]
#~ #      Sound.play_decision
#~ #      $scene = Scene_Class_Change.new(@actor_index)
#~ #      
#~ #    when $game_temp.status_command_index[:learnskill]
#~ #      Sound.play_decision
#~ #      $scene = Scene_Learn_Skill.new(@actor_index)
#~ #      
#~ #    when $game_temp.status_command_index[:equipskill]
#~ #      Sound.play_decision
#~ #      $scene = Scene_Equip_Skill.new(@actor_index)
#~ #      
#~ #    else
#~ #      return_check = true
#~ #      for key in $game_temp.status_command_index
#~ #        if $game_temp.status_command_index[key[0]] == index
#~ #          return_check = false
#~ #          found_key = key[0]
#~ #          break
#~ #        end
#~ #      end
#~ #      return if return_check
#~ #      Sound.play_decision
#~ #      command_array = YE::REDUX::STATUS::IMPORTED_COMMANDS[found_key]
#~ #      $scene = eval(command_array[3] + ".new(@actor_index)")
#~ #      
#~ #    end
#~ #  end # case_command_selection
#~   
#~   #--------------------------------------------------------------------------
#~   # overwrite initialize
#~   #--------------------------------------------------------------------------
#~   def initialize(actor_index = 0, menu_index = 0)
#~     @menu_index = menu_index
#~     $game_temp.status_menu_flag = true
#~     @actor_index = actor_index
#~     @actor = $game_party.members[@actor_index]
#~   end
#~   
#~   #--------------------------------------------------------------------------
#~   # overwrite start
#~   #--------------------------------------------------------------------------
#~   def start
#~     super
#~     create_menu_background
#~     @status_window = Window_Status.new(@actor)
#~     @status_mini_window = Window_Status_Mini.new(@actor)
#~     @status_bio_window = Window_Status_Bio.new(@actor)
#~     start_visible_windows
#~ #    create_command_window
#~   end
#~   
#~   #--------------------------------------------------------------------------
#~   # overwrite terminate
#~   #--------------------------------------------------------------------------
#~   def terminate
#~     super
#~     dispose_menu_background
#~ #    @command_window.dispose if @command_window != nil
#~     @status_window.dispose if @status_window != nil
#~     @status_mini_window.dispose if @status_mini_window != nil
#~     @status_bio_window.dispose if @status_bio_window != nil
#~   end
#~   
#~   #--------------------------------------------------------------------------
#~   # overwrite return scene
#~   #--------------------------------------------------------------------------
#~   def return_scene
#~     if $imported["CustomMenuCommand"] and 
#~     $game_temp.menu_command_index.has_key?(:status)
#~       $scene = Scene_Menu.new($game_temp.menu_command_index[:status])
#~     elsif $imported["CustomMenuCommand"]
#~       $scene = Scene_Map.new
#~     else
#~       $scene = Scene_Menu.new(3)
#~     end
#~     $game_temp.status_menu_flag = false
#~   end
#~   
#~   #--------------------------------------------------------------------------
#~   # overwrite next actor
#~   #--------------------------------------------------------------------------
#~   def next_actor
#~     @actor_index += 1
#~     @actor_index %= $game_party.members.size
#~     $scene = Scene_Status.new(@actor_index)
#~   end
#~   
#~   #--------------------------------------------------------------------------
#~   # overwrite prev actor
#~   #--------------------------------------------------------------------------
#~   def prev_actor
#~     @actor_index += $game_party.members.size - 1
#~     @actor_index %= $game_party.members.size
#~     $scene = Scene_Status.new(@actor_index)
#~   end
#~   
#~   #--------------------------------------------------------------------------
#~   # overwrite update
#~   #--------------------------------------------------------------------------
#~   def update
#~     super
#~     update_menu_background
#~ #    @command_window.update
#~     if Input.trigger?(Input.B)
#~       Sound.play_cancel
#~       return_scene
#~     elsif Input.trigger?(Input.C)
#~       $game_temp.status_menu_index = @command_window.index
#~ #      case_command_selection(@command_window.index)
#~     elsif Input.trigger?(Input.R)
#~       Sound.play_cursor
#~       next_actor
#~     elsif Input.trigger?(Input.L)
#~       Sound.play_cursor
#~       prev_actor
#~     end
#~   end
#~   
#~   #--------------------------------------------------------------------------
#~   # create command window
#~   #--------------------------------------------------------------------------
#~ #  def create_command_window
#~ #    commands = create_command_list
#~ #    @command_window = Window_Command.new(160, commands)
#~ #    @command_window.y = 128
#~ #    @command_window.height = 288
#~ #    @command_window.opacity = 0
#~ #    @command_window.index = @menu_index
#~ #  end
#~   
#~   #--------------------------------------------------------------------------
#~   # start visible windows
#~   #--------------------------------------------------------------------------
#~   def start_visible_windows
#~     @status_mini_window.visible = false
#~     @status_bio_window.visible = false
#~     case $game_temp.status_bio_flag
#~     when 0
#~       @status_mini_window.visible = true
#~     when 1
#~       @status_bio_window.visible = true
#~     end
#~   end
#~   
#~ end

#~ #==============================================================================
#~ # Game_Temp
#~ #==============================================================================

#~ class Game_Temp
#~   
#~   #--------------------------------------------------------------------------
#~   # Public Instance Variables
#~   #--------------------------------------------------------------------------
#~ #  attr_accessor :status_command_index
#~   attr_accessor :status_menu_flag
#~   attr_accessor :status_menu_index
#~   attr_accessor :status_bio_flag
#~   
#~   #--------------------------------------------------------------------------
#~   # alias initialize
#~   #--------------------------------------------------------------------------
#~   alias initialize_statusrd initialize unless $@
#~   def initialize
#~     initialize_statusrd
#~ #    @status_command_index = {}
#~     @status_menu_flag = false
#~     @status_menu_index = 0
#~     @status_bio_flag = 0
#~   end
#~ end

#~ #===============================================================================
#~ # Scene Title
#~ #===============================================================================

#~ class Scene_Title < Scene_Base
#~   
#~   #--------------------------------------------------------------------------
#~   # alias create game objects
#~   #--------------------------------------------------------------------------
#~   alias create_game_objects_statusrd create_game_objects unless $@
#~   def create_game_objects
#~     create_game_objects_statusrd
#~     for key in YE::REDUX::STATUS::ACTOR_PROFILES2
#~       narray = key[1]
#~       $game_variables[narray[0]] = narray[1]
#~     end
#~   end
#~   
#~ end # Scene_Title

#~ #===============================================================================
#~ # return scene alias
#~ #===============================================================================
#~ unless $imported["SceneSkillReDux"]
#~ class Scene_Skill < Scene_Base
#~   
#~   #--------------------------------------------------------------------------
#~   # alias return scene
#~   #--------------------------------------------------------------------------
#~   alias skill_return_scene_statusrd return_scene unless $@
#~   def return_scene
#~     if $game_temp.status_menu_flag
#~       $scene = Scene_Status.new(@actor_index, $game_temp.status_menu_index)
#~     else
#~       skill_return_scene_statusrd
#~     end
#~   end
#~   
#~ end
#~ end
#~ unless $imported["SceneEquipReDux"]
#~ class Scene_Equip < Scene_Base
#~   
#~   #--------------------------------------------------------------------------
#~   # alias return scene
#~   #--------------------------------------------------------------------------
#~   alias equip_return_scene_statusrd return_scene unless $@
#~   def return_scene
#~     if $game_temp.status_menu_flag
#~       $scene = Scene_Status.new(@actor_index, $game_temp.status_menu_index)
#~     else
#~       equip_return_scene_statusrd
#~     end
#~   end
#~   
#~ end
#~ end

#~ #===============================================================================
#~ # Window_Status
#~ #===============================================================================

#~ class Window_Status < Window_Base
#~   
#~   #--------------------------------------------------------------------------
#~   # initialize
#~   #--------------------------------------------------------------------------
#~   def initialize(actor)
#~     super(0, 0, 544, 416)
#~     @actor = actor
#~     refresh
#~   end
#~   
#~   #--------------------------------------------------------------------------
#~   # refresh
#~   #--------------------------------------------------------------------------
#~   def refresh
#~     self.contents.clear
#~     draw_actor_face(@actor, 0, 0)
#~     profile1 = YE::REDUX::STATUS::ACTOR_PROFILES1
#~     profile2 = YE::REDUX::STATUS::ACTOR_PROFILES2
#~     if profile1.include?(@actor.id)
#~       text = sprintf(profile1[@actor.id][0], @actor.name)
#~     else
#~       text = @actor.name
#~     end
#~     self.contents.draw_text(112, 0, 180, WLH, text, 0)
#~     #----
#~     dx = 112
#~     if $imported["SubclassSelectionSystem"]
#~       if YE::SUBCLASS::CLASS_ICONS.include?(@actor.class.id)
#~         icon = YE::SUBCLASS::CLASS_ICONS[@actor.class.id]
#~       else
#~         icon = YE::SUBCLASS::CLASS_ICONS[0]
#~       end
#~       draw_icon(icon, dx, 24)
#~       dx += 24
#~       if @actor.subclass != nil
#~         if YE::SUBCLASS::CLASS_ICONS.include?(@actor.subclass.id)
#~           icon = YE::SUBCLASS::CLASS_ICONS[@actor.subclass.id]
#~         else
#~           icon = YE::SUBCLASS::CLASS_ICONS[0]
#~         end
#~         draw_icon(icon, dx, 24)
#~         dx += 24
#~       end
#~     end
#~     draw_actor_class(@actor, dx, 24)
#~     #----
#~     self.contents.font.color = system_color
#~     text1 = YE::REDUX::STATUS::BIRTHDAY
#~     text2 = YE::REDUX::STATUS::AGE
#~     self.contents.draw_text(20, 48, 90, WLH, "", 2)
#~     self.contents.draw_text(20, 72, 90, WLH, "", 2)
#~     if profile2.include?(@actor.id)
#~       text1 = profile2[@actor.id][2]
#~       text2 = $game_variables[profile2[@actor.id][0]]
#~     else
#~       text1 = YE::REDUX::STATUS::UNKNOWN
#~       text2 = YE::REDUX::STATUS::UNKNOWN
#~     end
#~     self.contents.font.color = normal_color
#~     self.contents.draw_text(20, 48, 90, WLH, "", 0)
#~     self.contents.draw_text(20, 72, 90, WLH, "", 0)
#~     #----
#~     self.contents.font.color = system_color
#~     text1 = YE::REDUX::STATUS::ORIGIN
#~     text2 = YE::REDUX::STATUS::GENDER
#~     text3 = YE::REDUX::STATUS::HEIGHT
#~     text4 = YE::REDUX::STATUS::WEIGHT
#~     self.contents.draw_text(20,  0, 90, WLH, "", 2)
#~     self.contents.draw_text(20, 24, 90, WLH, "", 2)
#~     self.contents.draw_text(20, 48, 90, WLH, "", 2)
#~     self.contents.draw_text(20, 72, 90, WLH, "", 2)
#~     if profile1.include?(@actor.id)
#~       text1 = profile1[@actor.id][1]
#~       text2 = profile1[@actor.id][2]
#~       text3 = profile1[@actor.id][3]
#~       text4 = profile1[@actor.id][4]
#~     else
#~       text1 = YE::REDUX::STATUS::UNKNOWN
#~       text2 = YE::REDUX::STATUS::UNKNOWN
#~       text3 = YE::REDUX::STATUS::UNKNOWN
#~       text4 = YE::REDUX::STATUS::UNKNOWN
#~     end
#~     self.contents.font.color = normal_color
#~     self.contents.draw_text(20,  0, 90, WLH, "", 0)
#~     self.contents.draw_text(20, 24, 90, WLH, "", 0)
#~     self.contents.draw_text(20, 48, 90, WLH, "", 0)
#~     self.contents.draw_text(20, 72, 90, WLH, "", 0)
#~     #----
#~   end
#~   
#~ end # Window_Status

#~ #==============================================================================
#~ # Window_Status_Mini
#~ #==============================================================================

#~ class Window_Status_Mini < Window_Base
#~   
#~   #--------------------------------------------------------------------------
#~   # initialize
#~   #--------------------------------------------------------------------------
#~   def initialize(actor)
#~     super(10, 128, 384, 288)
#~     @actor = actor
#~     self.opacity = 0
#~     self.visible = false
#~     refresh
#~   end
#~   
#~   #--------------------------------------------------------------------------
#~   # refresh
#~   #--------------------------------------------------------------------------
#~   def refresh
#~     self.contents.clear
#~     self.contents.font.color = system_color
#~     #---
#~     sw = self.width - 32
#~     dx = 0
#~     dy = 0
#~     draw_icon(YE::REDUX::STATUS::ICON_LVL, dx, dy)
#~     self.contents.draw_text(dx+24, dy, 60, WLH, YE::REDUX::STATUS::TEXT_LVL)
#~     
#~     dy += WLH
#~     draw_icon(YE::REDUX::STATUS::ICON_NEXT, dx, dy)
#~     self.contents.draw_text(dx+24, dy, 60, WLH, YE::REDUX::STATUS::TEXT_NEXT)
#~     dy += WLH
#~     draw_icon(YE::REDUX::STATUS::ICON_EXP, dx, dy)
#~     self.contents.draw_text(dx+24, dy, 60, WLH, YE::REDUX::STATUS::TEXT_EXP)
#~     
#~     dy = WLH * 3
#~     draw_icon(YE::REDUX::STATUS::ICON_HP, dx, dy)
#~     draw_actor_hp(@actor, dx+24, dy, 128)
#~     dy += WLH
#~     self.contents.font.color = system_color
#~     draw_icon(YE::REDUX::STATUS::ICON_ATK, dx, dy)
#~     self.contents.draw_text(dx+24, dy, 60, WLH, YE::REDUX::STATUS::TEXT_ATK)
#~     dy += WLH
#~     draw_icon(YE::REDUX::STATUS::ICON_DEF, dx, dy)
#~     self.contents.draw_text(dx+24, dy, 60, WLH, YE::REDUX::STATUS::TEXT_DEF)
#~     dy += WLH
#~     draw_icon(YE::REDUX::STATUS::ICON_SPI, dx, dy)
#~     self.contents.draw_text(dx+24, dy, 60, WLH, YE::REDUX::STATUS::TEXT_SPI)
#~     dy += WLH
#~     draw_icon(YE::REDUX::STATUS::ICON_AGI, dx, dy)
#~     self.contents.draw_text(dx+24, dy, 60, WLH, YE::REDUX::STATUS::TEXT_AGI)
#~     #---
#~     dx = sw/2
#~     dy = WLH * 3
#~     draw_icon(YE::REDUX::STATUS::ICON_MP, dx, dy)
#~     draw_actor_mp(@actor, dx+24, dy, 128)
#~     dy += WLH
#~     self.contents.font.color = system_color
#~     if YE::REDUX::STATUS::SHOW_HIT
#~       draw_icon(YE::REDUX::STATUS::ICON_HIT, dx, dy)
#~       self.contents.draw_text(dx+24, dy, 60, WLH, YE::REDUX::STATUS::TEXT_HIT)
#~     end
#~     dy += WLH
#~     if YE::REDUX::STATUS::SHOW_EVA
#~       draw_icon(YE::REDUX::STATUS::ICON_EVA, dx, dy)
#~       self.contents.draw_text(dx+24, dy, 60, WLH, YE::REDUX::STATUS::TEXT_EVA)
#~     end
#~     dy += WLH
#~     if YE::REDUX::STATUS::SHOW_CRI
#~       draw_icon(YE::REDUX::STATUS::ICON_CRI, dx, dy)
#~       self.contents.draw_text(dx+24, dy, 60, WLH, YE::REDUX::STATUS::TEXT_CRI)
#~     end
#~     dy += WLH
#~     if YE::REDUX::STATUS::SHOW_ODDS
#~       draw_icon(YE::REDUX::STATUS::ICON_ODDS, dx, dy)
#~       self.contents.draw_text(dx+24, dy, 60, WLH, YE::REDUX::STATUS::TEXT_ODDS)
#~     end
#~     #---
#~     self.contents.font.color = normal_color
#~     dw = sw - 84
#~     dx = 84
#~     dy = 0
#~     self.contents.draw_text(dx, dy, 68, WLH, @actor.level); dy += WLH
#~     self.contents.draw_text(dx, dy, dw, WLH, @actor.next_rest_exp_s); dy += WLH
#~     self.contents.draw_text(dx, dy, dw, WLH, @actor.exp_s); dy += WLH
#~     
#~     dy = WLH * 4
#~     self.contents.draw_text(dx, dy, 68, WLH, @actor.atk, 0); dy += WLH
#~     self.contents.draw_text(dx, dy, 68, WLH, @actor.def, 0); dy += WLH
#~     self.contents.draw_text(dx, dy, 68, WLH, @actor.spi, 0); dy += WLH
#~     self.contents.draw_text(dx, dy, 68, WLH, @actor.agi, 0); dy += WLH
#~     dy = WLH * 4
#~     dx = sw/2 + 84
#~     if YE::REDUX::STATUS::SHOW_HIT
#~       text = sprintf("%d%%", @actor.hit)
#~       self.contents.draw_text(dx, dy, 68, WLH, text, 0)
#~     end; dy += WLH
#~     if YE::REDUX::STATUS::SHOW_EVA
#~       text = sprintf("%d%%", @actor.eva)
#~       self.contents.draw_text(dx, dy, 68, WLH, text, 0)
#~     end; dy += WLH
#~     if YE::REDUX::STATUS::SHOW_CRI
#~       text = sprintf("%d%%", @actor.cri)
#~       self.contents.draw_text(dx, dy, 68, WLH, text, 0)
#~     end; dy += WLH
#~     if YE::REDUX::STATUS::SHOW_ODDS
#~       self.contents.draw_text(dx, dy, 68, WLH, @actor.odds, 0)
#~     end; dy += WLH
#~   end
#~   
#~ end # Window_Status_Mini

#~ #==============================================================================
#~ # Window_Status_Bio
#~ #==============================================================================

#~ class Window_Status_Bio < Window_Base
#~   
#~   #--------------------------------------------------------------------------
#~   # initialize
#~   #--------------------------------------------------------------------------
#~   def initialize(actor)
#~     super(160, 128, 384, 288)
#~     @actor = actor
#~     self.opacity = 0
#~     refresh
#~   end
#~   
#~   #--------------------------------------------------------------------------
#~   # refresh
#~   #--------------------------------------------------------------------------
#~   def refresh
#~     self.contents.clear
#~     self.contents.font.color = normal_color
#~     self.contents.font.size = YE::REDUX::STATUS::BIO_FONT_SIZE
#~     if YE::REDUX::STATUS::ACTOR_BIOGRAPHIES.include?(@actor.id)
#~       text = YE::REDUX::STATUS::ACTOR_BIOGRAPHIES[@actor.id]
#~     else
#~       text = YE::REDUX::STATUS::ACTOR_BIOGRAPHIES[0]
#~     end
#~     y = 0
#~     txsize = YE::REDUX::STATUS::BIO_FONT_SIZE + 4
#~     nwidth = 544
#~     buf = text.gsub(/\\N(\[\d+\])/i) { "\\__#{$1}" }
#~     lines = buf.split(/(?:[|]|\\n)/i)
#~     lines.each_with_index { |l, i|
#~       l.gsub!(/\\__(\[\d+\])/i) { "\\N#{$1}" }
#~       self.contents.draw_text(0, i * txsize + y, nwidth, WLH, l, 0)
#~     }
#~   end
#~   
#~ end # Window_Status_Bio

#~ #===============================================================================
#~ #
#~ # END OF FILE
#~ #
#~ #===============================================================================