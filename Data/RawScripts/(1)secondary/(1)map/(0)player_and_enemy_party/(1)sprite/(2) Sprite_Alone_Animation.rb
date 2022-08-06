class Sprite_Alone_Animation < Sprite_Base

  def initialize(viewport, animation_id, x, y)
    super(viewport)
    @animation_id = animation_id
    self.x = x
    self.y = y
    update
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    super
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    if @animation.nil? and @animation_id != 0
      @animation = $data_animations[@animation_id]
      start_animation(@animation)
      @animation_id = 0
    end
  end
  
  def set_animation(animation_id,x,y)
    @animation_id, self.x, self.y = animation_id, x, y
  end
  
end

class Game_Interpreter
  
  
end
