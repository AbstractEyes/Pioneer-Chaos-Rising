class Sprite_Tile < Sprite
  attr_accessor :offset
  attr_accessor :frames
  attr_accessor :difference

  def initialize(viewport=nil)
    super(viewport)
    @frames = 0
    @difference = nil
    @offset = nil
  end

  def update
    super
    @frames -= 1 if @frames > 0
  end

  def done?
    return @frames <= 0
  end
end