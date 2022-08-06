class Scene_InputSet < Scene_Base
  #--------------------------------------------------------------------------
  # * Start processing
  #--------------------------------------------------------------------------
  def start
    super
    @viewport = Viewport.new(0, 0, $screen_width, $screen_height)
    @input_object = $input_config
    
    # Windows for the type of input, left side.
    @input_type = Window_InputType.new(0,60,160,$screen_height-60)
    @input_type.refresh
    @input_type.active = false
    @input_type.index = -1
    @input_type_second_index = -1
    
    # Window for the input preset type selection.
    @preset_type_set = Window_InputTypeSet.new(0,0,$screen_width,60)
    @preset_type_set.active = true
    @preset_type_set.index = $keyboard_preset - 1
    
    # Window for the exact input to select
    @input_set = Window_InputSelect.new(160,60,$screen_width-160,$screen_height-60)
    @input_set.refresh
    @input_set.active = false
    @input_set.index = 0
    
    @input_help = Window_InputHelp.new(30,30,($screen_width-60),60)
    @input_help.visible = false
    
    @button_set = Window_ButtonSet.new(102,143,340,130)
    @button_set.visible = false
    
    @preset_switch_help = Window_InputHelp.new(30,30,($screen_width/2), 100)
    @preset_switch_help.visible = false
    
    @preset_switch_choice = Window_TypeSetChoice.new(30,56,($screen_width/2),60)
    @preset_switch_choice.opacity = 0
    @preset_switch_choice.index = 0
    @preset_switch_choice.visible = false
    @preset_switch_choice.active = false
    
  end
  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  def terminate
    super
    @viewport.dispose
    @preset_type_set.index = $keyboard_preset - 1
    @start_preset = 0
    @current_preset = $keyboard_preset
    @input_set.set_inputs
    @input_object.set_inputs
    @input_set.dispose
    @input_type.dispose
    @preset_type_set.dispose
    @button_set.dispose
    @input_help.dispose
    @preset_switch_help.dispose
    @preset_switch_choice.dispose
  end
  #--------------------------------------------------------------------------
  # * Update Frame
  #--------------------------------------------------------------------------
  def update
    super
    @preset_type_set.update
    @input_type.update
    @input_set.update
    @button_set.update
    @input_help.update
    @preset_switch_help.update
    @preset_switch_choice.update
    @current_preset = $keyboard_preset
    if @preset_type_set.active
      update_input_type_set
    elsif @input_set.active
      update_input_list
    elsif @button_set.visible
      @cur_key = 0 if @cur_key.nil?
      check_input_button
    elsif @input_help.visible
      wait_for_confirm
    elsif @preset_switch_choice.active
      wait_for_type_switch_confirm
    end
    if @preset_type_set.index != @input_type_second_index
      @input_type_second_index = @preset_type_set.index
      @input_set.refresh(@preset_type_set.index + 1)
    end
    if @current_preset != @start_preset
      @start_preset = @current_preset
      @preset_type_set.refresh
    end
  end
  
  # Determines the type choice from the top of the screen.
  def update_input_type_set
    if Input.trigger?(PadConfig.cancel)
      if @input_set.all_bound? 
        Sound.play_cancel
        $scene = Scene_Map.new
      else
        Sound.play_buzzer
        @preset_type_set.active = false
        @input_help.set_text("Not all inputs are set correctly.")
        @input_help.visible = true
      end
    elsif Input.trigger?(PadConfig.decision)
      Sound.play_decision
      case @preset_type_set.index
      # Type A
      when 0
        @preset_switch_choice.active = true
        @preset_switch_choice.visible = true
        @preset_switch_help.set_text("Convert to Type A?")
        @preset_switch_help.visible = true
        @preset_type_set.active = false
      # Type B
      when 1
        @preset_switch_choice.active = true
        @preset_switch_choice.visible = true
        @preset_switch_help.set_text("Convert to Type B?")
        @preset_switch_help.visible = true
        @preset_type_set.active = false
      # Custom inputs
      when 2
        @preset_type_set.active = false
        @input_set.active = true
      end
    end
  end
  
  def wait_for_type_switch_confirm
    if Input.trigger?(PadConfig.decision)
      case @preset_switch_choice.index
      when 0
        Sound.play_decision
        $keyboard_preset = @preset_type_set.index + 1
        @preset_switch_choice.active = false
        @preset_switch_choice.visible = false
        @preset_switch_help.visible = false
        @preset_type_set.active = true
      when 1
        Sound.play_cancel
        @preset_switch_choice.active = false
        @preset_switch_choice.visible = false
        @preset_switch_help.visible = false
        @preset_type_set.active = true
      end
    elsif Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      @preset_switch_choice.active = false
      @preset_switch_choice.visible = false
      @preset_switch_help.visible = false
      @preset_type_set.active = true
    end
  end
  
  def wait_for_confirm
    if Input.trigger?(PadConfig.cancel) or Input.trigger?(PadConfig.decision)
      Sound.play_decision
      @input_help.visible = false
      @preset_type_set.active = true
    end
  end
  
  #--------------------------------------------------------------------------
  # * Update Item Selection
  #--------------------------------------------------------------------------
  def update_input_list
    if Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      @input_set.active = false
      @preset_type_set.active = true
    elsif Input.trigger?(PadConfig.decision)
      Sound.play_decision
      @button_set.refresh(@input_set.key_type, @input_set.key)
      @button_set.visible = true
      @input_set.active = false
    end
  end
  
  def check_input_button
    (1...222).each{ |i|
      @cur_key = 0 if @cur_key.nil?
      next if i == 160 or i == 161 or
              i == 162 or i == 163 or
              i == 164 or i == 165
      if Input.trigger?([i])
        Sound.play_cursor
        if @cur_key == i
          $keyboard_preset = @preset_type_set.index + 1
          @input_set.key = i
          @input_set.unbind_keys(i, 0)
          @input_set.refresh
          @cur_key = 0
          @button_set.set_key(-1)
          @button_set.active = false
          @button_set.visible = false
          @input_set.active = true
        elsif i == 27
          @input_set.key = -1
          @input_set.unbind_keys(@input_set.key, 1)
          @input_set.refresh
          @cur_key = 0
          @button_set.set_key(-1)
          @button_set.active = false
          @button_set.visible = false
          @input_set.active = true
        else
          @button_set.set_key(i)
          @button_set.refresh(@input_set.key_type, @input_set.key)
          @cur_key = i
        end
      end
    }
  end

end