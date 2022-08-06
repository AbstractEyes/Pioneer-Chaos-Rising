class Game_Character

  attr_accessor :o_animation
  attr_accessor :o_container
  attr_accessor :o_time
  attr_reader   :o_frames
  attr_accessor :o_index
  attr_reader   :o_x
  attr_reader   :o_y
  attr_reader   :o_pattern
  attr_reader   :o_wait
  attr_reader   :o_sequence
  attr_reader   :o_reverse
  attr_reader   :o_animation_type

  attr_reader   :dead_frame

  alias overwritten_animation_initialization initialize
  def initialize(*args,&block)
    overwritten_animation_initialization(*args,&block)
    @dead = false
    @dead_frame = 0
    @dead_wait = 0
    @special_sprite = false
    @o_sequence = []
    set_special_sprite
  end

  def reset_o_animation
    @o_animation = nil
    @o_time = -1
    @o_frames = -1
    @o_x = -1
    @o_y = -1
    @o_pattern = 0
    @o_wait = 0
    @o_reverse = false
    @o_animation_type = 0
    @o_next = false
    @o_container = PHI::Sprite_Data.get_data(@character_name)
  end

  def unlock_o_animation
    @o_next = true
  end

  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  alias shove_update update
  def update
    shove_update
    if jumping?                 # Jumping
      update_jump
    elsif overwritten_animation? # Non moving animation type
      update_overwritten_animation
    elsif moving? or shoved?    # Moving or shoved
      update_shove
      update_move
    else                        # Stopped
      update_stop
    end
    if @wait_count > 0          # Waiting
      @wait_count -= 1
    elsif @move_route_forcing   # Forced move route
      move_type_custom
    elsif not @locked           # Not locked
      update_self_movement
    end
    update_animation
  end
  #--------------------------------------------------------------------------
  # * Update While Moving
  #--------------------------------------------------------------------------
  def update_move
    distance = 2 ** @move_speed   # Convert to movement distance
    distance *= 2 if dash?        # If dashing, double it
    distance *= 6 if shoved?
    @real_x = [@real_x - distance, @x * 256].max if @x * 256 < @real_x
    @real_x = [@real_x + distance, @x * 256].min if @x * 256 > @real_x
    @real_y = [@real_y - distance, @y * 256].max if @y * 256 < @real_y
    @real_y = [@real_y + distance, @y * 256].min if @y * 256 > @real_y
    update_bush_depth unless moving?
    return if shoved?
    if @walk_anime
      @anime_count += 1.5
    elsif @step_anime
      @anime_count += 1
    end
  end
  #--------------------------------------------------------------------------
  # * Update Animation Count
  #--------------------------------------------------------------------------
  def update_animation
    speed = @move_speed + (dash? ? 1 : 0)
    special? ? mov_update = 14 : mov_update = 18
    return if special? && @o_container.nil?
    if @anime_count > mov_update - speed * 2
      # Roughly 10.5 frames per sprite change.
      if not @step_anime and @stop_count > 0
        @pattern = @original_pattern
      else
        if not_special?
          @pattern = (@pattern + 1) % 4
        else
          #@pattern = (@pattern + 1) % @o_container[move_dir_to_key].frames #% @o_container[move_dir_to_key].frames
          @pattern += 1 #if self.is_a?(Game_Player)
          if @pattern > @o_container[move_dir_to_key].frames
            @pattern = 1
          end
        end
      end
      @anime_count = 0
    end
  end

  def update_death
    return unless special?
    if dead? && $game_temp.in_battle && !@dead
      if @dead_wait < 0
        @dead_frame += 1
        @dead_wait = @character.o_container[:dead].wait
      end
      @dead_wait -= 1
      if @dead_frame > @character.o_container[:dead].frames
        @dead = true
        @dead_wait = 0
        @dead_frame = @character.o_container[:dead].frames
      end
    elsif !dead? && $game_temp.in_battle && @dead
      #resurrect
      if @dead_wait < 0
        @dead_frame += 1
        @dead_wait = @character.o_container[:dead].wait
      end
      @dead_wait -= 1
      if @dead_frame < 1
        @dead = false
        @dead_wait = 0
        @dead_frame = 0
      end
    end
  end

  def move_sprite_x
    return 0 if not_special?
    reset_o_animation if @o_container.nil?
    neg = 0
    neg = -1 if self.is_a?(Game_Player)
    return @o_container[move_dir_to_key].x + neg
  end

  def move_sprite_y
    return 0 if not_special?
    reset_o_animation if @o_container.nil?
    return @o_container[move_dir_to_key].y
  end

  def move_sprite_frames
    return 0 if not_special?
    reset_o_animation if @o_container.nil?
    return @o_container[move_dir_to_key].frames
  end

  def move_sprite_wait
    return if not_special?
    reset_o_animation if @o_container.nil?
    return @o_container[move_dir_to_key].wait
  end

  def move_dir_to_key
    dir8 ={ 1=>4, 2=>2, 3=>6, 4=>4, 5=>5, 6=>6, 7=>4, 8=>8, 9=>6 }
    #if dashing?
      #dash keys
    #else
    if $game_temp.in_battle
      case dir8[@direction]
        when 2
          :bat_move_down
        when 4
          :bat_move_left
        when 6
          :bat_move_right
        when 8
          :bat_move_up
        else
          :bat_idle
      end
    else
      case dir8[@direction]
        when 2
          :move_down
        when 4
          :move_left
        when 6
          :move_right
        when 8
          :move_up
        else
          :idle
      end
    end
    #end
  end

  # [[animation_sym, animation_type, custom_sequence, reverse], ...]
  def custom_animation_sequence(custom_sequence)
    return if not_special?
    custom_sequence.each do |seq|
      custom_animation(seq[0],seq[1],seq[2],seq[3])
    end
  end

  def custom_animation(animation_sym, animation_type=0, custom_sequence = [], reverse=false)
    return if not_special?
    @o_sequence.push([animation_sym, animation_type, custom_sequence, reverse])
  end

  def reverse_animation(animation_sym, animation_type=0, custom_sequence = [])
    return if not_special?
    custom_animation(animation_sym, animation_type, custom_sequence, true)
  end

  def o_sequence_running?
    @o_animation != nil
  end

  def o_sequence_has_items?
    @o_sequence.size > 0
  end

  def o_current_done?
    @o_next
  end

  def o_inactive?
    !o_sequence_running? && !o_sequence_has_items? && o_current_done?
  end

  def prepare_next_in_sequence
    @o_next = false
    node = @o_sequence.shift
    return if node.nil?
    @o_animation = @o_container[node[0]]
    @o_animation_type = node[1]
    @o_args = node[2]
    @o_reverse = node[3]
    @o_time = @o_animation.wait
    @o_wait = @o_animation.wait
    @o_frames = @o_animation.frames
    @o_reverse ? @o_pattern = @o_frames : @o_pattern = 0
    @o_x = @o_animation.x
    @o_y = @o_animation.y
    @o_next = false
  end

  def update_overwritten_animation
    #todo; prepare fork for custom animation sequencer
    # Currently only iterates through sequence and ends.
    #@o_sequence
    #return if !o_sequence_has_items? && !o_sequence_running? && !o_current_done?
    if special?
      #sequence not running, start sequence
      if o_inactive?
        return
      elsif (!o_sequence_running? && o_sequence_has_items?) || (o_sequence_has_items? && o_sequence_running? && o_current_done?)
        return prepare_next_in_sequence
      elsif o_sequence_running? && !o_sequence_has_items? && o_current_done?
        return reset_o_animation
      end
      if o_sequence_running?
        #check and shift sequence if last sequence done.
        case @o_animation_type
          when 0 # 0 - full sequence - start to end, 1-7, return to idle
            update_sequence_normal
          when 1 # 1 - full sequence lock - start to end, 1-7, stay on 7
            #todo
            update_sequence_lock
          when 2 # 2 - partial sequence lock - start to end, 1...7
            #todo
            update_sequence_lock
          when 3 # 3 - unlock sequence and reverse to start, from locked N, N-1
            #todo
            update_sequence_normal
          when 4 # 4 - unlock sequence and continue forward to completion, from locked N, N-7
            #todo
            update_sequence_normal
          when 5 # 5 - play set sequence, might run badly
            #todo
            update_custom_sequence
        end
      end
    end
  end

  # 0 - full sequence - start to end, 1-7, return to idle
  # 3 - unlock sequence and reverse to start, from locked N, N-1
  # 4 - unlock sequence and continue forward to completion, from locked N, N-7
  def update_sequence_normal
    if @o_wait > 0
      @o_wait -= 1
    end
    if @o_reverse
      if @o_wait <= 0
        @o_pattern -= 1
        @o_wait = @o_time
      end
      if @o_pattern <= 0
        @o_next = true
      end
    else
      if @o_wait <= 0
        @o_pattern += 1
        @o_wait = @o_time
      end
      if @o_pattern >= @o_frames
        @o_next = true
      end
    end
  end

  # 1 - full sequence lock - start to end, 1-7, stay on 7
  # must be manually reset
  # 2 - partial sequence lock - start to end, 1...7
  def update_sequence_lock
    if @o_wait > 0
      @o_wait -= 1
    end
    if @o_reverse
      if @o_wait <= 0 && @o_pattern > 0
        @o_pattern -= 1
        @o_wait = @o_time
      end
    else
      if @o_wait <= 0 && @o_pattern < @o_frames
        @o_pattern += 1
        @o_wait = @o_time
      end
    end
  end


  # 5 - play set sequence, might run badly
  def update_custom_sequence
    if @o_wait > 0
      @o_wait -= 1
    end
    if @o_args.size > 0
      if @o_wait <= 0 #&& @o_pattern > 0
        params = @o_args.shift
        @o_x = params[0]
        @o_y = params[1]
        @o_wait = params[2]
      end
    else
      @o_next = true
    end
  end


  def not_special?
    return !@special_sprite
  end

  def special?
    return @special_sprite
  end

  def set_special_sprite
    @special_sprite = @character_name.include?('~')
  end

  def overwritten_animation?
    return (!@o_sequence.empty? or @o_animation != nil)
  end

end

class Sequence_Node
  attr_reader :x, :y, :wait
  def initialize(x,y,wait)
    @x = x
    @y = y
    @wait = wait
  end
end

class Game_Interpreter

  def custom_animation(target, index, animation_key=nil)
    return if $game_map.nil?
    case target
      when :self
        return if @character.nil?
        @character.custom_animation(index)
      when :player
        return if $game_party.sorted_players[$game_party.sorted_members[index]].nil?
        $game_party.sorted_players[$game_party.sorted_members[index]].custom_animation(animation_key)
      when :enemy
        return
      when :event
        return unless $game_map.events.keys.include?(index)
        $game_map.events[index].custom_animation(animation_key)
      when :leader
        $game_player.custom_animation(index)
    end
  end

end

class Sprite_Character < Sprite_Base

  def update_src_rect
    return if @character.nil?
    @shove_interval = 0 if @shove_interval.nil?
    if @tile_id == 0 && !@character.is_a_item?# && !animation?
      #Todo: include battle direction shift
      #Todo: create un-sheath animation
      if @character.shoved?
        perform_shove_startup
      elsif @shove_interval > 0 && !@character.shoved?
        perform_shove_cooldown
      elsif @character.dead?
        perform_death_animation
      elsif overwritten_animation?
        perform_custom_animation
      else
        perform_move_animation
      end
    end
  end

  def perform_death_animation
    #self.src_rect.set()
    #catch for death stop, meaning no frame update
    return unless @character.special?
    return if @character.o_container.nil?
    sx = (@character.o_container[:dead].x + @character.dead_frame) * @cw
    sy = @character.o_container[:dead].y * @ch
    self.src_rect.set(sx, sy, @cw, @ch)
  end


  def resurrect_animation

  end

  def overwritten_animation?
    @character.overwritten_animation?
  end

  def perform_custom_animation
    sx = (@character.o_x + @character.o_pattern) * @cw
    sy = @character.o_y * @ch
    self.src_rect.set(sx, sy, @cw, @ch)
  end

  def perform_move_animation
    @shove_interval = 0
    @shove_counter = 0
    if @character.special?
      #p 'updating special'
      #p @character.o_container.inspect if @character.o_container.nil?
      #p @character.character_name + ' ' + @character.pattern.to_s + ' ' + @character.move_sprite_x.to_s + ' ' + @character.move_sprite_y.to_s
      sx = (@character.move_sprite_x + @character.pattern) * @cw
      sy = @character.move_sprite_y * @ch
      self.src_rect.set(sx, sy, @cw, @ch)
    else
      index = @character.character_index
      unless posing?
        @pose_pattern = nil
        @pose_duration = nil
      end
      if posing?
        pose_creation
      elsif dashing? and diagonal?
        @index_value = index+3
      elsif dashing?
        @index_value = index+2
      elsif diagonal?
        @index_value = index+1
      else
        @index_value = index
      end
      @dir8 = DIR8_FRAMES[@character.direction]
      self.mirror = mirror?
      #todo: define fast method of testing numbers
      #todo put forks to maintain new movement sprite amounts
      pattern = @character.pattern < 3 ? @character.pattern : 1
      sx = (@index_value % 4 * 3 + pattern) * @cw
      sy = (@index_value / 4 * 4 + (@dir8 - 2) / 2) * @ch
      self.src_rect.set(sx, sy, @cw, @ch)
    end
  end


  #def perform_move_animation
  #  #if @character.not_special?
  #  #  overwritten_perform_move_animation
  #  #else
  #    @shove_interval = 0
  #    @shove_counter = 0
  #    index = @character.character_index
  #    unless posing?
  #      @pose_pattern = nil
  #      @pose_duration = nil
  #    end
  #    if posing?
  #      pose_creation
  #    elsif dashing? and diagonal?
  #      @index_value = index+3
  #    elsif dashing?
  #      @index_value = index+2
  #    elsif diagonal?
  #      @index_value = index+1
  #    else
  #      @index_value = index
  #    end
  #    pattern = @character.pattern < 3 ? @character.pattern : 1
  #    @dir8 = DIR8_FRAMES[@character.direction]
  #    self.mirror = mirror?
  #    #todo: define fast method of testing numbers
  #    sx = (@index_value % 4 * 3 + pattern) * @cw
  #    sy = (@index_value / 4 * 4 + (@dir8 - 2) / 2) * @ch
  #    self.src_rect.set(sx, sy, @cw, @ch)
  #  #end
  #end

=begin
    if @character.not_special?
      overwritten_perform_move_animation
    else
      @shove_interval = 0
      @shove_counter = 0
      index = @character.character_index
      unless posing?
        @pose_pattern = nil
        @pose_duration = nil
      end
      if posing?
        pose_creation
      elsif dashing? and diagonal?
        @index_value = index+3
      elsif dashing?
        @index_value = index+2
      elsif diagonal?
        @index_value = index+1
      else
        @index_value = index
      end
      pattern = @character.pattern < 3 ? @character.pattern : 1
      @dir8 = DIR8_FRAMES[@character.direction]
      self.mirror = mirror?

      #todo: define fast method of testing numbers
      sx = (@index_value % 4 * 3 + pattern) * @cw
      sy = (@index_value / 4 * 4 + (@dir8 - 2) / 2) * @ch
      self.src_rect.set(sx, sy, @cw, @ch)
    end
=end

end