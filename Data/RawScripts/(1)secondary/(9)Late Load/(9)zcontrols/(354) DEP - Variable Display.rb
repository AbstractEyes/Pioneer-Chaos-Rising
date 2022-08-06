=begin
#===============================================================================
# 
# Shanghai Simple Script - Variable Map Window
# Last Date Updated: 2010.05.17
# Level: Normal
# 
# This script allows for multiple variables and automatically updates itself
# when the variables themselves change.
#===============================================================================
# Instructions
# -----------------------------------------------------------------------------
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials but above ▼ Main. Remember to save.
# 
# To use this variable window, use these event calls. Works on map only.
# 
# variable_window_clear
# - Clears all of the variable window and closes it.
# 
# variable_window_open
# - Opens the variable window, but only if it has variables.
# 
# variable_window_close
# - Closes the variable window.
# 
# variable_window_add(variable_id)
# - Adds the variable_id to the variable window.
# 
# variable_window_remove(variable_id)
# - Removes the variable_id from the variable window.
# 
# variable_window_upper_left
# variable_window_upper_right
# variable_window_lower_left
# variable_window_lower_right
# - Moves the variable window to that location.
# 
# variable_window_width(x)
# - Changes the variable window's width to x.
#===============================================================================
 
$imported = {} if $imported == nil
$imported["VariableMapWindow"] = true
 
#==============================================================================
# ** Game_System
#==============================================================================
 
class Game_System
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :shown_variables
  attr_accessor :variable_window_open
  attr_accessor :variable_corner
  attr_accessor :variable_width
  attr_accessor :gauge_variables
end
 
#==============================================================================
# ** Game_Interpreter
#==============================================================================
 
class Game_Interpreter
  #--------------------------------------------------------------------------
  # * Variable Window Clear
  #--------------------------------------------------------------------------
  def variable_window_clear
    return unless $scene.is_a?(Scene_Map)
    $scene.variable_window.data = []
    $scene.variable_window.refresh
    $scene.variable_window.close
  end
  #--------------------------------------------------------------------------
  # * Variable Window Open
  #--------------------------------------------------------------------------
  def variable_window_open
    return unless $scene.is_a?(Scene_Map)
    $scene.variable_window.open# if $scene.variable_window.data != []
    $game_system.variable_window_open = true
  end
  #--------------------------------------------------------------------------
  # * Variable Window Close
  #--------------------------------------------------------------------------
  def variable_window_close
    return unless $scene.is_a?(Scene_Map)
    $scene.variable_window.close
    $game_system.variable_window_open = false
  end
  #--------------------------------------------------------------------------
  # * Variable Window Add
  #--------------------------------------------------------------------------
  def variable_window_add(variable_id)
    return unless $scene.is_a?(Scene_Map)
    return unless variable_id.is_a?(Integer)
    return if $game_variables[variable_id].nil?
    return if $game_system.shown_variables.include?(variable_id)
    $game_system.shown_variables.push(variable_id)
    $scene.variable_window.refresh
  end
  #--------------------------------------------------------------------------
  # * Variable Window Add Exp Gauge
  #--------------------------------------------------------------------------
  def variable_window_add_exp_gauge(level_variable_id,exp_to_level,current_exp,total_exp)
    return unless $scene.is_a?(Scene_Map)
    return unless variable_id.is_a?(Integer)
    return if $game_variables[level_variable_id].nil?
    return if $game_variables[exp_to_level].nil?
    return if $game_variables[current_exp].nil?
    return if $game_variables[total_exp].nil?
    $game_system.gauge_variables.push(level_variable_id)
    $game_system.gauge_variables.push(exp_to_level)
    $game_system.gauge_variables.push(current_exp)
    $game_system.gauge_variables.push(total_exp)
    $scene.variable_window.refresh
  end

  #--------------------------------------------------------------------------
  # * Variable Window Add Timer
  #--------------------------------------------------------------------------
  def variable_window_add_timer(variable_id, variable_id2, variable_id3)
    return unless $scene.is_a?(Scene_Map)
    return unless variable_id.is_a?(Integer)
    return unless variable_id2.is_a?(Integer)
    return unless variable_id3.is_a?(Integer)
    return if $game_variables[variable_id].nil? 
    return if $game_variables[variable_id2].nil?
    return if $game_variables[variable_id3].nil?
    return if $game_system.shown_variables.include?(variable_id)
    return if $game_system.shown_variables.include?(variable_id2)
    return if $game_system.shown_variables.include?(variable_id3)
    $game_system.shown_variables.push(variable_id, variable_id2, variable_id3)
    $scene.variable_window.refresh
  end
  #--------------------------------------------------------------------------
  # * Variable Window Remove
  #--------------------------------------------------------------------------
  def variable_window_remove(variable_id)
    return unless $scene.is_a?(Scene_Map)
    return unless $game_system.shown_variables.include?(variable_id)
    $game_system.shown_variables.delete(variable_id)
    $scene.variable_window.refresh
  end
  #--------------------------------------------------------------------------
  # * Variable Window Upper Left
  #--------------------------------------------------------------------------
  def variable_window_upper_left
    return unless $scene.is_a?(Scene_Map)
    $game_system.variable_corner = 0
  end
  #--------------------------------------------------------------------------
  # * Variable Window Upper Right
  #--------------------------------------------------------------------------
  def variable_window_upper_right
    return unless $scene.is_a?(Scene_Map)
    $game_system.variable_corner = 1
  end
  #--------------------------------------------------------------------------
  # * Variable Window Lower Left
  #--------------------------------------------------------------------------
  def variable_window_lower_left
    return unless $scene.is_a?(Scene_Map)
    $game_system.variable_corner = 2
  end
  #--------------------------------------------------------------------------
  # * Variable Window Lower Right
  #--------------------------------------------------------------------------
  def variable_window_lower_right
    return unless $scene.is_a?(Scene_Map)
    $game_system.variable_corner = 3
  end
  #--------------------------------------------------------------------------
  # * Variable Window Width
  #--------------------------------------------------------------------------
  def variable_window_width(value)
    return unless $scene.is_a?(Scene_Map)
    $game_system.variable_width = [160, value].max
    $scene.variable_window.refresh
  end
end
 
#==============================================================================
# ** Window_Variable
#==============================================================================
 
class Window_Variable < Window_Base
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :data
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    @sub_x = -16
    @sub_y = -16
    super(@sub_x, @sub_y, 600, 500)
#~ #    self.openness = 0 if $game_system.shown_variables.empty?
    self.openness = 0 unless $game_system.variable_window_open
    self.opacity = 0
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    create_contents
    @level = $game_variables[1]#PHI::LEVEL.level
    @exp_to_level = $game_variables[2]#PHI::LEVEL.exp_to_level
    @exp_to_level = 1 if @exp_to_level == 0
    @total_exp = $game_variables[3]
    @current_level_exp = $game_variables[7]
    @current_level_exp = 1 if @current_level_exp == 0
    @current_level_percent = Integer((@current_level_exp / @exp_to_level) * 100)

    @stored_1 = $game_variables[1]
    @stored_2 = $game_variables[2]
    @stored_3 = $game_variables[3]
    @stored_7 = $game_variables[7]
    
    draw_hud
    draw_level_variables(80,416-70)
    draw_exp_variables(80,416-50)
    draw_ellipse_gauge(12,416-60,27)
  end
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def update
    super
    self.openness = 0 unless $game_system.variable_window_open
    refresh if $game_variables[1] != @stored_1
    refresh if $game_variables[2] != @stored_2
    refresh if $game_variables[3] != @stored_3
    refresh if $game_variables[7] != @stored_7
  end
  
  def draw_hud
    hud = Cache.system("hudframe1")
    rect = Rect.new(0, 0, 544, 416)
    rect.width = self.width
    rect.height = self.height
    self.contents.blt(0, 0, hud, rect, 255)
  end
  
  # Draws the circular gauge that displays the exp.
  def draw_ellipse_gauge(x, y, circle_size)
    yellow = Color.new(255,255,50,255)
    orange = Color.new(255,150,50,255)
    ellipse = Ellipse.new(x,y,circle_size,circle_size)
    if @current_level_exp > 0 and @exp_to_level > 0
      es2 = circle_size * @current_level_exp / @exp_to_level
      x2 = (x + circle_size) - es2
      y2 = (y + circle_size) - es2
      es3 = (es2 * 0.75).to_i
      x3 = (x + circle_size) - es3
      y3 = (y + circle_size) - es3
    else
      es2 = 0
      es3 = 0
      x2 = x
      y2 = y
    end
    ellipse2 = Ellipse.new(x2,y2,es2,es2)
    ellipse3 = Ellipse.new(x3,y3,es3,es3)
    self.contents.fill_ellipse(ellipse, Color.new(0,0,0,255))
    self.contents.fill_ellipse(ellipse2, yellow)
    self.contents.fill_ellipse(ellipse3, orange)
    fsize = self.contents.font.size
    self.contents.font.size = 12
    self.contents.draw_text(((x+circle_size) + 10), ((y+circle_size)+10), width, WLH, "%#{@current_level_percent}")

  end
  
  # Draws level variables
  def draw_level_variables(x, y)
    self.contents.font.color = system_color
    text = "Pioneer: "
    self.contents.draw_text(x, y, width, WLH, text)
    self.contents.font.color = Color.new(55,255,55,255)
    self.contents.draw_text(x+(text.size*8)+20, y, width, WLH, "#{@level}")
    self.contents.font.color = normal_color
  end
  
  # Draw exp data
  def draw_exp_variables(x, y)
    last_font_size = self.contents.font.size
    self.contents.font.color = crisis_color
    self.contents.draw_text(x+10, y+20, width, WLH, "Exp: #{Integer(@current_level_exp)} / #{Integer(@exp_to_level)}")
    self.contents.draw_text(x, y, width, WLH, "Total: #{Integer(@total_exp)}")
    self.contents.font.color = normal_color
  end
  
#~   def draw_exp_gauge_bar(x, y, bar_width)
#~     if @current_level_exp > 0 and @exp_to_level > 0
#~       gw = bar_width * @current_level_exp / @exp_to_level
#~     else
#~       gw = 0
#~     end
#~     self.contents.fill_rect(x, y + WLH, bar_width, 26, Color.new(0,0,0,255))
#~     self.contents.gradient_fill_rect(x, y + WLH, gw, 26, Color.new(0,0,255,255), Color.new(90,90,255,255))
#~   end
  
end
 
#==============================================================================
# ** Scene_Map
#==============================================================================
 
class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :variable_window
  #--------------------------------------------------------------------------
  # * Start processing
  #--------------------------------------------------------------------------
  alias start_sss_variable_map_window start unless $@
  def start
    start_sss_variable_map_window
    @variable_window = Window_Variable.new
  end
  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  alias terminate_sss_variable_map_window terminate unless $@
  def terminate
    @variable_window.dispose unless @variable_window.nil?
    @variable_window = nil
    terminate_sss_variable_map_window
  end
  #--------------------------------------------------------------------------
  # * Basic Update Processing
  #--------------------------------------------------------------------------
  alias update_basic_sss_variable_map_window update_basic unless $@
  def update_basic
    update_basic_sss_variable_map_window
    @variable_window.update unless @variable_window.nil?
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  alias update_sss_variable_map_window update unless $@
  def update
    update_sss_variable_map_window
    @variable_window.update unless @variable_window.nil?
  end
end
 
#===============================================================================
# 
# END OF FILE
# 
#===============================================================================
=end