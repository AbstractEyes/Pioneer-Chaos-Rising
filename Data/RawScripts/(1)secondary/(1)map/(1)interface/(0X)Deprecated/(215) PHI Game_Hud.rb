class Hud_Container
  attr_accessor :graphics
  
  def initialize
    @graphics = []
    @visible = true
  end

  def viewport=(viewport_in)
    @graphics.each do |graphic|
      graphic.viewport = viewport_in unless graphic.nil?
    end
  end

  def dispose
    @graphics.each do |graphic|
      graphic.dispose unless graphic.nil?
    end
    @graphics.clear
  end

  def update
    @graphics.each do |graphic|
      graphic.update unless graphic.nil?
    end
  end
  
  def refresh
    @graphics.each do |graphic|
      graphic.refresh unless graphic.nil?
    end
  end

  def show_hud
    @graphics.each do |graphic|
      graphic.visible = true unless graphic.nil?
    end
  end
  
  def hide_hud
    @graphics.each do |graphic|
      graphic.visible = false unless graphic.nil?
    end
  end

end