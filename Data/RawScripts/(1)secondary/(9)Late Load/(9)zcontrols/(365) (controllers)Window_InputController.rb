class Window_TypeInputController < Window_Selectable
  
  def initialize(x,y,width,height)
    super(x,y,width,height)
    @column_max = 3
    refresh
  end
  
  def refresh
    @data = [ "Configure", "Configure All", "Return" ]
    self.contents.clear
    create_contents
    @item_max = @data.size
    for i in 0...@item_max
      rect = Rect.new(i*(width/@column_max),0,width,WLH)
      self.contents.draw_text(rect,@data[i])
    end
  end
  
end

class Window_ControllerConfigureIndividual < Window_Selectable
  
  def initialize(x,y,width,height)
    super(x,y,width,height)
    @column_max = 1
    @key_options = Input::CONTROLLER_KEY.clone
    @input = $input_config
    @input_options = @input.get_inputs
    refresh
  end
  
  def key
    return @input_options[@index][1][2]
  end
  
  def key=(new_key)
    @input_options[@index][1][2] = new_key
  end
  
  def refresh
    self.contents.clear
    create_contents
    @item_max = @input_options.keys.size
    for i in 0...@item_max
      draw_input_option(i)
    end
  end
  
  def draw_input_option(index)
    rect = Rect.new(0,index*WLH,width,WLH)
    item = @input_options[index][1][2]
    self.contents.draw_text(rect,get_key(item))
  end
  
  def get_key(input_value)
    cur_key = @key_options.index(input_value).to_s
    cur_key = "None" if cur_key.empty?
    return cur_key
  end
  
  def all_bound?
    
  end

end

class Window_ControllerConfigureAll < Window_Base
  attr_accessor :button
  attr_accessor :indecks
  
  def initialize(x,y,width,height)
    super(x,y,width,height)
    @key_options = Input::CONTROLLER_KEY.clone
    @input = $input_config
    @input_options = @input.current_inputs
    @button = -1
  end
  
  def refresh
    self.contents.clear
    create_contents
    rect = Rect.new(0,0,width,WLH)
    if !@input_options[@indecks].nil?
      self.contents.draw_text(rect, "Set Button: " + @input_options[@indecks][0])
      rect.y += WLH
      self.contents.draw_text(rect, "From: " + get_key(@input_options[@indecks][1][2]))
    else
      self.contents.draw_text(rect, "Inputs complete!")
    end
  end
  
  def key
    return @input_options[@indecks][1][2]
  end
  
  def set_key(key)
    @input.current_inputs[@indecks][1][2] = key
  end
  
  def get_key(input_value)
    cur_key = @key_options.index(input_value).to_s
    cur_key = "None" if cur_key.empty?
    return cur_key
  end
  
end