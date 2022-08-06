class Window_MessagePopup < Window_Base
  attr_reader :executing
  attr_reader :type
  attr_reader :events
  attr_accessor :text
  attr_reader :item
  attr_reader :failed
  
  def initialize(x,y,width,height)
    super(x,y,width,height)
    create_contents
    @wait = 0
    @fit = false
    @executing = false
    @animate = 1
    @speed = 4
    @type = 0
    @events = []
    @halt = false
    @text = ''
    @item = false
    @failed = false
  end
  
  def add_event(event)
    @events.push event
  end

  def halt?
    return @halt
  end

  def fit
    @fit = true
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
          self.y -= 1
        when 2
          self.y += 1
        when 3
          self.x -= 1
        when 4
          self.x += 1
        when 5
          self.y -= 1
          self.x += 1
        when 6
          self.y += 1
          self.x += 1
        when 7
          self.y -= 1
          self.x -= 1
        when 8
          self.y += 1
          self.x -= 1
        end
      end
    else
      @executing = true
    end
  end

=begin
  @text = input string
  @opacity = input integer, message box opacity
  @x = input integer, x value of window position
  @y = input integer, y value of window position
  @width = input integer, width of the window
  @height = input integer, height of the window
  @color = Color, color class object for text color
  @animate = integer, determines the direction of the window
  @wait = integer, amount of frames to decrement before disposal events fire
=end
  
  def popup(text, opacity=self.opacity, x=self.x, y=self.x,
            width=self.width, height=self.height, color=normal_color, animate=0,
            speed=1, wait=60, halt=false, font_size=self.contents.font.size)
    self.text = text
    self.opacity = opacity unless opacity.nil?
    self.x = x unless x.nil?
    self.y = y unless y.nil?
    width.nil? ? self.width = self.contents.text_size(text).width + 32 : self.width = width
    self.height = height unless height.nil?
    @wait = 30 unless wait.nil?
    @wait = wait unless wait.nil?
    @animate = animate unless animate.nil?
    @speed = speed unless speed.nil?
    @halt = halt unless halt.nil?
    self.contents.font.size = font_size unless font_size.nil?
    rect = Rect.new(0,0,self.width,WLH)
    self.contents.clear
    create_contents
    self.contents.font.color = color unless color.nil?
    self.contents.draw_text(rect,text)
    update
  end

  def item_popup(item_id, opacity=self.opacity, x=self.x, y=self.x,
                 width=self.width, height=self.height, color=normal_color, animate=0,
                 speed=1, wait=60, halt=false, font_size=self.contents.font.size)
    popup('+1   ' + $data_items[item_id.to_i].name,opacity,x,y,width,height,color,animate,speed,wait,halt,font_size)
    draw_map_icon($data_items[item_id.to_i].icon_index, 20, 0)
  end

  def item_full_popup(item_id, opacity=self.opacity, x=self.x, y=self.x,
      width=self.width, height=self.height, color=normal_color, animate=0,
      speed=1, wait=60, halt=false, font_size=self.contents.font.size)
    @item = true
    popup('Full   ' + $data_items[item_id.to_i].name,opacity,x,y,width,height,color,animate,speed,wait,halt,font_size)
    draw_map_icon($data_items[item_id.to_i].icon_index, 40, 0)
  end

  def inventory_full_popup(item_id, opacity=self.opacity, x=self.x, y=self.x,
                      width=self.width, height=self.height, color=normal_color, animate=0,
                      speed=1, wait=60, halt=false, font_size=self.contents.font.size)
    @failed = true
    popup('Inventory Full   ' + $data_items[item_id.to_i].name,opacity,x,y,width,height,color,animate,speed,wait,halt,font_size)
    draw_map_icon($data_items[item_id.to_i].icon_index, 114, 0)
  end
  
end