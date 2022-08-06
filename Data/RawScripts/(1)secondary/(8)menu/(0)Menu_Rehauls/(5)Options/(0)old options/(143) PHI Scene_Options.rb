class Scene_Options < Scene_Base
  
  def initialize(menu_index = 0, option_index = 0)
    # Position of the cursor in the list of windows.
    @menu_index = menu_index
    @saved_menu_index = -1
    @option_index = option_index
    @saved_option_index = @option_index
  end

  def start
    super
    create_menu_background
    @categories = Menu_Categories.new(0,0,120,$screen_height)
    @categories.active = false
    create_options
  end
  
  def create_options
    @menu_options = {}
    for i in 0...@categories.categories.size
      @menu_options[i] = Menu_Options.new(120,0+(i*50+8),$screen_width-120,58)
      @menu_options[i].refresh(i)
      @menu_options[i].opacity = 0
      @menu_options[i].index = 0
    end
  end
  
  def terminate
    super
    dispose_menu_background
    @categories.dispose
    @menu_options.each { |key,window| window.dispose unless window.nil? or window.disposed? }
    @menu_options.clear
  end
  
  def update
    super
    update_menu_background
    @categories.update
    @menu_options.each { |key,window| window.update }
    if @menu_index != @saved_menu_index
      @menu_options[@saved_menu_index].active = false unless @saved_menu_index < 0
      @menu_options[@menu_index].active = true
      @saved_menu_index = @menu_index
    end
    if any_option_active?
      update_category_selection
    end
  end
  
  def any_option_active?
    @menu_options.each { |key,window|
      next if window.nil?
      return true if window.active
    }
    return false
  end
  
  def update_category_selection
    if Input.trigger?(PadConfig.cancel)
      Sound.play_equip
      $scene = Scene_Pioneer_Book.new
    elsif Input.trigger?(PadConfig.decision)
      Sound.play_decision
    elsif Input.trigger?(PadConfig.down)
      Sound.play_cursor
      return if @menu_index == @categories.categories.size - 1
      @menu_index += 1
    elsif Input.trigger?(PadConfig.up)
      Sound.play_cursor
      return if @menu_index <= 0
      @menu_index -= 1
    end
  end
  
end