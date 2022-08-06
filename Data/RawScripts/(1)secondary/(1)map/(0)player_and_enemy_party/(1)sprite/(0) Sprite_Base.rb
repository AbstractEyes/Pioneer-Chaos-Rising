#==============================================================================
# ** Sprite_Base
#------------------------------------------------------------------------------
#  A sprite class with animation display processing added.
#==============================================================================

# Each of these must be contained within a hash array.
class Forked_Animation
  attr_accessor :animation
  attr_accessor :animation_duration
  attr_accessor :animation_mirror
  attr_accessor :animation_bitmap1
  attr_accessor :animation_bitmap2
  attr_accessor :animation_sprites
  attr_accessor :animation_ox
  attr_accessor :animation_oy
  # Required Object Variables:
  def initialize(animation, mirror = false)
    @animation = animation
    @animation_duration = @animation.frame_max * 4 + 1
    @animation_mirror = mirror
    
    animation1_name = @animation.animation1_name
    animation1_hue = @animation.animation1_hue
    animation2_name = @animation.animation2_name
    animation2_hue = @animation.animation2_hue
    @animation_bitmap1 = (Cache.animation(animation1_name, animation1_hue))
    @animation_bitmap2 = (Cache.animation(animation2_name, animation2_hue))
    @animation_sprites = []
  end
  
end

class Sprite_Base < Sprite
  #--------------------------------------------------------------------------
  # * Class Variable
  #--------------------------------------------------------------------------
  @@animations = []
  @@_reference_count = {}
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     viewport : viewport
  #--------------------------------------------------------------------------
  def initialize(viewport = nil)
    super(viewport)
    @use_sprite = true          # Sprite use flag
    @animation_duration = 0     # Remaining animation time
    @animation_list = []
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    dispose_animation
    #return if @animation_list.empty?
    for index in 0...@animation_list.size
      dispose_target_animation(index)
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    if @animation != nil
      @animation_duration -= 1
      if @animation_duration % 4 == 0
        update_animation
      end
    end
    @animation_list = [] if @animation_list.nil?
    if !@animation_list.empty?
      @animation_list.compact! if @animation_list.include?(nil)
      for i in 0...@animation_list.size
        animation = @animation_list[i]
        animation.animation_duration -= 1
        if animation.animation_duration % 4 == 0
          update_target_animation(i)
        end
      end
    end
    @@animations.clear
  end
  #--------------------------------------------------------------------------
  # * Determine if animation is being displayed
  #--------------------------------------------------------------------------
  def animation?
    return @animation != nil || @animation_list.size > 0
  end
  #--------------------------------------------------------------------------
  # * Start Animation
  #--------------------------------------------------------------------------
  def start_f_animation(animation, mirror = false)
    animation_object = Forked_Animation.new(animation, mirror)
    return if animation == nil
    @animation_list.push(animation_object)
    handle_references
    @animation_list[@animation_list.size - 1].animation_sprites = []
    
    if animation.position != 3 or not @@animations.include?(animation)
      if @use_sprite
        for i in 0..15
          sprite = ::Sprite.new(viewport)
          sprite.visible = false
          @animation_list[@animation_list.size - 1].animation_sprites.push(sprite)
        end
        unless @@animations.include?(animation)
          @@animations.push(animation)
        end
      end
    end
    if @animation_list[@animation_list.size - 1].animation.position == 3
      if viewport == nil
        @animation_list[@animation_list.size - 1].animation_ox = $screen_width / 2
        @animation_list[@animation_list.size - 1].animation_oy = $screen_height / 2
      else
        @animation_list[@animation_list.size - 1].animation_ox = viewport.rect.width / 2
        @animation_list[@animation_list.size - 1].animation_oy = viewport.rect.height / 2
      end
    else
      @animation_list[@animation_list.size - 1].animation_ox = x - ox + width / 2
      @animation_list[@animation_list.size - 1].animation_oy = y - oy + height / 2
      if @animation_list[@animation_list.size - 1].animation.position == 0
        @animation_list[@animation_list.size - 1].animation_oy -= height / 2
      elsif @animation_list[@animation_list.size - 1].animation.position == 2
        @animation_list[@animation_list.size - 1].animation_oy += height / 2
      end
    end
  end
  
  def handle_references
    for animation in @animation_list
      next if animation.nil?
      next if animation.animation_bitmap1.nil?
      next if animation.animation_bitmap2.nil?
      if @@_reference_count.include?(animation.animation_bitmap1)
        @@_reference_count[animation.animation_bitmap1] += 1
      else
        @@_reference_count[animation.animation_bitmap1] = 1
      end
      if @@_reference_count.include?(animation.animation_bitmap2)
        @@_reference_count[animation.animation_bitmap2] += 1
      else
        @@_reference_count[animation.animation_bitmap2] = 1
      end
      #Graphics.frame_reset
    end
  end
  
  #--------------------------------------------------------------------------
  # * Dispose of Animation
  #--------------------------------------------------------------------------
  def dispose_target_animation(index)
    animation = @animation_list[index]
    if animation.animation_bitmap1 != nil
      @@_reference_count[animation.animation_bitmap1] -= 1
      if @@_reference_count[animation.animation_bitmap1] == 0
        animation.animation_bitmap1.dispose
      end
    end
    if animation.animation_bitmap2 != nil
      @@_reference_count[animation.animation_bitmap2] -= 1
      if @@_reference_count[animation.animation_bitmap2] == 0
        animation.animation_bitmap2.dispose
      end
    end
    animation.animation_bitmap1 = nil
    animation.animation_bitmap2 = nil
    #Targeting battlers added.
    if @targeting_battlers != nil
      for i in 0...@targeting_battlers.size
        n = @targeting_battlers.shift if @targeting_battlers[i][0] == @animation_list[index].animation.id
      end
    end
    if @animation_list[index].animation_sprites != nil
      for sprite in @animation_list[index].animation_sprites
        sprite.dispose
      end
      @animation_list[index].animation_sprites = nil
      @animation_list[index] = nil
    end
    @animation_list[index] = nil
  end
  #--------------------------------------------------------------------------
  # * Update Animation
  #--------------------------------------------------------------------------
  def update_target_animation(index)
    animation_object = @animation_list[index]
    animation = animation_object.animation
    if animation_object.animation_duration > 0
      frame_index = animation.frame_max - (animation_object.animation_duration + 3) / 4
      animation_f_set_sprites(animation_object,animation.frames[frame_index])
      for timing in animation.timings
        if timing.frame == frame_index
          animation_process_timing(timing)
        end
      end
    else
      dispose_target_animation(index)
    end
  end
  #--------------------------------------------------------------------------
  # * Set Animation Sprite
  #     frame : Frame data ((0X)RPG.rb::Animation::Frame)
  #--------------------------------------------------------------------------
  def animation_f_set_sprites(animation, frame)
    cell_data = frame.cell_data
    for i in 0..15
      sprite = animation.animation_sprites[i]
      next if sprite == nil
      pattern = cell_data[i, 0]
      if pattern == nil or pattern == -1
        sprite.visible = false
        next
      end
      if pattern < 100
        sprite.bitmap = animation.animation_bitmap1
      else
        sprite.bitmap = animation.animation_bitmap2
      end
      sprite.visible = true
      sprite.src_rect.set(pattern % 5 * 192,
        pattern % 100 / 5 * 192, 192, 192)
      if @animation_mirror
        sprite.x = animation.animation_ox - cell_data[i, 1]
        sprite.y = animation.animation_oy + cell_data[i, 2]
        sprite.angle = (360 - cell_data[i, 4])
        sprite.mirror = (cell_data[i, 5] == 0)
      else
        sprite.x = animation.animation_ox + cell_data[i, 1]
        sprite.y = animation.animation_oy + cell_data[i, 2]
        sprite.angle = cell_data[i, 4]
        sprite.mirror = (cell_data[i, 5] == 1)
      end
      sprite.z = self.z + 300 + i
      sprite.ox = 96
      sprite.oy = 96
      sprite.zoom_x = cell_data[i, 3] / 100.0
      sprite.zoom_y = cell_data[i, 3] / 100.0
      sprite.opacity = cell_data[i, 6] * self.opacity / 255.0
      sprite.blend_type = cell_data[i, 7]
    end
  end
  #--------------------------------------------------------------------------
  # * SE and Flash Timing Processing
  #     timing : timing data ((0X)RPG.rb::Animation::Timing)
  #--------------------------------------------------------------------------
  def animation_process_timing(timing)
    timing.se.play
    case timing.flash_scope
    when 1
      self.flash(timing.flash_color, timing.flash_duration * 4)
    when 2
      if viewport != nil
        viewport.flash(timing.flash_color, timing.flash_duration * 4)
      end
    when 3
      self.flash(nil, timing.flash_duration * 4)
    end
  end
end