#==============================================================================
# ** Scene_Map_Battle
#------------------------------------------------------------------------------
#  This class performs the map screen and battle processing.
#==============================================================================
#$scene = Scene_Map.new
class Scene_Map < Scene_Base
  attr_accessor :spriteset
  attr_accessor :animations
  attr_accessor :levelup_display

  ##############################################################################
  # Scene Creation methods.
  ##############################################################################
  def start
    super
    $game_map.refresh

    @spriteset = Spriteset_Map.new
    #draw_test_line
    @message_window = Window_Message.new

    # Battle Viewport for animations and characters
    @battle_viewport = Viewport.new(0,0,$screen_width,$screen_height)

    # Battler data display, visible during battle,
    #    falls away when not in battle.
    @party_display = Window_BattlerParty.new(0,0,140,$screen_height)
    # Battler action macro window array.
    @macro_display = Window_BattlerMacros.new(40,$screen_height-48,32+16,64)
    # Holds all messages for the message history.
    @message_scroll = Window_MessageScroll.new($screen_width-102,106,102,140)
    # Contains the target information and targets for an actor attack.
    @target_window = Window_Target.new(0,0,$screen_width,$screen_height)
    # Skill icon selection
    @skill_window = Window_SkillIcons.new(80,$screen_height-72,70,120)
    @skill_window.z = @target_window.z + 1
    @tiled_party = Window_TiledParty.new(0,0,160,160)
    @tiled_party.z = @skill_window.z + 1
    # Popup messages.
    @messages = []
    # Dynamic animations.
    @animations = []

    # Battle threat, if threat is active, the threat flag is active.  No reason to check anything but this.
    $game_temp.battle_threat = false
    $game_temp.battle_spotted = false
    $game_temp.in_battle = false

    #@shape_manager = Shape_Manager.new

    # Contains a list of player id's that leveled up during battle.
    @levelup_queue = []
    @battle_exp = 0
    @battle_kills = 0
  end

  ##############################################################################
  # When the scene terminates, this sequence runs.
  def terminate
    super
    p "Terminated"
    snapshot_for_background
    @party_display.dispose
    @macro_display.dispose
    @spriteset.dispose
    @message_window.dispose
    @message_scroll.dispose
    @target_window.dispose
    @tiled_party.dispose
    dispose_popups
    @animations.each { |a| a.dispose }
    @animations.clear
    @skill_window.dispose
    ($game_party.troop + $game_troop.troop).each { |t| next if t.battler.nil?; t.battler.action.clear; }
    GC.start
  end

  # Branch to terminate, to dispose of all message popups.
  # Proper cleanup.
  def dispose_popups
    unless @messages.empty?
      @messages.each do |message|; message.dispose unless message.nil?; end
      @messages.clear
    end
  end
  ##############################################################################
  # The main update loop, highly important attention to detail
  # is required for any modification to the main update loop.
  def update
    super
    @party_display.update
    @macro_display.update
    @message_window.update
    @message_scroll.update
    # ONLY IF battle has already started, will this be used.
    if ($game_temp.battle_threat && $game_temp.battle_spotted) || $game_temp.in_battle
      @target_window.update
      @skill_window.update
      @tiled_party.update
      full_battle_update
    else
      full_map_update
    end
  end

  def full_map_update
    # Battle has not started, thus this is the only update to be used.
    update_map                    # Updates the basic updates for the map and sprites.
    update_threat_check           # Sets the threat bool.
    update_message_popups         # Updates the message queue.
    update_transfer_player        # Updates the transfer.
    update_call_menu              # Opens the menu
    update_call_debug             # Opens the debug scene
    update_scene_change           # Changes the scene if the new scene isn't the same as this.
    update_common_inputs          # Updates the add-on inputs.
  end

  def update_threat_check
    $game_temp.battle_threat = $game_party.any_alive_enemy_in_range?
    $game_temp.battle_spotted = $game_party.any_alive_enemy_spotted?
  end

  def full_battle_update
    # If one of the many battle interfaces are active, update that interface.
    if $game_temp.battle_threat && $game_temp.battle_spotted && !$game_temp.in_battle
      battle_startup_sequence
    elsif !$game_temp.battle_threat && $game_temp.in_battle
      battle_end_sequence
      return
    end
    if @macro_display.active
      # Updates the macro window inputs.
      #@spriteset.update
      update_member_macro_inputs
    elsif @skill_window.active
      # Updates the inputs for the skill icon window.
      update_skill_window_inputs
    elsif @target_window.active
      # Updates the target window inputs.
      #@spriteset.update
      update_target_window_inputs
    elsif @macro_display.battle_movement?
      # If the battler is moving
      # Update triggers to remove the movement.
      update_battle_movement_inputs
      update_battle_idle
    elsif @macro_display.has_ready_member?
      # Display has member, display is not active, and display battler movement not enabled.
      refresh_and_display_macros
    else
      # If the battler isn't moving, and none of the other triggers are satisfied.
      update_battle_idle
    end
  end

  def update_battle_idle
    update_map
    update_threat_check             # Sets the threat bool.
    update_message_popups
  end

  def update_basic
    Graphics.update                   # Update game screen
    Input.update                      # Update input information
    @spriteset.update                 # Update sprite set
    update_message_popups
  end

  def update_map
    $game_map.interpreter.update      # Update interpreter
    $game_map.update                  # Update map
    $game_party.update                # Update player sprites and movement
    $game_system.update               # Update timer
    @spriteset.update
  end

  # Update directly for messages.
  def update_message_popups
    #todo: prepare interpreter messages inside the item event.
    $interpreter_messages = [] if $interpreter_messages.nil?
    if !$interpreter_messages.empty?
      @messages += $interpreter_messages
      $interpreter_messages.clear
    end
    for i in 0...@messages.size
      message = @messages[i]
      next if message.nil?
      if message.executing
        #perform_message_event(message.events)
        @messages[i].dispose
        @messages[i] = nil
      else
        @messages[i].update
        if message.halt?
          update_basic
        end
      end
    end
    @messages.compact! if @messages.include?(nil)
  end

  ##############################################################################
  # Scene Input Update methods.
  #     Used for direct scene control by input use.
  #     These are directly tied to the sub menus attached to the screen,
  #     $game_map cannot be updating during these.
  ##############################################################################
  # Step 1:  The fork between inputs for the hud overlay
  #          and battle trigger methods.
  def update_common_inputs
    if Input.trigger?(PadConfig.hud)
      $scene = Enchant_Scene.new
      #@party_display.animate_hide if @party_display.visible
      #@party_display.animate_show unless @party_display.visible
      #finish_hiding

      #@message_scroll.visible = !@message_scroll.visible
      #if !@message_scroll.visible
        #unlock_displays

      #elsif @message_scroll.visible
        #show_member_displays
      #end
    end
  end

  ##############################################################################
  # Step 2:  The active battler icons are visible, and thus
  #          the macro overlay is visible.
  def update_member_macro_inputs
    if Input.trigger?(PadConfig.decision)
      Sound.play_decision
      case @macro_display.macro_key
        when :offensive_skills
          p "offensive skills"
          show_skill_icons
          @macro_display.active = false
          @macro_display.update
          #@party_display.animate_hide
          #finish_hiding
        when :defensive_skills
          p "defensive skills"
          show_armor_icons
          @macro_display.active = false
          @macro_display.update
          #@party_display.animate_hide
          #finish_hiding
        when :use_item
          p "Item"
          show_item_icons
          @macro_display.active = false
          @macro_display.update
        when :move
          p "Move"
          hide_macro_display
          @tiled_party.visible = false
          @macro_display.set_movement
          @party_display.animate_show
        else
          p "Issues are present that must be addressed."
          p @macro_display.macro_key.inspect
      end
    elsif Input.trigger?(PadConfig.up)
      # Next battler in list.
    elsif Input.trigger?(PadConfig.down)
      # Last battler in list.
    elsif Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      @macro_display.clear_last_position
      open_macro_display
      #@macro_display.refresh
      #$game_index.bind(@macro_display.member.id)
      #@macro_display.next_active_position
      #@macro_display.refresh
    end
  end
  ##############################################################################
  # Step 3c:  Updates the inputs for the player skill selection.
  def update_skill_window_inputs
    if Input.trigger?(PadConfig.decision)
      Sound.play_decision
      hide_skill_icons
      @macro_display.active = false
      open_target_display
      @target_window.refresh(@macro_display.member, @skill_window.skill)
    elsif Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      hide_skill_icons
      open_macro_display
    elsif Input.trigger?(PadConfig.hud)
      Sound.play_equip
      @skill_window.switch_expand
    elsif Input.trigger?(PadConfig.page_down)
      Sound.play_equip
    elsif Input.trigger?(PadConfig.page_up)
      Sound.play_equip
    elsif Input.trigger?(PadConfig.up) or Input.trigger?(PadConfig.down)
      return if @skill_window.one_tree?
      Sound.play_cursor
      @skill_window.next_tree
    elsif Input.trigger?(PadConfig.left)
      Sound.play_cursor
      @skill_window.next
    elsif Input.trigger?(PadConfig.right)
      Sound.play_cursor
      @skill_window.last
    end
  end

  ##############################################################################
  # Step 3a:  The target window is open, and thus the inputs for the target
  #           window take priority over any of the other inputs.
  def update_target_window_inputs
    if Input.trigger?(PadConfig.decision)
      prepare_action
      close_target_display
      @macro_display.next_active_position
      @tiled_party.refresh
      if @macro_display.done?
        # Battle complete, start executing.
        hide_macro_display
        @tiled_party.visible = false
        @party_display.visible = true
        finish_hiding
        @party_display.animate_show
        Sound.play_decision
        finish_hiding
      else
        # Battle not complete, continue to next member.
        open_macro_display
        Sound.play_equip
      end
    elsif Input.trigger?(PadConfig.cancel)
      close_target_display
      @skill_window.one_tree? ? show_armor_icons : show_skill_icons
      Sound.play_cancel
    end
  end

  def update_battle_movement_inputs
    if Input.trigger?(PadConfig.decision) or
        Input.trigger?(PadConfig.cancel) or
        Input.trigger?(PadConfig.hud) or
        Input.trigger?(PadConfig.menu)
      open_macro_display
      $game_party.clear_battle_movement
      finish_moving
      @macro_display.next_active_position
      open_macro_display
      @party_display.animate_hide
      finish_hiding
      @tiled_party.visible = true
      @tiled_party.refresh
    end
  end

  ##############################################################################
  # Step 3b:  Updates the window for item selection, needs a simple custom
  #           window and window base.
  def update_item_window_inputs
  end

  def finish_moving
    while $game_party.any_player_moving?
      $game_party.update_players
      update_basic
    end
  end

  def battle_startup_sequence
    $game_temp.in_battle = true
    start_battle_bgm
    update_basic
    # Battle start.
    start_battle_message
    finish_moving
    finish_messages
    # Messages and pre-battle movement done, starting formation sequence.
    $game_party.break_line
    direction = PHI::Formation.dir_4($game_player.direction)
    PHI::Formation.prepare
    finish_moving
    $game_party.players.each_value { |p| p.direction = direction }
  end

  def refresh_and_display_macros
    p 'refresh and display macros'
    @party_display.animate_hide if @party_display.visible
    finish_hiding
    #Graphics.wait(1)
    Sound.play_equip
    @spriteset.update
    $game_map.snap_to_player($game_party.leader)
    @spriteset.update
    @macro_display.next_active_position
    open_macro_display
    @tiled_party.visible = true
    @tiled_party.refresh
    show_member_displays
  end

  def refresh_and_display_skills
    @skill_window.refresh(@macro_display.member)
  end

  def next_battle_order_sequence
    #Graphics.wait(1)
    $game_map.snap_to_player($game_party.leader)
    @spriteset.update
    open_macro_display
    show_member_displays
  end

  def battle_end_sequence
    update_basic
    dump_hud
    @spriteset.dump_battle
    $game_player.locked = true
    clear_all_actions
    $game_party.clear_battle_movement
    finish_messages
    wait_for_animation
    $game_party.halt_movement
    while $game_party.any_player_moving?
      $game_party.update_players
      update_basic
    end
    $game_party.active_snap_line($game_player.x, $game_player.y)
    $game_party.set_leader
    $game_party.reform_line
    end_battle_bgm
    finish_moving
    $game_player.locked = false
    $game_temp.in_battle = false
    @party_display.animate_show
    @party_display.update
  end

  def dump_hud
    #Remove active from all interfaces.
    @macro_display.active = false
    @macro_display.visible = false
    @party_display.index = -1
    @party_display.active = false
    @target_window.active = false
    @target_window.visible = false
    @skill_window.visible = false
  end

  ##############################################################################
  def set_target_window_skill
    @target_window.refresh(@macro_display.member)
    open_target_display
  end

  def finish_messages
    while !@messages.empty?
      update_basic
      update_message_popups
    end
  end

  def finish_hiding
    #while @party_display.animating?
    #  update_basic
    #  @party_display.update
    #end
  end

  def messages_finished?
    @messages.empty? ? true : false
  end

  ##############################################################################
  # Prepares the temp action for the queue.
  ##############################################################################
  # Step 4a: Updates the action queue for action traversal.
  def clear_all_actions
    for member in ($game_troop.members + $game_party.members)
      next if member.nil?
      next if member.action.nil?
      member.action.clear
    end
  end

  def prepare_action
    @macro_display.member.shape_manager.prepare(@target_window.target.character, @skill_window.skill)
    @macro_display.member.action.set_skill(@skill_window.tree, @skill_window.index)
  end

  def finish_action
    @macro_display.member.action.ready = true
  end

  def display_exp_reward(exp)
    text = PHI::Vocab::EXP + " +" + exp.to_s
    add_scroller(text)
    message = Window_MessagePopup.new(200,180,128,80)
    message.popup(text,0, nil, nil, nil, nil, PHI.color(:CYAN), rand(6)+1, rand(4)+1, 60, nil, 12)
    message.update
    message.z = get_message_z
    push_message(message)
  end

  def reward_exp(exp)
    return unless $scene.is_a?(Scene_Map)
    levels = $game_party.get_levels_and_ids
    $game_party.distribute_exp(exp)
    levels = $game_party.get_levelups(levels)
    for i in 0...levels.size
      up = levels[i]
      next unless $game_party.sorted_members[0...5].include?(up)
      $game_party.players[up].member.action.display_levelup_animations($game_party.players[up])
      display_levelup_message($game_party.players[up])
      @party_display.force_refresh
    end
  end

  def display_levelup_message(player)
    text = "Level Up"
    add_scroller(player.get_member.name + " " + text + " " + player.get_member.level.to_s)
    y_pos = $game_party.members.index(player.get_member) * $screen_height / 5
    message = Window_MessagePopup.new(12,y_pos,128,80)
    message.popup(text, 0, nil, nil, nil, nil, nil, nil, nil, 30)
    message.z = 5000
    message.update
    push_message(message)
  end

  ##############################################################################
  # Force test action function, used to test pieces of the actions.
  def force_test_action
  end
  #--------------------------------------------------------------------------
  # * Wait Until Animation Display has Finished
  #--------------------------------------------------------------------------
  def wait_for_animation
    while @spriteset.animation? #or !messages_finished?
      update_basic
    end
  end
  #--------------------------------------------------------------------------
  # * Show Normal Animation
  #     targets      : Target array
  #     animation_id : Animation ID
  #     mirror       : Flip horizontal
  #--------------------------------------------------------------------------
  def display_target_host_animation(target, animation_id, user, user_animation_id)
    # Damage splash animations.
    animation = $data_animations[animation_id]
    user_animation = $data_animations[user_animation_id]
    if animation != nil
      #to_screen = (animation.position == 3)       # Is the positon "screen"?
      target.battle_animations.push [animation_id, user.battler.__id__] unless target.battler.dead?
    end
    if user_animation != nil
      #to_screen = (animation.position == 3)       # Is the positon "screen"?
      user.battle_animations.push user_animation_id
    end
  end
  def display_target_animation(target, animation_id)
    animation = $data_animations[animation_id]
    target.battle_animations.push animation_id if animation != nil
  end
  ##############################################################################
  # Scene Window overlay modifiers.
  #   Used as modifiers for the scene, triggered by inputs and events.
  ##############################################################################
  def show_member_displays
    @party_display.visible = true
  end

  def dock_party_window
    @party_display.animate_hide
    finish_hiding
  end

  def undock_party_window
    @party_display.animate_show
  end

  def show_skill_icons
    @skill_window.refresh(@macro_display.member.get_skill_belt_pos(0), @macro_display.member.get_skill_belt_pos(1), @macro_display.member.get_skill_belt_pos(2), false)
    @skill_window.visible = true
    @skill_window.active = true
  end
  def show_armor_icons
    @skill_window.refresh(@macro_display.member.get_skill_belt_pos(0), @macro_display.member.get_skill_belt_pos(1), @macro_display.member.get_skill_belt_pos(2), true)
    @skill_window.visible = true
    @skill_window.active = true
  end
  def show_item_icons
    #
  end

  def hide_skill_icons
    @skill_window.visible = false
    @skill_window.active = false
  end

  def open_macro_display
    @tiled_party.refresh
    @macro_display.next_active_position
    @macro_display.refresh
    $game_index.bind(@macro_display.member.id)
    @macro_display.refresh
    @macro_display.visible = true
    @macro_display.active = true
  end
  def hide_macro_display
    @macro_display.visible = false
    @macro_display.active = false
  end

  ##############################################################################
  def open_target_display
    @target_window.visible = true
    @target_window.active = true
  end
  ##############################################################################
  def close_target_display
    @target_window.contents.clear
    @target_window.index = -1
    @target_window.visible = false
    @target_window.active = false
  end

  ##############################################################################
  # Scene Popup Messagebox custom methods.
  # @text = input string
  # @opacity = input integer, message box opacity
  # @x = input integer, x value of window position
  # @y = input integer, y value of window position
  # @width = input integer, width of the window
  # @height = input integer, height of the window
  # @color = Color, color class object for text color
  # @animate = integer, determines the direction of the window

  def snap_to_character(character)
    $game_map.snap_to_player(character)
  end

  #def display_attack_animation(target)
  # If guarded, make tink noise
  # If not guarded do normal attack damage sound.
  #end

  def start_battle_message
    text = "Threat spotted, formations!"
    add_scroller(text)
    message = Window_MessagePopup.new(120,120,128,80)
    message.popup(text,0, nil, nil, nil, nil, PHI.color(:RED, 200),nil, nil, 60)
    message.update
    message.z = get_message_z
    push_message(message)
    #Graphics.wait( 1)
  end

  def display_blocked_message(name)
    text = name + " " + PHI::Vocab::BLOCKED.to_s
    add_scroller(text)
    message = Window_MessagePopup.new(
        240,
        64,
        @target_window.contents.text_size(text).width+32,
        92-16)
    message.contents.font.size = 10
    message.popup(text, 0)
    message.update
    message.z = get_message_z
    push_message(message)
    finish_messages
  end

  def display_guard(battler)
    # Guard sound effect play, battler into guard state.
    # Guard message display.
  end

  def display_move(battler)
    # Move message show
  end

  def display_state_change(battler, state)
    # Display state change message LIST
  end

  def display_item_use(battler, item)
    # Display item used
  end

  def display_gained_item(item, text)
    return unless text.is_a?(String)
    message = Window_MessagePopup.new(0,$screen_height-50,120,54)
    text = "   " + text
    message.popup(text,60,0,
                  nil,nil,nil,nil,nil,
                  0,0)
    message.draw_item_icon(item)
    message.update
    message.z = get_message_z
    push_message(message)
  end

  def add_scroller(text)
    @message_scroll.add(text)
  end

  def get_message_z
    highest_z = 0
    for i in 0...@messages.size
      message = @messages[i]
      next if message.nil?; highest_z = message.z if highest_z < message.z
    end
    return (highest_z + 1)
  end

  def display_character_comment(character, comment)
    return if comment == ''
    message = Window_MessagePopup.new(character.screen_x - 100, character.screen_y - 30, 100, 60)
    message.popup(character.battler.name + ': ' + comment, 0, nil, nil, nil, nil, PHI.color(:YELLOW), rand(6)+1,rand(4)+1, 60, false, 80)
    push_message(message)
  end

  def display_item(name)
    return unless text.is_a?(String)
    message = Window_MessagePopup.new($screen_width/2-50,$screen_height-60,100,60)
    message.popup("Obtained: " + name,60,nil,nil,nil,nil,nil,6)
    push_message(message)
  end

  def display_failed_item(name)
    return unless text.is_a?(String)
    message = Window_MessagePopup.new($screen_width/2-50,$screen_height-60,100,60)
    message.popup("Cannot hold: " + name,60,nil,nil,nil,nil,nil,6)
    push_message(message)
  end

  def display_text(text)
    return unless text.is_a?(String)
    message = Window_MessagePopup.new($screen_width/2-50,$screen_height-60,100,60)
    message.popup(text,60,nil,nil,nil,nil,nil,2,1)
    message.update
    message.z = get_message_z
    message.opacity = 0
    push_message(message)
  end

  def f_text(text)
    return unless text.is_a?(String)
    message = Window_MessagePopup.new(0,0,0,0)
    message.popup(text,60,nil,nil,nil,nil,nil,nil,rand(6)+1,rand(4)+1)
    push_message(message)
  end

  def e_name(event)
    name = event.event.name
    message = Window_MessagePopup.new(60,125,120,80)
    message.popup(name,30,0,$screen_width/2-message.width/2,$screen_height/2-12,nil,nil,nil,rand(6)+1,rand(4)+1)
    push_message(message)
  end

  def push_message(message)
    @messages.push(message)
    #@message_scroll.add(message.text)
  end
  ##############################################################################
  # Support functions that do not require any attention.
  ##############################################################################

  def recreate_spriteset
    @spriteset.dispose
    @spriteset = Spriteset_Map.new
  end

  def wait(duration, no_fast = false)
    for i in 0...duration
      update_basic
      break if not no_fast and i >= duration / 2 and show_fast?
    end
  end

  def perform_message_event(events)
    for ev in events
      next unless ev.is_a?(Message_Event)
      case ev.type
        when 1  # 1: snap to (0)character
          $game_map.snap_to_player(ev.data)
        when 2  # 2: play sfx
          $data_system.sounds[ev.data].play
        when 3  # 3: play animation
          play_animation(ev.data)
        when 4  # 4: flash (0)character
          ev.data.flash = true
        when 5  # 5: blink (0)character
          ev.data.blink = true
        when 100 # 20: eval
          ev.data.each do |e|
            eval(e.data)
          end
      end
    end
  end

  def play_animation(data)
    data[0].start_animation(data[1]) #@data[0] = (0)character @data[1] = animation
  end

end

=begin
#==============================================================================
# ** Scene_Map_Battle
#------------------------------------------------------------------------------
#  This class performs the map screen and battle processing.
#==============================================================================

class Scene_Map < Scene_Base
  ##############################################################################
  # Scene Creation methods.
  ##############################################################################
  def start
    super
    $game_map.refresh

    @spriteset = Spriteset_Map.new
    #draw_test_line
    @message_window = Window_Message.new
    # Scene flow data.
    @battle_handler = Battle_Handler.new

    # Battle Viewport for animations and characters
    @battle_viewport = Viewport.new(0,0,$screen_width,$screen_height)

    # Battler data display, visible during battle,
    #    falls away when not in battle.
    @party_display = Window_BattlerParty.new(0,0,140,$screen_height)
    # Battler action macro window array.
    @macro_display = Window_BattlerMacros.new(140,$screen_height-48,32+16,64)
    # Holds all messages for the message history.
    @message_scroll = Window_MessageScroll.new($screen_width-102,106,102,140)
    # Contains the target information and targets for an actor attack.
    @target_window = Window_Target.new(0,0,$screen_width,$screen_height)
    #Todo: Fix targetting window. Its ass.
    $game_system.target_state = 1
    # Action queue, containing all window target return values,
    #  each already registered for their action.
    @action_queue = []
    # Popup messages.
    @messages = []
    # Dynamic animations.
    @animations = []
    # If the character is currently being moved in battle with the player's atb being full.
    @locked_display = false
    # Flag for if the battle start has been run or not.
    #@battle_started = false
    # The counter for the main screen hud to fall away
    @fallback_reset = 300
    @fallback_counter = @fallback_reset

    @map_bgm = $game_map.bgm
    @map_bgs = $game_map.bgs

    # Battle threat, if threat is active, the threat flag is active.  No reason to check anything but this.
    $game_temp.battle_threat = false
    $game_temp.battle_spotted = false
    $game_temp.in_battle = false

    #@shape_manager = Shape_Manager.new

    # Contains a list of player id's that leveled up during battle.
    @levelup_queue = []
    @battle_exp = 0
    @battle_kills = 0
  end

  ##############################################################################
  # When the scene terminates, this sequence runs.
  def terminate
    super
    p "Terminated"
    snapshot_for_background
    @party_display.dispose
    @macro_display.dispose
    @spriteset.dispose
    @message_window.dispose
    @message_scroll.dispose
    @target_window.dispose
    dispose_popups
    @animations.each { |a| a.dispose }
    @animations.clear
    @action_queue.each { |a| a.dispose }
    @action_queue.clear
    GC.start
  end
  # Branch to terminate, to dispose of all message popups.
  # Proper cleanup.
  def dispose_popups
    unless @messages.empty?
      @messages.each { |message|
        message.dispose unless message.nil?
      }
      @messages.clear
    end
  end
  ##############################################################################
  # The main update loop, highly important attention to detail
  # is required for any modification to the main update loop.
  def update
    super
    @party_display.update
    @macro_display.update
    @message_scroll.update
    @target_window.update
    @message_window.update
    # ONLY IF battle has already started, will this be used.
    if ($game_temp.battle_threat && $game_temp.battle_spotted) || $game_temp.in_battle
      full_battle_update
    else
      full_map_update
    end
  end

  def full_map_update
    # Battle has not started, thus this is the only update to be used.
    update_map                    # Updates the basic updates for the map and sprites.
    update_threat_check           # Sets the threat bool.
    update_message_popups         # Updates the message queue.
    update_action_queue           # Updates event action queue.
    update_transfer_player        # Updates the transfer.
    update_call_menu              # Opens the menu
    update_call_debug             # Opens the debug scene
    update_scene_change           # Changes the scene if the new scene isn't the same as this.
    update_common_inputs          # Updates the add-on inputs.
  end

  def full_battle_update
    # If one of the many battle interfaces are active, update that interface.
    if $game_temp.battle_threat && $game_temp.battle_spotted && !$game_temp.in_battle
      battle_startup_sequence
    elsif !$game_temp.battle_threat && $game_temp.in_battle
      battle_end_sequence
      return
    end
    if @macro_display.active
      # Updates the macro window inputs.
      @spriteset.update
      update_member_macro_inputs
    elsif @target_window.active
      # Updates the target window inputs.
      @spriteset.update
      update_target_window_inputs
    elsif @macro_display.battle_movement?
      # If the battler is moving
      # Update triggers to remove the movement.
      update_battle_movement_inputs
      update_battle_idle
    elsif !@target_window.active && !@target_window.active &&
        @macro_display.empty? && !$game_party.get_active_alive_members.empty?
      # Display has member, display is not active, and display battler movement not enabled.
      refresh_and_display_macros
    elsif !@target_window.active && !@target_window.active &&
        !@macro_display.empty? && !@macro_display.done?
      # Next character in the battle order.
      next_battle_order_sequence
    else
      # If the battler isn't moving, and none of the other triggers are satisfied.
      update_battle_idle
    end
  end

  def update_battle_idle
    update_map
    update_threat_check             # Sets the threat bool.
    update_action_queue
    update_message_popups
  end

  def update_basic
    Graphics.update                   # Update game screen
    Input.update                      # Update input information
    @spriteset.update                 # Update sprite set
    update_message_popups
  end

  def update_map
    $game_map.interpreter.update      # Update interpreter
    $game_map.update                  # Update map
    $game_party.update                # Update player sprites and movement
    $game_system.update               # Update timer
    @spriteset.update
  end

  # Update directly for messages.
  def update_message_popups
    #todo: prepare interpreter messages inside the item event.
    $interpreter_messages = [] if $interpreter_messages.nil?
    if !$interpreter_messages.empty?
      @messages += $interpreter_messages
      $interpreter_messages.clear
    end
    for i in 0...@messages.size
      next if @messages[i].nil?
      if @messages[i].ready
        perform_message_event(@messages[i].events)
        @messages[i].dispose
        @messages[i] = nil
      else
        @messages[i].update
        if @messages[i].halt?
          update_basic
        end
      end
    end
    @messages.compact! if @messages.include?(nil)
  end

  ##############################################################################
  # Scene Input Update methods.
  #     Used for direct scene control by input use.
  #     These are directly tied to the sub menus attached to the screen,
  #     $game_map cannot be updating during these.
  ##############################################################################
  # Step 1:  The fork between inputs for the hud overlay
  #          and battle trigger methods.
  def update_common_inputs
    if Input.trigger?(PadConfig.hud)
      Sound.play_equip
      @message_scroll.visible = !@message_scroll.visible
      if !@message_scroll.visible
        #unlock_displays
      elsif @message_scroll.visible
        show_member_displays
      end
    end
  end

  ##############################################################################
  # Step 2:  The active battler icons are visible, and thus
  #          the macro overlay is visible.
  def update_member_macro_inputs
    if Input.trigger?(PadConfig.decision)
      Sound.play_decision
      case @macro_display.macro_key
      when :attack
        p "Attack"
        hide_macro_display
        set_target_window_attack
      when :skill
        p "Skill"
      when :guard
        p "Guard"
      when :item
        p "Item"
      when :move
        p "Move"
        Sound.play_cancel
        hide_macro_display
        @macro_display.set_movement
      else
        p "Issues are present that must be addressed."
        p @macro_display.macro_key.inspect
      end
    elsif Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      hide_macro_display
      @macro_display.set_movement
      #@party_display.force_refresh
      #@locked_display = true
      #unlock_displays
    end
  end

  ##############################################################################
  # Step 3a:  The target window is open, and thus the inputs for the target
  #           window take priority over any of the other inputs.
  def update_target_window_inputs
    #Todo: Don't close window, prepare next character if party not done.
    #Todo: set next character fork here.
    if Input.trigger?(PadConfig.decision)
      prepare_action
      @macro_display.next
      if @macro_display.done?
        @macro_display.dump
      end
      close_target_display
      hide_macro_display
      Sound.play_equip
    elsif Input.trigger?(PadConfig.cancel)
      @target_window.contents.clear
      @target_window.index = -1
      close_target_display
      open_macro_display
      Sound.play_cancel
    end
  end

  def update_battle_movement_inputs
    if Input.trigger?(PadConfig.decision) or
        Input.trigger?(PadConfig.cancel) or
        Input.trigger?(PadConfig.hud) or
        Input.trigger?(PadConfig.menu)
      @macro_display.refresh_macros
      $game_party.clear_battle_movement
      finish_moving
      @party_display.index = $game_party.members.index(@macro_display.member)
      #@party_display.index = @macro_display.find_party_index
    #elsif Input.trigger?(PadConfig.page_up)
    #  next_battler_movement
    #  $game_map.snap_to_player($game_party.players[get_movement_member.id]) unless get_movement_member.nil?
    #elsif Input.trigger?(PadConfig.page_down)
    #  last_battler_movement
    #  $game_map.snap_to_player($game_party.players[get_movement_member.id]) unless get_movement_member.nil?
    end
  end
  ##############################################################################
  # Battle Movement methods.
  ##############################################################################
  def next_battler_movement
    return if $game_party.get_active_members.empty?
    unless get_movement_member.nil?
      ind = get_movement_member_index
      get_movement_member.battle_movement = false
      get_next_movement_member(ind).battle_movement = true
    end
  end
  def last_battler_movement
    return if $game_party.get_active_members.empty?
    unless get_movement_member.nil?
      ind = get_movement_member_index
      get_movement_member.battle_movement = false
      get_last_movement_member(ind).battle_movement = true
    end
  end
  def get_movement_member_index
    return $game_party.get_active_members.index(get_movement_member)
  end
  def get_next_movement_member(start_position)
    member = $game_party.get_active_members[start_position + 1]
    member = $game_party.get_active_members[0] if member.nil?
    return member
  end
  def get_last_movement_member(start_position)
    if start_position - 1 < 0
      member = $game_party.get_active_members[$game_party.get_active_members.size - 1]
    else
      member = $game_party.get_active_members[start_position - 1]
    end
    return member
  end
  def get_movement_member
    $game_party.get_active_members.each {|member| return member if member.battle_movement }
    return nil
  end

  ##############################################################################
  # Step 3b:  Updates the window for item selection, needs a simple custom
  #           window and window base.
  def update_item_window_inputs
  end
  ##############################################################################
  # Step 3c:  Updates the inputs for the player skill selection.
  def update_skill_window_inputs
  end

  def update_threat_check
    $game_temp.battle_threat = $game_party.any_alive_enemy_in_range?
    $game_temp.battle_spotted = $game_party.any_alive_enemy_spotted?
  end

  def battle_startup_sequence
    p "battle startup sequence"
    $game_temp.in_battle = true
    start_battle_bgm
    update_basic
    # Battle start.
    start_battle_message
    finish_moving
    finish_messages
    # Messages and pre-battle movement done, starting formation sequence.
    $game_party.break_line
    direction = PHI::Formation.dir_4($game_player.direction)
    PHI::Formation.prepare
    finish_moving
    $game_party.players.each_value { |p| p.direction = direction }
    #refresh_and_display_macros
    # Formation set, prepare macro display window.
    # Battle startup sequence complete, continue
    # Todo: Post battle startup, animation loop triggers, battle grid graphic start loop, etc.
  end

  def refresh_and_display_macros
    #if @macro_display.battle_movement?
    #  @macro_display.refresh_macros
    @macro_display.dump
    @macro_display.refresh($game_party.get_active_alive_players)
    Graphics.wait(1)
    Sound.play_equip
    @spriteset.update
    #p "Sorted Index: " + $game_party.find_sorted_index(@macro_display.member).to_s
    #@party_display.index = @macro_display.get_index#index = $game_party.find_sorted_index(@macro_display.member)
    @party_display.index = $game_party.sorted_members.index(@macro_display.member.id)#index = $game_party.find_sorted_index(@macro_display.member)
    $game_map.snap_to_player($game_party.leader)
    @spriteset.update

    open_macro_display
    show_member_displays
  end

  def next_battle_order_sequence
    @macro_display.refresh_macros
    Graphics.wait(1)
    #Sound.play_cursor
    #Sound.play_cursor
    #p "Sorted Index: " + $game_party.find_sorted_index(@macro_display.member).to_s
    @party_display.index = $game_party.sorted_members.index(@macro_display.member.id)#index = $game_party.find_sorted_index(@macro_display.member)
    $game_map.snap_to_player($game_party.leader)#$game_party.players[@macro_display.member.id])
    @spriteset.update
    open_macro_display
    show_member_displays
  end

  def battle_end_sequence
    #Todo: Display battle end message.
    update_basic
    dump_hud
    @macro_display.dump
    @spriteset.dump_battle
    $game_player.locked = true
    clear_all_actions
    $game_party.clear_battle_movement
    finish_messages
    wait_for_animation
    #p "finish moving 1"
    stop_party_moving
    $game_party.active_snap_line($game_player.x, $game_player.y)
    $game_party.set_leader
    $game_party.reform_line
    #p "finish moving 2"
    end_battle_bgm
    finish_moving
    $game_player.locked = false
    $game_temp.in_battle = false
    #Todo: Display overall exp gain and multiplier for monsters killed.
  end

  def dump_hud
    #Remove active from all interfaces.
    @macro_display.active = false
    @macro_display.visible = false
    @party_display.index = -1
    @party_display.active = false
    @target_window.active = false
    @target_window.visible = false
  end

  def stop_party_moving
    $game_party.halt_movement
    finish_moving
  end

  def finish_moving
    p "Finishing moving."
    while $game_party.any_player_moving?
      $game_party.update_players
      update_basic
    end
    p "Done"
  end

  def finish_moving_character(character)
    #todo: not working
    #while character.move_route_forcing || character.moving?
     # character.update
      #update_basic
    #nd
  end

  def finish_messages
    while !@messages.empty?
      update_basic
    end
  end
  ##############################################################################
  # Prepares the temp action for the queue.
  ##############################################################################
  # Step 4a: Updates the action queue for action traversal.
  def update_action_queue
    # Check which action type
    for i in 0...@action_queue.size
      break unless $game_temp.battle_threat
      action = @action_queue[i]
      next if action.nil?
      # Fork to designated action
      case action.kind
        when 1
          p "update action"
          update_action(i, action)
        else

      end
      # If action complete, dispose of action.
    end
    @action_queue.compact! if @action_queue.include?(nil)
  end

  def clear_all_actions
    for action in @action_queue
      action.clear
    end
    @action_queue.clear
  end

  def prepare_action
    #Todo: Split into multiple methods.
    #Todo: does not calculate single handed weapons from both hands, just the primary hand's weapon.
    member = @macro_display.member
    member.action.set_skill(0, 0)
    @action_queue.push member.action
  end

  def update_action(position, action)
    #Path to target?
    return unless $game_temp.battle_threat
    #Todo: Fix the path_required check.
    if action.in_range?
      p "In range, complete attack action"
      #action.host.halt_movement
      finish_moving_character(action.host)
      action.host.halt_movement
      complete_action(position, action)
    elsif action.blocked?
      p "Blocked"
      display_blocked_message(action)
      clear_action(position, action)
    elsif action.path_required?
      p "Path required"
      action.path_to
    end
  end

  def clear_action(position, action)
    #complete action battle end, destroy action properly
    action.battler.action.clear
    action.battler.clear_everything
    action.battler.reset_atb
    action.host.battle_animations.clear
    p "Clearing action"
    @action_queue[position] = nil
    @action_queue.compact!
  end

  def complete_action(position, action)
    case action.kind
      when 1
        run_skill_sequence(position, action)
      when 2

      when 3

    end
    clear_action(position, action)
    #$game_map.snap_to_player($game_party.players[reserved.id]) unless reserved.nil?
    #map_update
  end
    #reserved = nil
    #reserved = $game_party.get_active_members[0] unless $game_party.get_active_members[0].nil?
    #reserved = get_movement_member unless get_movement_member.nil?
    #$game_map.snap_to_player(action.host)
    #update_basic
    ## For now, no startup.  Must rig into functional state.
    ##Todo: Build startup.
    #positions = action.get_positions
    #targets = action.get_shape_targets
    #display_battle_animation(action.host, action.battler, targets, positions)
    #display_attack_values(action, targets)
    #wait_for_animation
    #clear_action(position, action)
    #$game_map.snap_to_player($game_party.players[reserved.id]) unless reserved.nil?
    #map_update

  def run_completion_sequence
  end


  def clear_action(position, action)
    action.battler.action.clear
    action.battler.clear_everything
    action.battler.reset_atb
    action.host.battle_animations.clear
    p "Clearing action"
    @action_queue[position] = nil
    @action_queue.compact!
    #$game_map.snap_to_player($game_party.players[reserved.id]) unless reserved.nil?
  end

  def run_skill_sequence(position, action)
    for i in 0...action.sequence.size
      piece = action.sequence[i]
      if piece == :full
        #<animation n><wait><damage n><wait>
        p "Running full animation"
        display_skill_animation(action, action.sequence[i])
        wait_for_animation
        perform_skill_calculations(action)
        display_attack_values(action)
        execute_damage_values(action)
        wait_for_animation
      elsif piece.include?('animation')
        #todo: prepare animation fork.
      elsif piece.include?('damage')

      elsif piece.include?('code')

      elsif piece.include?('spawn')

      elsif piece.include?('wait')

      else
          next
      end
    end
    action.clear
  end

  def display_skill_animation(action, command)
    #positions = action.get_positions
    targets = action.get_shape_targets

    animation_id = action.skill.animation_id_target
    user_animation_id = action.skill.animation_id_host
    #p "animation id " + animation_id.to_s
    #animation_id = command[1].to_i if command.is_a?(Array)
    #p "animation id " + animation_id.to_s
    display_target_host_animation(targets, animation_id, action.host, user_animation_id)
  end

  def display_animation(action, command)

  end

  def wait_for_action(action)

  end

  def find_shape_targets(action)
    return action.host.battler.shape_manager.get_shape_targets
  end

  def perform_skill_calculations(action)
    for member in action.get_shape_targets
      member.battler.make_skill_damage_value(action.battler, action.skill)
    end
  end

  def display_attack_values(action)
    for member in action.get_shape_targets
      # Perform on target.
      next if member.battler.dead?
      display_attack_value(member, action.battler, member.battler.hp_damage)
      @spriteset.update
      #p "Damage: " + member.battler.hp_damage.to_s
    end
  end

  def execute_damage_values(action)
    for member in action.get_shape_targets
      next if member.battler.dead?
      member.battler.execute_damage
      member.battler.clear_action_results
      if member.battler.dead?
        run_death_sequence(action.host, member)
      end
    end
  end

  def run_death_sequence(host, target)
    #todo: write the death sequence.
    display_death_animation(target)
    spawn_items(target) if target.is_a?(Game_Event)
    display_exp_reward(target.battler.exp.to_s) if target.is_a?(Game_Event)
    reward_exp(target.battler.exp) if target.is_a?(Game_Event)
    destroy_npc(target) if target.is_a?(Game_Event)
    #todo: display death animation
    #todo: poop items
  end

  def destroy_npc(target)
    $game_map.ev_handler.set_death_switch($game_map.map_id, target.event.id)
  end

  def spawn_items(character)
    character.battler.drops.each do |item|
      if item.is_a?(RPG::Enemy::DropItem)
        if character.battler.drop_item1.kind == 1
          p character.battler.drop_item1.denominator.to_s
          if rand(character.battler.drop_item1.denominator) == 0
            $game_map.create_item(character.x, character.y, character.battler.drop_item1.item_id)
            $game_map.ev_handler.newest_event.move_random
            $game_map.ev_handler.newest_event.update
            update_battle_idle
            while $game_map.ev_handler.newest_event.moving?
              update_battle_idle
              $game_map.ev_handler.newest_event.update
            end
          end
        else
          p "not an item drop, needs more code."
        end
        if character.battler.drop_item2.kind == 1
          if rand(character.battler.drop_item2.denominator) == 0
            $game_map.create_item(character.x, character.y, character.battler.drop_item2.item_id)
            $game_map.ev_handler.newest_event.move_random
            $game_map.ev_handler.newest_event.update
            update_battle_idle
            while $game_map.ev_handler.newest_event.moving?
              update_battle_idle
              $game_map.ev_handler.newest_event.update
            end
          end
        else
          p "not an item drop, needs more code."
        end
      else
        #Todo: Build functionality for extra item drops.
        # <drop id value max_amt frequency>
      end

    end
  end

  def display_death_animation(character)
    #character.battler.collapse = true
    Sound.play_enemy_collapse
    character.battler.collapse = true
    character.update
  end

  def display_levelup_animations(event)
    event.battle_animations.push 88
  end

  def display_exp_reward(exp)
    text = PHI::Vocab::EXP + " +" + exp
    add_scroller(text)
    message = Window_MessagePopup.new(200,180,128,80)
    message.popup(text,0, nil, nil, nil, nil, PHI.color(:CYAN), rand(6)+1, rand(4)+1, 60, nil, 12)
    message.update
    message.z = get_message_z
    push_message(message)
  end

  def reward_exp(exp)
    levels = $game_party.get_levels_and_ids
    $game_party.distribute_exp(exp)
    $game_party.get_levelups(levels).each do |up|
      next unless $game_party.sorted_members[0...5].include?(up)
      display_levelup_animations($game_party.players[up])
      display_levelup_message($game_party.players[up])
      @party_display.force_refresh
    end
  end

  def display_levelup_message(player)
    text = "Level Up"
    add_scroller(player.get_member.name + " " + text + " " + player.get_member.level.to_s)
    y_pos = $game_party.members.index(player.get_member) * $screen_height/5
    message = Window_MessagePopup.new(12,y_pos,128,80)
    message.popup(text, 0, nil, nil, nil, nil, nil, nil, nil, 30)
    message.z = 5000
    message.update
    push_message(message)
  end

  def update_guard_actions
    #Stand still
    #Wait some frames
    #Jump to guarding target center screen
    #Perform guard animation
    #Set guard state on battler
  end
  def complete_guard_action
  end

  def update_item_actions
    #Stand still
    #Wait some frames
    #Find item type
    #if normal item path to target touch
    #if skill item, start skill iterations
    #if
  end
  def complete_item_action
  end

  def update_skill_actions
    #Determine if path to or stand still
    #Wait some frames
    #If path to, walk to, begin channel
    #If stand still, channel

  end
  def complete_skill_action
  end

  def update_quick_step_actions
    #Teleport this player to the position, atb timer reset.
  end
  def complete_quick_step_action
  end

  ##############################################################################
  # Force test action function, used to test pieces of the actions.
  def force_test_action
  end
  #--------------------------------------------------------------------------
  # * Wait Until Animation Display has Finished
  #--------------------------------------------------------------------------
  def wait_for_animation
    while @spriteset.animation?
      update_basic
    end
  end
  #--------------------------------------------------------------------------
  # * Show Normal Animation
  #     targets      : Target array
  #     animation_id : Animation ID
  #     mirror       : Flip horizontal
  #--------------------------------------------------------------------------
  def display_target_host_animation(targets, animation_id, user, user_animation_id)
    # Damage splash animations.
    animation = $data_animations[animation_id]
    user_animation = $data_animations[user_animation_id]
    if animation != nil
      to_screen = (animation.position == 3)       # Is the positon "screen"?
      for target in targets.uniq
        next if target.battler.dead?
        target.battle_animations.push animation_id
      end
    end
    if user_animation != nil
      to_screen = (animation.position == 3)       # Is the positon "screen"?
      user.battle_animations.push user_animation_id
    end
  end
  ##############################################################################
  # Scene Window overlay modifiers.
  #   Used as modifiers for the scene, triggered by inputs and events.
  ##############################################################################
  def show_member_displays
    @party_display.visible = true
  end

  def lock_displays
    #todo: lock party display, preventing it from falling away.
  end

  def unlock_displays
    #todo: unlock party display, causing it to fall away if hp, mp, and atb are full for long enough.
  end

  def open_macro_display
    @macro_display.visible = true
    @macro_display.active = true
  end

  def hide_macro_display
    @macro_display.visible = false
    @macro_display.active = false
  end
  ##############################################################################
  def set_target_window_attack
    @target_window.refresh(@macro_display.member, "enemy", "attack")
    open_target_display
  end
  ##############################################################################
  def open_target_display
    @target_window.visible = true
    @target_window.active = true
  end
  ##############################################################################
  def close_target_display
    @target_window.visible = false
    @target_window.active = false
  end
  ##############################################################################
  ##############################################################################
  # Battler Function methods
  def any_member_atb_full?
    for member in $game_party.members
      return true if member.ready?
    end
    return false
  end

  def any_member_moving?
    for member in $game_party.members
      return true if member.battle_movement
    end
    return false
  end

  def get_full_atb_members
    output = []
    for member in $game_party.members
      output.push member if member.atb_full?
    end
    return output
  end

  def alive_members
    output = []
    for member in $game_party.members
      output.push member if member.dead?
    end
    return output
  end

  def any_enemy_in_range?
    return $game_party.any_alive_enemy_in_range?
  end

  ##############################################################################
  # Scene Popup Messagebox custom methods.

  #@text = input string
  #@opacity = input integer, message box opacity
  #@x = input integer, x value of window position
  #@y = input integer, y value of window position
  #@width = input integer, width of the window
  #@height = input integer, height of the window
  #@color = Color, color class object for text color
  #@animate = integer, determines the direction of the window

def snap_to_character(character)
  $game_map.snap_to_player(character)
end

def display_attack_value(character, attacker, hp)
  return if character.battler.nil?
  p "Battler not nil."
  # Todo: set values to determine critical damage.
  text = hp.to_s
  sprite = Sprite_NumericPopup.new
  #if attacker.physical_attack?
  if hp > 0; color = PHI.color(:WHITE) else color = PHI.color(:RED) end
  #elsif attacker.agility_attack?
  # if hp > 0; color = PHI.color(:YELLOW) else color = PHI.color(:WHITE) end
  #elsif attacker.spirit_attack?
  # if hp > 0; color = PHI.color(:BLUE, 160) else color = PHI.color(:WHITE) end
  #end
  sprite.set_number(character, text, color)
  sprite.oy += 24
  character.battle_numerics.push sprite
end

# def display_attack_animation(target)
# If guarded, make tink noise
# If not guarded do normal attack damage sound.
#end

def start_battle_message
  text = "Threat found, formations everyone!"
  add_scroller(text)
  message = Window_MessagePopup.new(120,120,128,80)
  message.popup(text,0, nil, nil, nil, nil, PHI.color(:RED, 200),nil, nil, 60)
  message.update
  message.z = get_message_z
  push_message(message)
  Graphics.wait(1)
end

def display_blocked_message(action)
  text = action.battler.name + " " + PHI::Vocab::BLOCKED.to_s
  add_scroller(text)
  message = Window_MessagePopup.new(
      240,
      64,
      @target_window.contents.text_size(text).width+32,
      92-16)
  message.contents.font.size = 10
  message.popup(text, 0)
  message.update
  message.z = get_message_z
  push_message(message)
  finish_messages
end

def display_guard(battler)
  # Guard sound effect play, battler into guard state.
  # Guard message display.
end

def display_move(battler)
  # Move message show
end

def display_state_change(battler, state)
  # Display state change message LIST
end

def display_item_use(battler, item)
  # Display item used
end

def display_gained_item(item, text)
  return unless text.is_a?(String)
  message = Window_MessagePopup.new(0,$screen_height-50,120,54)
  text = "   " + text
  message.popup(text,60,0,
                nil,nil,nil,nil,nil,
                0,0)
  message.draw_item_icon(item)
  message.update
  message.z = get_message_z
  push_message(message)
end

def add_scroller(text)
  @message_scroll.add(text)
end

def get_message_z
  highest_z = 0
  @messages.each { |message|
    next if message.nil?
    highest_z = message.z if highest_z < message.z
  }
  return (highest_z + 1)
end

def display_item(name)
  return unless text.is_a?(String)
  message = Window_MessagePopup.new($screen_width/2-50,$screen_height-60,100,60)
  message.popup("Obtained: " + name,60,nil,nil,nil,nil,nil,6)
  push_message(message)
end

def display_failed_item(name)
  return unless text.is_a?(String)
  message = Window_MessagePopup.new($screen_width/2-50,$screen_height-60,100,60)
  message.popup("Cannot hold: " + name,60,nil,nil,nil,nil,nil,6)
  push_message(message)
end

def display_text(text)
  return unless text.is_a?(String)
  message = Window_MessagePopup.new($screen_width/2-50,$screen_height-60,100,60)
  message.popup(text,60,nil,nil,nil,nil,nil,nil,rand(6)+1,rand(4)+1)
  push_message(message)
end

def f_text(text)
  return unless text.is_a?(String)
  message = Window_MessagePopup.new(0,0,0,0)
  message.popup(text,60,nil,nil,nil,nil,nil,nil,rand(6)+1,rand(4)+1)
  push_message(message)
end

def e_name(event)
  name = event.event.name
  message = Window_MessagePopup.new(60,125,120,80)
  message.popup(name,30,0,$screen_width/2-message.width/2,$screen_height/2-12,nil,nil,nil,rand(6)+1,rand(4)+1)
  push_message(message)
end

def push_message(message)
  @messages.push(message)
  @message_scroll.add(message.text)
end
##############################################################################
# Support functions that do not require any attention.
##############################################################################

def recreate_spriteset
  @spriteset.dispose
  @spriteset = Spriteset_Map.new
end

def wait(duration, no_fast = false)
  for i in 0...duration
    update_basic
    break if not no_fast and i >= duration / 2 and show_fast?
  end
end


def perform_message_event(events)
  for ev in events
    next unless ev.is_a?(Message_Event)
    case ev.type
      when 1  # 1: snap to (0)character
        $game_map.snap_to_player(ev.data)
      when 2  # 2: play sfx
        $data_system.sounds[ev.data].play
      when 3  # 3: play animation
        play_animation(ev.data)
      when 4  # 4: flash (0)character
        ev.data.flash = true
      when 5  # 5: blink (0)character
        ev.data.blink = true
      when 100 # 20: eval
        ev.data.each do |e|
          eval(e.data)
        end
    end
  end
end

=begin
  @data[0] = (0)character
  @data[1] = animation
=end
#def play_animation(data)
 # data[0].start_animation(data[1])
#end


#~   #--------------------------------------------------------------------------
#~   # * Execute Screen Switch
#~   #--------------------------------------------------------------------------
#~   alias original_update_scene_change update_scene_change
#~   def update_scene_change
#~     return $game_temp.next_scene = nil if $scene != nil and $battle
#~     original_update_scene_change
#~   end



#end
#=end