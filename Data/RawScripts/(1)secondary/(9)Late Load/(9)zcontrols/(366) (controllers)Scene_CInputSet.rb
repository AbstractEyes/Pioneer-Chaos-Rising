class Scene_CInputSet < Scene_Base
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
    @preset_type_set = Window_TypeInputController.new(0,0,$screen_width,60)
    @preset_type_set.active = true
    @preset_type_set.index = 0
    
    # Window for the exact input to select
    @input_set = Window_ControllerConfigureIndividual.new(160,60,$screen_width-160,$screen_height-60)
    @input_set.refresh
    @input_set.active = false
    @input_set.index = 0
    
    # Configures all inputs in sequence.
    @input_set_all = Window_ControllerConfigureAll.new((($screen_width/2)-120),(($screen_height/2)-40), 240, 80)
    @input_set_all.visible = false
    
    @input_help = Window_InputHelp.new(30,30,($screen_width-60),60)
    @input_help.visible = false
    
  end
  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  def terminate
    super
    @viewport.dispose
    @input_object.set_inputs
    @preset_type_set.dispose
    @input_set.dispose
    @input_type.dispose
    @input_help.dispose
    @input_set_all.dispose
  end
  #--------------------------------------------------------------------------
  # * Update Frame
  #--------------------------------------------------------------------------
  def update
    super
    @preset_type_set.update
    @input_type.update
    @input_set.update
    @input_help.update
    @input_set_all.update
    if @preset_type_set.active
      update_preset_choice
    elsif @input_set.active
      update_input_screen
    elsif @input_set_all.visible
      update_set_all_window
    end
  end
  
  def update_input_screen
    if Input.trigger?(PadConfig.cancel)
      @input_set.active = false
      @preset_type_set.active = true
    elsif Input.trigger?(PadConfig.decision)
      
    end
  end
  
  # Determines the type choice from the top of the screen.
  def update_preset_choice
    if Input.trigger?(PadConfig.cancel)
#~       @input_set.set_inputs
#~       if @input_set.all_bound? 
        Sound.play_cancel
        $scene = Scene_Map.new
#~       else
#~       end
    elsif Input.trigger?(PadConfig.decision)
      case @preset_type_set.index
      # Set individual controller buttons
      when 0
        Sound.play_decision
        @preset_type_set.active = false
        @input_set.active = true
      # set all controller buttons in sequence
      when 1
        Sound.play_decision
        @preset_type_set.active = false
        @input_set_all.visible = true
        @input_set_all.indecks = 0
        @input_set_all.refresh
      # Exit
      when 2
        Sound.play_cancel
        $scene = Scene_Map.new
      end
    end
  end
  
  def update_set_all_window
    if @input_set_all.indecks < @input_object.current_inputs.keys.size
      (530...560).each{ |i|
        if Input.trigger?([i])
          Sound.play_decision
          @input_set_all.set_key(i)
          @input_set_all.indecks += 1
          @input_set_all.refresh
          @input_set.refresh
        elsif i == 27
          Sound.play_cancel
          @input_set_all.visible = false
          @preset_type_set.active = true
        end
      }
    else
      @input_set_all.visible = false
      @preset_type_set.active = true
    end
  end

end