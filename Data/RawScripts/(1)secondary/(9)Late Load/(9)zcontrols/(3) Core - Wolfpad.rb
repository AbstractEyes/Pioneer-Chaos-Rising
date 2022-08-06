#==============================================================================
# Gamepad Extender VX v1.0a (7/25/12)
# by Lone Wolf
# Edits by Funplayer
#------------------------------------------------------------------------------
# This allows scripters to utilize the extra buttons on modern
# XInput-compatible gamepads.　It requires DirectX 9.0 or later and
# an XInput compatible gamepad. Incompatible pads will default to
# using the standard Input module functionality.
#
# This is not a plug-and-play script.
#
# Instructions:
# - Paste in the Materials section.
# - Use the PadConfig section to specify button differences between
#	 Gamepad and Keyboard (optional but recommended)
#	 (Replace direct button calls in your scripts (and the defaults) with
#	 PadConfig calls or these will do nothing.)
#------------------------------------------------------------------------------
# Command Reference:
#------------------------------------------------------------------------------
# All calls to extended buttons on Pad 1 can be made through the Input module.
# Pass WolfPad::BUTTON for pad calls, Input.BUTTON for keyboard calls.
# When using multiple pads, send calls directly to WolfPad with pad number
# as the final parameter.
#
# The current list of mappable buttons is as follows:
#
# A, B, X, Y	 - XBOX 360 standard face buttons.
# L1, L2, R1, R2 - Four triggers (LB, LT, RB, RT)
# SELECT, START	- Back and Start buttons
# L3, R3		 - Clickable Analog buttons
#
# UP, DOWN,
# LEFT, RIGHT		 - D-Pad buttons
#
# NON-STANDARD MAPPINGS WILL DO NOTHING without a compatible gamepad.
# To that end, use calls to PadConfig to remap non-standard keys into
# the standard domain where possible.
#
#	for example: "Input.trigger?(PadConfig.page_down)"
#	will return WolfPad::R1 if a gamepad is plugged in, but Input.R otherwise
#
# Analog values can be referenced with the following commands:
# left_stick
# right_stick
# left_trigger
# right_trigger
#
# Directional values of analog sticks can be referenced with these:
# lstick4
# lstick8
# rstick4
# rstick8
#
# Controller vibration can be accessed with these:
# vibrate(left_motor, right_motor, frame_duration)
# set_motors(left_motor, right_motor)
#
#
# All functions take an optional gamepad ID as their final parameter.
#------------------------------------------------------------------------------
# Terms of Use:
#------------------------------------------------------------------------------
# If you use it, give credit. With a few caveats:
#
# This is an alpha version of a script in development.
# I make no guarantees of compatibility with other scripts.
#
# This is a VX port of an RGSS3 script. Some features may behave differently,
#
# This script was posted at the official (0X)RPG.rb Maker forums.
# Do modify or redistribute this script by itself, though you may
# include a configured version with your own script demos provided
# you include this header in its entirety.
#------------------------------------------------------------------------------
# Contact Info:
#------------------------------------------------------------------------------
# I can be reached via PM only at the (0X)RPG.rb Maker Web forums.
#	(http://forums.rpgmakerweb.com)
#
# PM'ing the user Lone Wolf at other (0X)RPG.rb Maker sites may have...
# unpredicatable results. I made someone really happy the day I registered...
#------------------------------------------------------------------------------
# Credits:
# Lone Wolf
# Funplayer (Complete edit to support integration with rebinding and controller)
#------------------------------------------------------------------------------
# 翻訳したいんですか？いいんだが、まだ完成していない。
#==============================================================================

module PadConfig
  # Basic configuration settings:
  DEADZONE = 0.1 # Deadzone for axis input (%)
  CONTROLLERS = 4 # Number of controllers to use (from 1 - 4)
  MOVE_WITH_STICK = true # Use left-analog stick with dir4 and dir8
  # Use this section to write flexible button-mappings for your scripts.
  # Add additional methods as needed.
  # PadConfig.up
  def self.up
    Input.UP
  end

  def self.down
    Input.DOWN
  end

  def self.left
    Input.LEFT
  end

  def self.right
    Input.RIGHT
  end

  def self.decision
    Input.C
  end

  def self.cancel
    Input.B
  end

  def self.dash
    Input.A
  end

  def self.menu
    Input.Y
  end

  def self.page_up
    Input.L
  end

  def self.page_down
    Input.R
  end

  def self.sandbox_1
    Input.L
  end

  def self.sandbox_2
    Input.R
  end

  def self.hud
    Input.X
  end

  def self.debug
      Input.CTRL
  end

  def self.debug2
    Input.F9
  end
  
  def self.turbo
    Input.TAB
  end

end

#~ =begin
# Main module:
module WolfPad
  # Button constants. Do NOT modify these unless you know what you're doing.
=begin
#~       WolfPad::UP = 545 #d-pad up
#~       WolfPad::DOWN = 544 #d-pad left
#~       WolfPad::LEFT = 543 #d-pad down
#~       WolfPad::RIGHT = 542 #d-pad right
#~       WolfPad::A = 533 #lower face button
#~       WolfPad::B = 532 #right face button
#~       WolfPad::X = 531 #left face button
#~       WolfPad::Y = 530 #upper face button
#~       WolfPad::L1 = 537 #upper left trigger
#~       WolfPad::R1 = 536 #upper right trigger
#~       WolfPad::START = 541
#~       WolfPad::SELECT = 540
#~       WolfPad::L3 = 539 #left thubstick button
#~       WolfPad::R3 = 538 #right thubstick button
#~       WolfPad::L2 = 546 #lower left trigger (press only)
#~       WolfPad::R2 = 547 #lower right trigger (press only)
=end
  UP = 545 #d-pad up
  DOWN = 544 #d-pad left
  LEFT = 543 #d-pad down
  RIGHT = 542 #d-pad right
  A = 533 #lower face button
  B = 532 #right face button
  X = 531 #left face button
  Y = 530 #upper face button
  L1 = 537 #upper left trigger
  R1 = 536 #upper right trigger
  START = 541
  SELECT = 540
  L3 = 539 #left thubstick button
  R3 = 538 #right thubstick button
  L2 = 546 #lower left trigger (press only)
  R2 = 547 #lower right trigger (press only)

  def self.update
    for pad_index in 0...PadConfig::CONTROLLERS
     input = get_state(pad_index)
     if @packet[pad_index] == input[0]
       set_holds(pad_index)
       next
     end
     @packet[pad_index] = input[0]
     @buttons[pad_index] = (input[1] | 0x10000).to_s(2)
     @triggers[pad_index] = [input[2], input[3]]
     @lstick[pad_index] = [constrain_axis(input[4]), -constrain_axis(input[5])]
     @rstick[pad_index] = [constrain_axis(input[6]), -constrain_axis(input[7])]
     set_holds(pad_index)
    end
    update_vibration
  end
  def self.test
    detected = 0
    for i in 0...PadConfig::CONTROLLERS
      self.update
      detected += plugged_in?(i) ? 1 : 0
    end
    puts sprintf('%d XInput controller(s) in use.', detected)
    Graphics.wait(360)
  end

  # Basic vibration call.
  # For simplicity, motor values should be floats from 0.0 to 1.0
  def self.vibrate(left, right, duration, pad_index = 0)
    set_motors(left, right, pad_index)
    @vibrations[pad_index] = duration
  end
  # Counts down vibration event timers
  def self.update_vibration
    for pad in 0...PadConfig::CONTROLLERS
      next if @vibrations[pad].nil?
      next if @vibrations[pad] == -1
      @vibrations[pad] -= 1
      if @vibrations[pad] == 0
        @vibrations[pad] = -1
        set_motors(0, 0, pad)
      end
    end
  end
  # Set left and right motor speeds. Vibration continues until stopped.
  # Repeated calls with different values can create vibration effects.
  # For simplicity, input values should be floats from 0.0 to 1.0
  def self.set_motors(left, right, pad_index = 0)
    left_v = [left * 65535, 65535].min
    right_v = [right * 65535, 65535].min
    vibration = [left_v, right_v].pack("SS")
    @set_state.call(pad_index, vibration)
  end
  def self.press?(button, pad_index = 0)
    return key_holds(button, pad_index) > 0
  end
  def self.trigger?(button, pad_index = 0)
    return key_holds(button, pad_index) == 1
  end
  def self.repeat?(button, p_i = 0)
    result = key_holds(button, p_i)
    return true if result == 1
    return true if result > 19 && result % 5 == 0
  end
  # Returns left stick as a pair of floats [x, y] between -1.0 and 1.0
  def self.left_stick(pad_index = 0)
    return @lstick[pad_index]
  end
  # Returns right stick as a pair of floats [x, y] between -1.0 and 1.0
  def self.right_stick(pad_index = 0)
    return @rstick[pad_index]
  end
  # Returns left trigger as float between 0.0 to 1.0
  def self.left_trigger(pad_index = 0)
    return @triggers[pad_index][0] / 255.0
  end
  # Returns right trigger as float between 0.0 to 1.0
  def self.right_trigger(pad_index = 0)
    return @triggers[pad_index][1] / 255.0
  end
  def self.dir4(p_i = 0)
    return lstick4(p_i) if lstick4(p_i) != 0 #lstick4(p_i) if PadConfig::MOVE_WITH_STICK
    if press?(UP, p_i)
      return 8
    elsif press?(RIGHT, p_i)
      return 6
    elsif press?(LEFT, p_i)
      return 4
    elsif press?(DOWN, p_i)
      return 2
    else
      return 0
    end
  end
  def self.dir8(p_i = 0)
    return lstick8(p_i) if lstick8(p_i) #PadConfig::MOVE_WITH_STICK
    if press?(UP, p_i) and press?(LEFT, p_i)
      return 7
    elsif press?(UP, p_i) and press?(RIGHT, p_i)
      return 9
    elsif press?(DOWN, p_i) and press?(LEFT, p_i)
      return 1
    elsif press?(DOWN, p_i) and press?(RIGHT, p_i)
      return 3
    else
      return dir4(p_i)
    end
  end
  # Left-stick as numpad direction
  def self.lstick8(p_i = 0)
    return axis_to_dir8(@lstick[p_i])
  end
  def self.lstick4(p_i = 0)
    return axis_to_dir4(@lstick[p_i])
  end
  # Right-stick as numpad direction
  def self.rstick8(p_i = 0)
    return axis_to_dir8(@rstick[p_i])
  end
  def self.rstick4(p_i = 0)
    return axis_to_dir4(@rstick[p_i])
  end
  def self.plugged_in?(pad_index = 0)
    #p pad_index.to_s + ' ' + @packet.inspect
    return @packet[pad_index] && @packet[pad_index] > 0
  end
  def self.keyboard_key?(button)
    return button[0] < 30 if button[0] < 30
    return button[1] < 30 if button[1] < 30
    return false
  end
  #Helper functions:
  # convert signed half-word axis state to float
  def self.constrain_axis(axis)
    val = axis.to_f / 2**15
    return val.abs > PadConfig::DEADZONE ? val : 0
  end
  # convert axis direction to VX Ace direction
  def self.axis_to_dir8(axis)
    return angle_to_dir8(axis_to_angle(axis))
  end
  def self.axis_to_dir4(axis)
    return angle_to_dir4(axis_to_angle(axis))
  end
  def self.axis_to_angle(axis)
    cy = -axis[1]
    cx = -axis[0]
    return 0 if cy == 0 && cx == 0
    angle = Math.atan2(cx, cy) * 180 / Math::PI
    angle = angle < 0 ? angle + 360 : angle
    return angle
  end
  # Please PM me if you have an easier way to write this.
  def self.angle_to_dir8(angle)
    return 0 if angle == 0
    d = 0
    if angle < 22.5 || angle >= 337.5
     d = 8
    elsif angle < 67.5
     d = 7
    elsif angle < 112.5
     d = 4
    elsif angle < 157.5
     d = 1
    elsif angle < 202.5
     d = 2
    elsif angle < 247.5
     d = 3
    elsif angle < 292.5
     d = 6
    elsif angle < 337.5
     d = 9
    end
    return d
  end
  def self.angle_to_dir4(angle)
    return 0 if angle == 0
    d = 0
    if angle < 45 || angle >= 315
     d = 8
    elsif angle < 135
     d = 4
    elsif angle < 225
     d = 2
    elsif angle < 315
     d = 6
    end
    return d
  end 
  private # methods past here can't be called from outside
  #Win32API calls. Leave these alone.
  @set_state = Win32API.new('xinput1_4', 'XInputSetState', 'IP', 'V')
  @get_state = Win32API.new('xinput1_4', 'XInputGetState', 'IP', 'L')

  #Initializers
  # Will store data for number of gamepads in use.
  @packet = [PadConfig::CONTROLLERS]
  @buttons = [PadConfig::CONTROLLERS]
  @triggers = [PadConfig::CONTROLLERS]
  @lstick = [PadConfig::CONTROLLERS]
  @rstick = [PadConfig::CONTROLLERS]
  # tracks how long buttons have been pressed
  @holds = Table.new(PadConfig::CONTROLLERS, 18)
  # stores vibration event timers
  @vibrations = [PadConfig::CONTROLLERS]
  def self.key_holds(button_id, pad_index=0)
    if button_id.is_a?(Array)
      return 0
    else
      (0...@holds.xsize).each {|p_i|
        if @holds[p_i, button_id - 530] != 0
          return @holds[p_i, button_id - 530]
        end
      }
      return 0 #@holds[pad_index, button_id - 530]
    end
  end
  def self.get_state(pad_index)
    state = "\0" * 16
    @get_state.call(pad_index, state)
    return state.unpack("LSCCssss")
  end
  def self.set_holds(p_i)
    for i in 1...17
     @holds[p_i, i-1] = @buttons[p_i][i,1].to_i > 0 ? @holds[p_i, i-1]+1 : 0
    end
    @holds[p_i, 16] = (left_trigger(p_i) >= 0.5) ? (@holds[p_i, 16]+1) : 0
    @holds[p_i, 17] = (right_trigger(p_i) >= 0.5) ? (@holds[p_i, 17]+1) : 0
  end
end# Aliases to tie the above into VXAce's Input module

module Input
  class <<self
    alias :vxa_update :update
    alias :vxa_press? :press?
    alias :vxa_trigger? :trigger?
    alias :vxa_repeat? :repeat?
    alias :vxa_dir4 :dir4
    alias :vxa_dir8 :dir8
  end
  def self.update
    WolfPad.update
    vxa_update
  end
  def self.press?(button)
    highest_key = 0
    if button.is_a?(Array)
      button.each do |key|
        highest_key = key if highest_key < key
      end
      if highest_key >= 530
        return (vxa_press?(button) or WolfPad.press?(highest_key))
      else
        return (vxa_press?(button))
      end
    end
    return WolfPad.press?(button) if WolfPad.plugged_in?
    return vxa_press?(button)
  end
  
  def self.trigger?(button)
    highest_key = 0
    if button.is_a?(Array)
      button.each do |key|
        highest_key = key if highest_key < key
      end
      if highest_key >= 530
        return (vxa_trigger?(button) or WolfPad.trigger?(highest_key))
      else
        return (vxa_trigger?(button))# or WolfPad.trigger?(highest_key))
      end
    end
    return WolfPad.trigger?(button) if WolfPad.plugged_in?
    return vxa_trigger?(button)
  end
  
  def self.repeat?(button)
    highest_key = 0
    if button.is_a?(Array)
      button.each do |key|
        highest_key = key if highest_key < key
      end
      if highest_key >= 530
        return (vxa_repeat?(button) or WolfPad.repeat?(highest_key))
      else
        return (vxa_repeat?(button))
      end
    end
    return WolfPad.repeat?(button) if WolfPad.plugged_in?
    return vxa_repeat?(button)
  end
  #~ def self.dir4
  #~ 	WolfPad.plugged_in? ? WolfPad.dir4 : vxa_dir4
  #~ end
  #~ def self.dir8
  #~ 	WolfPad.plugged_in? ? WolfPad.dir8 : vxa_dir8
  #~ end
end
#~ =end