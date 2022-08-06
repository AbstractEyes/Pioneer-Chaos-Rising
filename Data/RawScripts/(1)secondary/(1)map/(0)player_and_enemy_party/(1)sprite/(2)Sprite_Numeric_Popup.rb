class Sprite_NumericPopup < Sprite
  attr_reader :executing
  attr_reader :color
  attr_reader :host_id

  def initialize(viewport=nil)
    super(viewport)
    @wait = 0
    @fit = false
    @executing = false
    @animate = 1
    @speed = 4
    @type = 0
    @events = []
    @halt = false
    @color = nil
    @host_id = -1
  end

  def set_host(id)
    @host_id = id
  end

  def matching_host?(id)
    return @host_id == id
  end

  def dispose
    super
  end

  def update
    super
    if @wait > 0
      @wait -= 1
      return if @speed == 0
      if @wait % @speed == 0
        case @animate
          when 1
            self.oy -= 1
          when 2
            self.oy += 1
          when 3
            self.ox -= 1
          when 4
            self.ox += 1
          when 5
            self.oy -= 1
            self.ox += 1
          when 6
            self.oy += 1
            self.ox += 1
          when 7
            self.oy -= 1
            self.ox -= 1
          when 8
            self.oy += 1
            self.ox -= 1
        end
      end
    else
      @executing = true
    end
  end

  def set_number(host, value, color = PHI.color(:RED))
    @color = color
    @wait = 30
    @fit = false
    @executing = false
    @animate = rand(8)+1
    @speed = 6
    self.bitmap = Bitmap.new(64,32)
    self.bitmap.font.color = @color
    self.bitmap.draw_text(0, 0, 64, 32, value.to_s)
  end

end