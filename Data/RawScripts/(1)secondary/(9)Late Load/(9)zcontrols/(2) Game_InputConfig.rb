class Game_InputConfig
  attr_accessor :current_inputs
  attr_accessor :keyboard_custom
  attr_reader   :keyboard_type_a
  attr_reader   :keyboard_type_b
  
  def initialize
    # Inputs for the custom inputs.
    $keyboard_preset = $system.config[:KB_Preset][1].to_i
    object_setup
    set_inputs($keyboard_preset)
  end
  
  def object_setup
    @current_inputs = {
      0       =>  ["Up",            Input.UP.clone],
      1       =>  ["Down",          Input.DOWN.clone],
      2       =>  ["Left",          Input.LEFT.clone],
      3       =>  ["Right",         Input.RIGHT.clone],
      4       =>  ["Dash",          Input.A.clone],
      5       =>  ["Cancel",        Input.B.clone],
      6       =>  ["Confirm",       Input.C.clone],
      7       =>  ["Display",       Input.X.clone],
      8       =>  ["Menu",          Input.Y.clone],
      9       =>  ["Pause",         Input.Z.clone],
      10      =>  ["PageUp",        Input.L.clone],
      11      =>  ["PageDown",      Input.R.clone],
    }
    @keyboard_custom = {
      0       =>  ["Up",            Input.UP.clone],
      1       =>  ["Down",          Input.DOWN.clone],
      2       =>  ["Left",          Input.LEFT.clone],
      3       =>  ["Right",         Input.RIGHT.clone],
      4       =>  ["Dash",          Input.A.clone],
      5       =>  ["Cancel",        Input.B.clone],
      6       =>  ["Confirm",       Input.C.clone],
      7       =>  ["Display",       Input.X.clone],
      8       =>  ["Menu",          Input.Y.clone],
      9       =>  ["Pause",         Input.Z.clone],
      10      =>  ["PageUp",        Input.L.clone],
      11      =>  ["PageDown",      Input.R.clone],
    }  

    @keyboard_type_a = {
      0       =>  ["Up",            [87,  38, Input.UP.clone[2]]],
      1       =>  ["Down",          [83,  40, Input.DOWN.clone[2]]],
      2       =>  ["Left",          [65,  37, Input.LEFT.clone[2]]],
      3       =>  ["Right",         [68,  39, Input.RIGHT.clone[2]]],
      4       =>  ["Dash",          [96,  16, Input.A.clone[2]]],
      5       =>  ["Cancel",        [101, 75, Input.B.clone[2]]],
      6       =>  ["Confirm",       [100, 74, Input.C.clone[2]]],
      7       =>  ["Display",       [103, 85, Input.X.clone[2]]],
      8       =>  ["Menu",          [104, -1, Input.Y.clone[2]]],
      9       =>  ["Pause",         [80,  -1, Input.Z.clone[2]]],
      10      =>  ["PageUp",        [104, 73, Input.L.clone[2]]],
      11      =>  ["PageDown",      [105, 79, Input.R.clone[2]]],
    }

    @keyboard_type_b = {
      0       =>  ["Up",            [38, -1, Input.UP.clone[2]]],
      1       =>  ["Down",          [40, -1, Input.DOWN.clone[2]]],
      2       =>  ["Left",          [37, -1, Input.LEFT.clone[2]]],
      3       =>  ["Right",         [39, -1, Input.RIGHT.clone[2]]],
      4       =>  ["Dash",          [16, -1, Input.A.clone[2]]],
      5       =>  ["Cancel",        [83, -1, Input.B.clone[2]]],
      6       =>  ["Confirm",       [65, -1, Input.C.clone[2]]],
      7       =>  ["Display",       [81, -1, Input.X.clone[2]]],
      8       =>  ["Menu",          [49, -1, Input.Y.clone[2]]],
      9       =>  ["Pause",         [32, -1, Input.Z.clone[2]]],
      10      =>  ["PageUp",        [87, -1, Input.L.clone[2]]],
      11      =>  ["PageDown",      [69, -1, Input.R.clone[2]]],
    }
    
    @controller_custom = {
      0       =>  ["Up",            [Input.UP.clone[2]]],
      1       =>  ["Down",          [Input.DOWN.clone[2]]],
      2       =>  ["Left",          [Input.LEFT.clone[2]]],
      3       =>  ["Right",         [Input.RIGHT.clone[2]]],
      4       =>  ["Dash",          [Input.A.clone[2]]],
      5       =>  ["Cancel",        [Input.B.clone[2]]],
      6       =>  ["Confirm",       [Input.C.clone[2]]],
      7       =>  ["Display",       [Input.X.clone[2]]],
      8       =>  ["Menu",          [Input.Y.clone[2]]],
      9       =>  ["Pause",         [Input.Z.clone[2]]],
      10      =>  ["PageUp",        [Input.L.clone[2]]],
      11      =>  ["PageDown",      [Input.R.clone[2]]],
    }
  end
  
  # Gets the list of inputs for the input scene.
  def get_inputs
    return @current_inputs
  end
  
  def get_custom
    return @keyboard_custom
  end
  
  def get_type_a
    return @keyboard_type_a
  end
  
  def get_type_b
    return @keyboard_type_b
  end
  
  def get_controller_inputs
    return @current_inputs
  end
  
  # Sets the inputs to the Input object self methods.
  def set_inputs(type=$keyboard_preset)
    case type
    # Type A
    when 1
      @current_inputs = @keyboard_type_a.clone
    # Type B
    when 2
      @current_inputs = @keyboard_type_b.clone
    when 3
      @current_inputs = @keyboard_custom.clone
    end
    finish_setting_inputs
  end
  
  def finish_setting_inputs
    for clone_key in @current_inputs.keys
      key_name = @current_inputs[clone_key][0].clone
      key_data = @current_inputs[clone_key][1].clone
      a,b,c = key_data[0],key_data[1],key_data[2]
      if key_name == "Up"
        Input.UP = [a,b,c]
      elsif key_name == "Down"
        Input.DOWN = [a,b,c]
      elsif key_name == "Left"
        Input.LEFT = [a,b,c]
      elsif key_name == "Right"
        Input.RIGHT = [a,b,c]
      elsif key_name == "Dash"
        Input.A = [a,b,c]
      elsif key_name == "Cancel"
        Input.B = [a,b,c]
      elsif key_name == "Confirm"
        Input.C = [a,b,c]
      elsif key_name == "Display"
        Input.X = [a,b,c]
      elsif key_name == "Menu"
        Input.Y = [a,b,c]
      elsif key_name == "Pause"
        Input.Z = [a,b,c]
      elsif key_name == "PageUp"
        Input.L = [a,b,c]
      elsif key_name == "PageDown"
        Input.R = [a,b,c]
      end
    end
  end
  
  def save_inputs
    File.open("System/keyboard_inputs.txt", 'w') do |file|
      file.puts("Keyboard Preset " + $keyboard_preset.to_s)
      for i in 0...@current_inputs.keys.size
        key_name = @current_inputs[i][0].clone
        key_data = @current_inputs[i][1].clone
        file.puts(key_name.to_s + " " + key_data[0].to_s + " " + key_data[1].to_s)
      end
    end
    File.open("System/x360_inputs.txt", 'w') do |file|
      for i in 0...@current_inputs.keys.size
        key_name = @current_inputs[i][0].clone
        key_data = @current_inputs[i][1].clone
        file.puts(key_name.to_s + " " + key_data[2].to_s)
      end
    end
  end
  
  
  # Function to determine if an input exists on a different row than the current.
  def input_exists?(button_data,button)
    for x in 0...@current_inputs.keys.size
      for y in 0...@current_inputs[x][1].size
        if button == @current_inputs[x][1][y]
          return false if button_data[0] == @current_inputs[x][0]
          return true
        end
      end
    end
    return false
  end
  

end