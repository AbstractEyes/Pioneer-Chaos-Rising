class Window_InputHelp < Window_Base
  def initialize(x,y,width,height)
    super(x,y,width,height)
  end
  
  def set_text(new_text)
    self.contents.clear
    create_contents
    self.contents.draw_text(0,0,width,WLH,new_text)
  end
  
end

class Window_TypeSetChoice < Window_Selectable
  
  def initialize(x,y,width,height)
    super(x,y,width,height)
    @column_max = 2
    @index = 0
    @types = ["Change", "Nevermind"]
    refresh
  end
  
  def refresh
    self.contents.clear
    create_contents
    @item_max = 2
    for i in 0...@item_max
      draw_type(i)
    end
  end
  
  def draw_type(index)
    rect = Rect.new(0,0,width/@column_max,WLH)
    rect.x = (index*(width/@column_max))
    self.contents.draw_text(rect, @types[index])
  end
  
end

class Window_InputTypeSet < Window_Selectable
  def initialize(x,y,width,height)
    super(x,y,width,height)
    @column_max = 3
    @index = 0
    @types = ["Type A", "Type B", "Custom"]
    refresh
  end
  
  def refresh
    self.contents.clear
    create_contents
    @item_max = 3
    for i in 0...@item_max
      draw_type(i)
    end
  end
  
  def draw_type(index)
    rect = Rect.new(0,0,width/@column_max,WLH)
    rect.x = (index*(width/@column_max))
    self.contents.font.color = normal_color
    self.contents.font.color = PHI::COLORS[:GOLD] if index == $keyboard_preset - 1
    self.contents.draw_text(rect, @types[index])
  end
  
end

class Window_InputType < Window_Selectable
  
  def initialize(x,y,width,height)
    super(x,y,width,height)
    self.active = false
    @key_options = Input::Key.clone
    @input = $input_config
    @input_options = @input.get_inputs
    refresh
  end
  
  # Refresh draws the list.
  def refresh
    self.contents.clear
    create_contents
    @item_max = @input_options.keys.size
    for i in 0...@item_max
      draw_input_option(i)
    end
  end

  # Draw a single input option top down.
  def draw_input_option(index)
    rect = Rect.new(0, index*WLH,width,WLH)
    self.contents.draw_text(rect, find_key(index))
  end
  
  # Returns the key type based on the key index.
  def find_key(index)
    return @input_options[index][0]
  end
      
end

# ---------------------------------------------------------------------------- #
# Window_InputSelect #
# ------------------ #
# This window is important for binding and rebinding inputs.
# Should be self encapsulating, handles the input setting and
# removing the inputs from the Game_InputConfig class.
# ---------------------------------------------------------------------------- #

class Window_InputSelect < Window_Selectable
  
  def initialize(x,y,width,height)
    super(x,y,width,height)
    @column_max = 2
    @key_options = Input::Key.clone
    @input = $input_config
    @input_data_options = @input.get_inputs
    @input_viewable_options = @input.get_inputs.clone
    refresh
  end

  # Draws the side by side keys for the 
  def refresh(preset=0)
    self.contents.clear
    set_preset(preset)
    @item_max = @input_viewable_options.keys.size * 2
    create_contents
    for i in 0...@item_max / 2
      draw_input_option(i)
    end
  end
  
  def set_preset(preset)
    case preset
    when 1
      @input_viewable_options = @input.keyboard_type_a.clone
    when 2
      @input_viewable_options = @input.keyboard_type_b.clone
    when 3
      @input_viewable_options = @input.keyboard_custom.clone
    end
  end
  
  def set_inputs
    case $keyboard_preset
    when 1
      @input.current_inputs = @input.keyboard_type_a.clone
    when 2
      @input.current_inputs = @input.keyboard_type_b.clone
    when 3
      if @index == $keyboard_preset
        @input.keyboard_custom = @input_viewable_options.clone
        @input.current_inputs = @input_viewable_options.clone
      end
    end
  end
  
  # Gets the full key data from the (0)options.
  def key_data
    return @input_viewable_options[@index / @column_max]
  end

  # Returns the value of the currently selected key.
  def key
    return @input_viewable_options[@index / @column_max][1][@index % @column_max]
  end
  
  def key=(new_value)
    @input_viewable_options[@index / @column_max][1][@index % @column_max] = new_value
  end
  
  def set_key(new_value)
    @input_viewable_options[@index / @column_max][1][@index % @column_max] = new_value
  end
  
  # Unbind Keys #
  # This function is used to unbind from the window each matching input.
  def unbind_keys(new_value, force_unbind)
    for x in 0...@input_viewable_options.keys.size
      inputs = @input_viewable_options[x][1]
      for y in 0...inputs.size
        next if @index / @column_max == x and
                @index % @column_max == y and force_unbind == 0
        @input_viewable_options[x][1][y] = -1 if @input_viewable_options[x][1][y] == new_value
      end
    end
  end
  
  def all_bound?
    keys = @key_options
    for x in 0...@input_viewable_options.keys.size
      inputs = @input_viewable_options[x][1]
      check_input = false
      for input in inputs
        check_input = true if input >= 0 and input <= 230
      end
      return false if check_input == false
    end
  end
  
  # Returns the name of the key type.
  def key_type
    return @input_viewable_options[@index / @column_max][0]
  end
  
  def draw_input_option(index)
    rect = Rect.new(0,index*WLH,width,WLH)
    item1 = @input_viewable_options[index][1][0]
    item2 = @input_viewable_options[index][1][1]
    self.contents.draw_text(rect,get_key(item1))
    rect.x = width/2
    self.contents.draw_text(rect,get_key(item2))
  end
    
  def get_key(int_value)
    return int_value if !int_value.is_a?(Integer)
    for cur_key in @key_options.keys
      if @key_options[cur_key] == int_value
        return cur_key
      end
    end
    if int_value < 530
      return "None"
    else
      return nil
    end
  end
  
end

class Window_InputSetHelp < Window_Base
  
  def initialize(x,y,width,height)
    super(x,y,width,height)
    @key_options = Input::Key
    @input = $input_config
    @input_options = @input.get_inputs
  end
  
end

class Window_ButtonSet < Window_Base
  
  def initialize(x,y,width,height)
    super(x,y,width,height)
    @key_options = Input::Key
    @input = $input_config
    @input_options = @input.get_inputs
    @key_int = -1
    @key = "None"
  end
  
  def refresh(key_type, key)
    self.contents.clear
    create_contents
    self.contents.draw_text(0,0,width,WLH, "Key type: " + key_type)
    self.contents.draw_text(0,WLH,width,WLH, "Replace: " + get_key(key) + " with which key?")
    self.contents.draw_text(0,WLH*2,width,WLH, "Press key twice to set new key.")
    self.contents.draw_text(0,WLH*3,width,WLH, "New Key: " + @key)
  end
  
  def set_key(key_int)
    @key_int = key_int
    @key = get_key(key_int)
  end
  
  def get_key(int_value)
    return int_value if !int_value.is_a?(Integer)
    for cur_key in @key_options.keys
      if @key_options[cur_key] == int_value
        return cur_key
      end
    end
    if int_value < 530
      return "None"
    else
      return nil
    end
  end

end