#==============================================================================
# ** Game_BattleAction
#------------------------------------------------------------------------------
#  This class handles battle actions. This class is used within the
# Game_Battler class.
#==============================================================================

#Todo: implement skill sequence nodes
class Skill_Sequence_Node
  attr_accessor :last_non_wait
  attr_accessor :sequence_pos
  attr_accessor :skill
end

class Game_BattleAction
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :host                     # host
  attr_accessor :battler                  # battler
  attr_accessor :speed                    # speed
  attr_accessor :kind                     # kind (basic/skill/item)
  attr_accessor :skill_id                 # skill ID
  attr_accessor :item_id                  # item ID
  attr_accessor :target_index             # target index #deprecated
  attr_accessor :forcing                  # forced flag
  attr_accessor :value                    # automatic battle evaluation value
  attr_accessor :shape_manager
  attr_accessor :executing
  attr_accessor :residue_container
  attr_reader   :performing_skill
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     battler : Battler
  #--------------------------------------------------------------------------
  def initialize(battler)
    @battler = battler
    @shape_manager = @battler.shape_manager
    @atb_counter = BATTLE_DATA::ATB_TIMER
    @startup_counter = BATTLE_DATA::SKILL_TIMER
    @cooldown_counter = BATTLE_DATA::COOLDOWN_TIMER
    @wait = 0
    @last_non_wait_action = nil
    @residue_container = []
    @performing_skill = false
    clear
  end

  #--------------------------------------------------------------------------
  # * Clear
  #--------------------------------------------------------------------------
  def clear
    @performing_skill = false
    @cooldown_started = false
    @speed = 0
    @kind = 0
    @skill_id = -1
    @item_id = -1
    @tree = nil
    @forcing = false
    @value = 0
    @target = nil
    @type = nil
    @sequence_pos = 0
    @subsequence_pos = 0
    @killed_target_comment = false
    @startup_counter = BATTLE_DATA::SKILL_TIMER
    @cooldown_counter = BATTLE_DATA::COOLDOWN_TIMER
    @last_non_wait_action = nil
  end

  def clear_battle
    #complete action battle end, destroy action properly
    battler.clear_everything
    reset_atb
    host.battle_animations.clear
    clear
  end


  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------

  def update
    #Path to target?
    #Todo: Fix the path_required check.
    # If atb meter is full, and skill is not active.
    return @wait -= 1 if @wait > 0
    update_stat_regen
    update_residue
    update_atb unless atb_full?
    return unless $game_temp.in_battle
    if !skill_selected? && !host.is_a?(Game_Player) && !battler.dead? && ready?
      update_ai
    elsif skill_selected? || item_selected?
      return update_skill_startup unless skill_startup_complete?
      return update_skill_cooldown if !skill_cooldown_complete? && @performing_skill && sequence_done?
      return update_skill_execute unless sequence_done?
      return begin_cooldown if (sequence_done? && @performing_skill && !@cooldown_started)
      return complete_current_action if ready_for_clear?
    end
  end

  def update_ai
    #todo: replace stub with enhanced ai
    #select target, then skill immediately
    #p 'update ai'
    #p battler.skills.keys.inspect
    tree = battler.skills.keys[rand(battler.skills.keys.size)]
    nid = rand(battler.skills[tree].keys.size)
    set_skill(tree, nid)
    battler.shape_manager.prepare($game_party.players[$game_party.players.keys[rand($game_party.players.keys.size)]], skill)
  end

  def update_atb
    distance = BATTLE_DATA::ATB_TIMER
    modifier = 999
    modifier += battler.level * 1.5
    modifier = battler.agi + 1 if modifier <= battler.agi
    rate = distance / (modifier - battler.agi).to_f + 1
    rate = 50 if rate > 50
    @atb_counter += rate
  end

  def update_skill_startup
    @startup_counter += skill_step(selected_object.startup)
  end

  def update_skill_cooldown
    @cooldown_counter += skill_step(selected_object.cooldown)
  end

  def complete_current_action
    reset_atb
    clear
  end

  def begin_cooldown
    @killed_target_comment ? display_kill_comment : display_cooldown_comment
    @cooldown_started = true
    @cooldown_counter = 0 if selected_object.cooldown > 0
  end

  def update_skill_execute
    # Skill full, confirm bool.
    if (in_range? || @performing_skill) && (skill_selected? || item_selected?)
      execute_skill_sequence
    elsif path_required?
      #Todo: Confirm pathing is possible.
      if blocked?
        #Todo: create a proper blocked response.
        $scene.display_blocked_message(battler.name) if $scene.is_a?(Scene_Map)
        clear
      else
        path_to
      end
    end
  end

  def can_revive?
    return selected_object.can_revive?
  end

  def execute_skill_sequence
    return @sequence_pos = sequence.size + 1 if sequence_done?
    return @sequence_pos = sequence.size + 1 if !can_revive? && target.battler.dead?
    #return if any_performing_skill?
    host.face_target(target) unless @performing_skill
    @performing_skill = true
    host.halt_movement
    # Check if skill sequence should run, or execute itself right now.
    # Happens because death can still have skills cast upon it, if the death flag is tripped.
    segment = sequence[@sequence_pos]
    piece = segment
    if segment.is_a?(Array) # Processes the array into a segment piece
      if is_command_list?(segment)
        piece = segment[@subsequence_pos] # Piece from subsequence list
      elsif is_command?(segment)
        piece = segment[0] # Piece from subsequence list
      end
    else
      @subsequence_pos = 0;
    end
    @last_non_wait_action = piece if piece != :wait
    case piece
      when :animation
        p 'Running animation'
        is_command_list?(segment) ? display_full_animation : display_command_animation(segment)
      when :damage
        p 'Running damage'
        is_command_list?(segment) ? execute_full_skill : execute_segment_skill(segment)
      when :hit
        p 'Displaying hit comment'
        is_command_list?(segment) ? display_hit_comment : display_hit_comment(segment)
      when :shove
        p 'Running shove'
        is_command_list?(segment) ? perform_shove_movements : perform_shove_movements(segment)
      when :code
        p 'Running code ' + segment[1].to_s
        eval(segment[1])
      when :spawn
        #Todo: spawn entity from command, set loyalty
      when :wait
        case @last_non_wait_action
          when :animation
            return if targets_animating?
          when :damage
            return if damage_animating?
          when :shove
            return if target.shoved? || self.host.shoved?
        end
    end
    if segment.is_a?(Array) && !subsequence_done?(segment)
      @subsequence_pos += 1
    else
      @subsequence_pos = 0
      @sequence_pos += 1
    end
  end


=begin
  def execute_skill_sequence
    return @sequence_pos = sequence.size + 1 if sequence_done?
    return @sequence_pos = sequence.size + 1 if !can_revive? && target.battler.dead?
    host.face_target(target) unless @performing_skill
    @performing_skill = true
    host.halt_movement
    # Check if skill sequence should run, or execute itself right now.
    # Happens because death can still have skills cast upon it, if the death flag is tripped.
    segment = sequence[@sequence_pos]
    piece = segment
    piece = segment[0] if segment.is_a?(Array)
    @last_non_wait_action = piece if piece != :wait
    case piece
      when :animation
        p 'Running animation'
        display_skill_animation
      when :damage
        p 'Running damage'
        execute_skill
      when :hit
        p 'Displaying hit comment'
        display_hit_comment
      when :shove
        p 'Running shove'
        perform_shove_movements
      when :code
        p 'Running code ' + segment[1].to_s
        eval(segment[1])
      when :spawn
        #Todo: spawn entity from command
      when :wait
        case @last_non_wait_action
          when :animation
            return if targets_animating?
          when :damage
            return if damage_animating?
          when :shove
            return if target.shoved?
        end
    end
    @sequence_pos += 1
  end
=end
  # ----------------------------------------------------------------------------------------------
  # Functions used for sequencer.
  # ----------------------------------------------------------------------------------------------
  # ----------------------------------------------------------------------------------------------
  # ----------------------------------------------------------------------------------------------
  def execute_full_skill
    return if battler.nil?
    #on_hit_values
    perform_skill_calculations
    display_attack_values
    execute_damage_values
  end
  def execute_segment_skill(segment)
    perform_skill_calculations(segment)
    display_attack_values
    execute_damage_values
  end
  def perform_skill_calculations(segment=nil)
    #p shape_targets.inspect
    for member in shape_targets
      next if member.nil? or member.battler.nil?
      member.battler.make_skill_damage_value(battler, selected_object, segment)
    end
  end
  def execute_damage_values
    for member in shape_targets
      next if member.battler.nil?
      alive = member.battler.dead?
      member.battler.execute_damage
      alive_after = member.battler.dead?
      member.battler.clear_action_results
      # Todo: form battler comment for resurrection
      if alive != alive_after && !alive
        @killed_target_comment = true
        run_death_sequence(member)
      end
    end
  end
  ############################################################################################################
  def perform_shove_movements(segment=nil)
    #todo: write documentation for shove functionality in sequence.
    return unless $scene.is_a?(Scene_Map)
    return if item_selected?
    #todo: functionality for item
    #todo: on_shove
    host.shove_command(skill.self_shove, host, target)
    for tgt in shape_targets
      next if tgt.nil? or tgt.battler.nil?
      tgt.shove_command(skill.shove, host, target)
    end
  end

  def display_attack_values
    return unless $scene.is_a?(Scene_Map)
    return if item_selected?
    #todo: functionality for item
    for this_target in shape_targets
      next if this_target.nil? or this_target.battler.nil?
      # Perform on target.
      #next if this_target.battler.dead?
      this_target.battle_numerics.push [this_target, battler, this_target.battler.hp_damage]
      #p "Damage: " + member.battler.hp_damage.to_s
    end
  end

  def update_stat_regen
    #hp_dif = battler.maxhp - battler.hp
    #mp_dif = battler.maxmp - battler.mp
    #sta_dif = battler.maxstamina - battler.stamina
    #str_dif = battler.maxstr
  end

  def update_residue
    #todo: implement the broken algorithm fork with node list
    # Step residue
    battler.lingering.each do |lingering_skill|
      lingering_skill.step
    end
    #Perform stat changes.
    #Todo: include lingering effects for equipment.
    battler.lingering.each do |lingering_skill|
      #Todo: perform residue effect
      if lingering_skill.activate?
        lingering_skill.stack_up
        perform_residue_effect(lingering_skill)
      end
      #lingering_skill.skill
    end
    #Chop completed
    (0...battler.lingering.size).each do |i|
      battler.lingering[i] = nil if battler.lingering[i].done?
    end
    battler.lingering.compact!
  end

  def perform_residue_effect(lingering_skill)

  end


  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  # Step the counters

  def set_skill(tree, skill_id)
    @kind = 1
    @skill_id = skill_id
    tree.is_a?(Symbol) ? @tree = tree : @tree = @battler.get_skill_tree_title(tree)
    display_startup_comment
    @startup_counter = 0 if skill.startup > 0
  end

  def set_item(item_id)
    @kind = 2
    @item_id = item_id
  end


  def skill_step(val)
    distance = BATTLE_DATA::SKILL_TIMER * val
    #distance = 10000 if distance == 0
    modifier = 999
    modifier += battler.level * 1.5
    modifier = ((battler.spi + battler.agi) / 2) + 1 if modifier <= ((battler.spi + battler.agi) / 2)
    rate = distance / (modifier - ((battler.spi + battler.agi) / 2)).to_f + 1
    rate = 50 if rate > 50
    return rate
  end

  def reset_atb
    @atb_counter = 0.0
    @startup_counter = BATTLE_DATA::SKILL_TIMER
    @cooldown_counter = BATTLE_DATA::COOLDOWN_TIMER
  end
  def sequence
    return @battler.action.skill.sequence if @battler.action.skill_selected?
    return @battler.action.item.sequence if @battler.action.item_selected?
    return []
  end
  def sequence_done?
    return true if sequence.nil?
    return @sequence_pos > sequence.size
  end
  def subsequence_done?(seq)
    return true if seq.nil? or seq.is_a?(Symbol)
    return @subsequence_pos > seq.size
  end
  def is_command_list?(seq)
    syms = 0
    for i in 0...seq.size
      syms += 1 if seq[i].is_a?(Symbol)# || seq[i].is_a?(Array)
    end
    return syms > 1
  end
  def is_command?(seq)
    return !is_command_list?(seq)
  end
  def running?
    return targets_animating?
  end
  def atb
    return @atb_counter
  end
  def s_startup
    return @startup_counter
  end
  def s_cooldown
    return @cooldown_counter
  end

  # Check bool flags
  def atb_full?
    return (@atb_counter >= BATTLE_DATA::ATB_TIMER)
  end
  def ready?
    return nothing_selected? && atb_full? # && !self.pathing
  end
  def skill_startup_complete?
    return (@startup_counter >= BATTLE_DATA::SKILL_TIMER)
  end
  def skill_ready?
    return skill_startup_complete?
  end
  def skill_cooldown_complete?
    return (@cooldown_counter >= BATTLE_DATA::SKILL_TIMER)
  end

  def ready_for_clear?
    return @performing_skill &&
        skill_selected? &&
        skill_cooldown_complete? &&
        skill_startup_complete? &&
        sequence_done?
  end

  def nothing_selected?
    return @kind == 0
  end

  def skill_selected?
    return @kind == 1
  end

  def skill
    #if skill_selected?
    #  p "Battle Action Skill: " + @battler.skills[@tree][@skill_id].name
    #  p "tree: " + @tree.to_s, "@skill_id: " + @skill_id.to_s
    #end
    return skill_selected? ? @battler.skills[@tree][@skill_id] : nil
  end

  def item_selected?
    return @kind == 2
  end

  # Todo: get item from the allocated item id, from the new inventory or second inventory.
  def item
    return item_selected? ? $data_items[@item_id] : nil
  end

  def selected_object
    if skill_selected?
      return skill
    elsif item_selected?
      return item
    else
      return nil
    end
  end

  def in_range?
    return (host.x - target.x).abs <= selected_object.offset && (host.y - target.y).abs <= selected_object.offset
  end

  # Todo: deprecate old style of target, replace with new.
  def target
    return @battler.shape_manager.target
  end

  def shape_targets
    return @battler.shape_manager.get_shape_targets
  end

  def get_positions
    return @battler.shape_manager.positions
  end

  def host
    if @battler.is_a?(Game_Actor)
      return $game_party.players[@battler.id]
    elsif @battler.is_a?(Game_Enemy)
      return @battler.character
    end
    return nil
  end

  def path_to
    host.offset_force_path(target.x,target.y, selected_object.offset)
  end

  def possible?
    return false if blocked?
    return false if @battler.dead?
    return !blocked? && !@battler.dead?
  end

  def path_started?
    return host.move_route_forcing
  end

  def path_required?
    return false if in_range?
    return !path_started?
  end

  def blocked?
    return host.movable?
  end

  def performing?
    return @performing_skill
  end

  def targets_animating?
    #for i in 0...$scene.spriteset.character_sprites.size
    #  #p 'is true ' if $scene.spriteset.character_sprites[i].animation_from_this_battler?(@battler.__id__)
    #  return true if $scene.spriteset.character_sprites[i].animation_from_this_battler?(@battler.__id__)
    #end
    return false
  end

  def damage_animating?
    #for i in 0...$scene.spriteset.character_sprites.size
    #  sprite = $scene.spriteset.character_sprites[i]
    #  return true if shape_targets.include?(sprite.character) && sprite.popup_from_this_battler?(@battler.__id__)
    #end
    return false
  end

  def display_command_animation(sequence)
    case sequence[1]
      when :host
        $scene.display_target_animation(host, sequence[2]) if $scene.is_a?(Scene_Map)
      when :target
        $scene.display_target_animation(target, sequence[2]) if $scene.is_a?(Scene_Map)
    end
  end


  def display_full_animation(target_id=nil, user_id=nil)
    p 'displaying animation'
    #todo: functionality for item animations
    return if item_selected?
    target_id.nil? ? animation_id = skill.animation_id_target : animation_id = target_id
    user_id.nil? ? user_animation_id = skill.animation_id_host : user_animation_id = user_id
    $scene.display_target_host_animation(target, animation_id, host, user_animation_id) if $scene.is_a?(Scene_Map)
  end

  def display_hit_comment(segment=nil)
    return unless $scene.is_a?(Scene_Map)
    #todo: hit comment for items
    return if item_selected?
    segment.nil? ? message = skill.hit_message : message = segment[1]
    $scene.display_character_comment(host, message)
  end

  def display_cooldown_comment
    return unless $scene.is_a?(Scene_Map)
    #todo: cooldown comment for items
    return if item_selected?
    $scene.display_character_comment(host, skill.cooldown_message)
  end

  def display_startup_comment
    return unless $scene.is_a?(Scene_Map)
    #todo: startup comment for items
    $scene.display_character_comment(host, skill.cast_message)
  end

  def display_kill_comment
    return unless $scene.is_a?(Scene_Map)
    #todo: kill comment for items
    return if item_selected?
    $scene.display_character_comment(host, skill.kill_message)
  end

  def run_death_sequence(target)
    return unless $scene.is_a?(Scene_Map)
    #todo: write the death sequence.
    return if item_selected?
    #display_death_animation(target)
    spawn_items(target) if target.is_a?(Game_Event)
    $scene.display_exp_reward(target.battler.exp.to_s) if target.is_a?(Game_Event)
    $scene.reward_exp(target.battler.exp) if target.is_a?(Game_Event)
    destroy_npc(target) if target.is_a?(Game_Event)
  end

  #Todo: deprecate old destroy_npc
  def destroy_npc(target)
    $game_map.ev_handler.set_death_switch($game_map.map_id, target.event.id)
  end

  def spawn_items(character)
    return unless $scene.is_a?(Scene_Map)
    return
    character.battler.drops.each do |item|
      if item.is_a?(RPG::Enemy::DropItem)
        if character.battler.drop_item1.kind == 1
          if rand(character.battler.drop_item1.denominator) == 0
            $game_map.create_item(character.x, character.y, character.battler.drop_item1.item_id)
            $game_map.ev_handler.newest_event.move_random
            $game_map.ev_handler.newest_event.update
            #$scene.update_battle_idle
            while $game_map.ev_handler.newest_event.moving?
              Graphics.wait(1)
              $game_map.ev_handler.newest_event.update
              $scene.spriteset.update
            end
          end
        else
          p "not an item drop, needs more code."
        end
        #if character.battler.drop_item2.kind == 1
        #  if rand(character.battler.drop_item2.denominator) == 0
        #    $game_map.create_item(character.x, character.y, character.battler.drop_item2.item_id)
        #    $game_map.ev_handler.newest_event.move_random
        #    $game_map.ev_handler.newest_event.update
        #    $scene.update_battle_idle
        #    while $game_map.ev_handler.newest_event.moving?
        #      $scene.update_battle_idle
        #      $game_map.ev_handler.newest_event.update
        #    end
        #  end
        #else
        #  p "not an item drop, needs more code."
        #end
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

  def display_levelup_animations(character)
    character.battle_animations.push 88
  end

end

=begin
  #--------------------------------------------------------------------------
  # * Get Allied Units
  #--------------------------------------------------------------------------
  def friends_unit
    if battler.actor?
      return $game_party
    else
      return $game_troop
    end
  end
  #--------------------------------------------------------------------------
  # * Get Enemy Units
  #--------------------------------------------------------------------------
  def opponents_unit
    if battler.actor?
      return $game_troop
    else
      return $game_party
    end
  end
  #--------------------------------------------------------------------------
  # * Random Target
  #--------------------------------------------------------------------------
  # Todo: Functionality for smooth target, deprecate.
  def decide_random_target
    #if for_friend?
    #  target = friends_unit.random_target
    #elsif for_dead_friend?
    #  target = friends_unit.random_dead_target
    #else
    #  target = opponents_unit.random_target
    #end
    #if target == nil
    #  clear
    #else
    #  @target_index = target.index
    #end
  end
  #--------------------------------------------------------------------------
  # * Last Target
  #--------------------------------------------------------------------------
  # Todo: Deprecate last target, and anything to do with target index.
  def decide_last_target
    #if @target_index == -1
    #  target = nil
    #elsif for_friend?
    #  target = friends_unit.members[@target_index]
    #else
    #  target = opponents_unit.members[@target_index]
    #end
    #if target == nil or not target.exist?
    #  clear
    #end
  end
  #--------------------------------------------------------------------------
  # * Action Preparation
  #--------------------------------------------------------------------------
  def prepare
    # Todo: Prepare functionality for berserker and confision in the future.
    #if battler.berserker? or battler.confusion?   # If berserk or confused
    #  set_attack                                  # Change to normal attack
    #end
  end
  #--------------------------------------------------------------------------
  # * Skill Evaluation
  #--------------------------------------------------------------------------
  # Todo: Deprecate anything to do with target index.
  def evaluate_skill
    #@value = 0
    #unless battler.skill_can_use?(skill)
    #  return
    #end
    #if skill.for_opponent?
    #  targets = opponents_unit.existing_members
    #elsif skill.for_user?
    #  targets = [battler]
    #elsif skill.for_dead_friend?
    #  targets = friends_unit.dead_members
    #else
    #  targets = friends_unit.existing_members
    #end
    #for target in targets
    #  value = evaluate_skill_with_target(target)
    #  if skill.for_all?
    #    @value += value
    #  elsif value > @value
    #    @value = value
    #    @target_index = target.index
    #  end
    #end
  end
  #--------------------------------------------------------------------------
  # * Create Target Array
  #--------------------------------------------------------------------------
  # Todo: deprecate make_targets for automation.
  def make_targets
    #if attack?
    #  return make_attack_targets
    #elsif skill?
    #  return make_obj_targets(skill)
    #elsif item?
    #  return make_obj_targets(item)
    #end
  end
  #--------------------------------------------------------------------------
  # * Create Normal Attack Targets
  #--------------------------------------------------------------------------
  #Todo: Replace targeting system with the new stored target system.
  def make_attack_targets
    #targets = []
    #if battler.confusion?
    #  targets.push(friends_unit.random_target)
    #elsif battler.berserker?
    #  targets.push(opponents_unit.random_target)
    #else
    #  targets.push(opponents_unit.smooth_target(@target_index))
    #end
    #if battler.dual_attack      # Chain attack
    #  targets += targets
    #end
    #return targets.compact
  end
  #--------------------------------------------------------------------------
  # * Create Skill or Item Targets
  #     obj : Skill or item
  #--------------------------------------------------------------------------
  #Todo: Replace item/skill targets with the new item target system.
  def make_obj_targets(obj)
    #targets = []
    #if obj.for_opponent?
    #  if obj.for_random?
    #    if obj.for_one?         # One random enemy
    #      number_of_targets = 1
    #    elsif obj.for_two?      # Two random enemies
    #      number_of_targets = 2
    #    else                    # Three random enemies
    #      number_of_targets = 3
    #    end
    #    number_of_targets.times do
    #      targets.push(opponents_unit.random_target)
    #    end
    #  elsif obj.dual?           # One enemy, dual
    #    targets.push(opponents_unit.smooth_target(@target_index))
    #    targets += targets
    #  elsif obj.for_one?        # One enemy
    #    targets.push(opponents_unit.smooth_target(@target_index))
    #  else                      # All enemies
    #    targets += opponents_unit.existing_members
    #  end
    #elsif obj.for_user?         # User
    #  targets.push(battler)
    #elsif obj.for_dead_friend?
    #  if obj.for_one?           # One ally (incapacitated)
    #    targets.push(friends_unit.smooth_dead_target(@target_index))
   #   else                      # All allies (incapacitated)
   #     targets += friends_unit.dead_members
   #   end
   # elsif obj.for_friend?
   #   if obj.for_one?           # One ally
   #     targets.push(friends_unit.smooth_target(@target_index))
   #   else                      # All allies
   #     targets += friends_unit.existing_members
   #   end
   # end
   # return targets.compact
  end
=end