#==============================================================================
# Modified Scene_Name 1.3b Final
# By Cyclope
# Author's post: http://forum.chaos-project.com/index.php?topic=6731.0
# Edit by Helladen: Converted to VX and fixed alignment and settings.
# I also rewrote the enter button it now works properly.
# Edit by Funplayer: Completely rewrote main algorithms for rebinding.
# - 1.1 release for VX. (7/15/10)
# - 1.2 fixed the guide text at the bottom. (7/15/10)
# - 1.3 added where you can have it draw your face or (0)character sprite.
#   Fixed it from not having a sound if you erased letters.
#   Changed some of the sounds and other small fixes. (7/19/10)
# - 1.3b fixed where you could space the whole name and space sounds.
#------------------------------------------------------------------------------
# Instructions
# Place above main
#------------------------------------------------------------------------------
# Credit:
# Nattmath (For making Scene_Name Letters Modification)
# Blizzard (For making Custom Controls)
# Cyclope (For modifying Scene_Name Leters Modification and Scene_Name)
# Helladen (Converted to Rpg Maker VX and enhanced it)
# Funplayer (Complete rewrite for dynamic rebinding)
#==============================================================================
#==============================================================================
# ** Window_Instructions
#------------------------------------------------------------------------------
# This window displays full status specs on the status screen.
#==============================================================================
# Configuration
#------------------------------------------------------------------------------
DRAW_FACE = false # If this is true then it will draw a face if not then sprite
#==============================================================================
module INPUTS

#~   X_UP =        controller_input_data[1].to_i
#~   X_DOWN =      controller_input_data[3].to_i
#~   X_LEFT =      controller_input_data[5].to_i
#~   X_RIGHT =     controller_input_data[7].to_i
#~   X_DASH =      controller_input_data[9].to_i
#~   X_MENU =      controller_input_data[11].to_i
#~   X_CONFIRM =   controller_input_data[13].to_i
#~   X_HUD =       controller_input_data[15].to_i
#~   X_SANDBOX =   controller_input_data[17].to_i
#~   X_PAUSE   =   controller_input_data[19].to_i
#~   X_PAGEUP =    controller_input_data[21].to_i
#~   X_PAGEDOWN =  controller_input_data[23].to_i
#~     
#~   UP_1 = keyboard_input_data[4].to_i
#~   UP_2 = keyboard_input_data[5].to_i
#~   DOWN_1 = keyboard_input_data[7].to_i
#~   DOWN_2 = keyboard_input_data[8].to_i
#~   LEFT_1 = keyboard_input_data[10].to_i
#~   LEFT_2 = keyboard_input_data[11].to_i
#~   RIGHT_1 = keyboard_input_data[13].to_i
#~   RIGHT_2 = keyboard_input_data[14].to_i
#~   DASH_1 = keyboard_input_data[16].to_i
#~   DASH_2 = keyboard_input_data[17].to_i
#~   CONFIRM_1 = keyboard_input_data[22].to_i
#~   CONFIRM_2 = keyboard_input_data[23].to_i
#~   MENU_1 = keyboard_input_data[19].to_i
#~   MENU_2 = keyboard_input_data[20].to_i
#~   HUD_1 = keyboard_input_data[25].to_i
#~   HUD_2 = keyboard_input_data[26].to_i
#~   PAGEUP_1 = keyboard_input_data[28].to_i
#~   PAGEUP_2 = keyboard_input_data[29].to_i
#~   PAGEDOWN_1 = keyboard_input_data[31].to_i
#~   PAGEDOWN_2 = keyboard_input_data[32].to_i
#~   SANDBOX_1 = keyboard_input_data[34].to_i
#~   SANDBOX_2 = keyboard_input_data[35].to_i
#~   

#~     W_UP = 545 #d-pad up
#~     W_DOWN = 544 #d-pad left
#~     W_LEFT = 543 #d-pad down
#~     W_RIGHT = 542 #d-pad right
#~     W_A = 533 #lower face button
#~     W_B = 532 #right face button
#~     W_X = 531 #left face button
#~     W_Y = 530 #upper face button
#~     W_L1 = 537 #upper left trigger
#~     W_R1 = 536 #upper right trigger
#~     W_START = 541
#~     W_SELECT = 540
#~     W_L3 = 539 #left thubstick button
#~     W_R3 = 538 #right thubstick button
#~     W_L2 = 546 #lower left trigger (press only)
#~     W_R2 = 547 #lower right trigger (press only)
end

#==============================================================================
# module Input
#==============================================================================
module Input
  
  #----------------------------------------------------------------------------
  # Simple ASCII table
  #----------------------------------------------------------------------------
  Key = {
    'Mouse Left' => 1,
    'Mouse Right' => 2,
    'Mouse Middle' => 4,
    'Mouse 4' => 5,
    'Mouse 5' => 6,
    'Backspace' => 8,
    'Tab' => 9,
    'Clear' => 12,
    'Enter' => 13,
    'Shift' => 16,
    'Ctrl' => 17,
    'Alt' => -1,#18,
    'Pause'=> 19,
    'Caps Lock' => 20,
    'Esc' => 27,
    'Space' => 32,
    'Page Up' => 33,
    'Page Down' => 34,
    'End' => 35,
    'Home' => 36,
    'Arrow Left' => 37,
    'Arrow Up' => 38,
    'Arrow Right' => 39,
    'Arrow Down' => 40,
    'Select' => 41,
    'Print' => 42,
    'Execute' => 43,
    'PrintScrn' =>44,
    'Insert' => 45,
    'Delete' => 46,
    'Help' => 47,

    '0' => 48,
    '1' => 49,
    '2' => 50,
    '3' => 51,
    '4' => 52,
    '5' => 53,
    '6' => 54,
    '7' => 55,
    '8' => 56,
    '9' => 57,
    ':' => 58,
    ';' => 59,
    '(' => 60,
    '=' => 61,
    ')' => 62,
    '?' => 63,
    '@' => 64,

    'A' => 65,
    'B' => 66,
    'C' => 67,
    'D' => 68,
    'E' => 69,
    'F' => 70,
    'G' => 71,
    'H' => 72,
    'I' => 73,
    'J' => 74,
    'K' => 75,
    'L' => 76,
    'M' => 77,
    'N' => 78,
    'O' => 79,
    'P' => 80,
    'Q' => 81,
    'R' => 82,
    'S' => 83,
    'T' => 84,
    'U' => 85,
    'V' => 86,
    'W' => 87,
    'X' => 88,
    'Y' => 89,
    'Z' => 90,
    'Left Win' => 91,
    'Right Win' => 92,
    'Apps'      => 93,
    'Sleep'     => 95,
    'NumberPad 0' => 96,
    'NumberPad 1' => 97,
    'NumberPad 2' => 98,
    'NumberPad 3' => 99,
    'NumberPad 4' => 100,
    'NumberPad 5' => 101,
    'NumberPad 6' => 102,
    'NumberPad 7' => 103,
    'NumberPad 8' => 104,
    'NumberPad 9' => 105,
    '*' => 106,
    '+' => 107,
    '-' => 108,
    'Numpad Minus' => 109,
    '.' => 110,
    '/' => 111,
    'F1' => 112,
    'F2' => 113,
    'F3' => 114,
    'F4' => 115,
    'F5' => 116,
    'F6' => 117,
    'F7' => 118,
    'F8' => 119,
    'F9' => 120,
    'F10' => 121,
    'F11' => 122,
    'F12' => 123,

    'Num Lock' => 144,
    'Scroll Lock' => 145,

    'Left Shift' => 160,
    'Right Shift' => 161,
    'Left Ctrl' => 162,
    'Right Ctrl' => 163,
    'Left Alt' => 164,
    'Right Alt' => 165,

    ';:' => 186,
    '+' => 187,
    ',' => 188,
    '-' => 189,
    '.' => 190,
    '/?' => 191,
    '`~' => 192,

    '[{' => 219,
    '\|' => 220,
    ']}' => 221,
    '"' => 222,
  }
  
  CONTROLLER_KEY = {
    'UP'     => 545, #d-pad up
    'DOWN'   => 544, #d-pad left
    'LEFT'   => 543, #d-pad down
    'RIGHT'  => 542, #d-pad right
    'A'      => 533, #lower face button
    'B'      => 532, #right face button
    'X'      => 531, #left face button
    'Y'      => 530, #upper face button
    'L1'     => 537, #upper left trigger
    'R1'     => 536, #upper right trigger
    'START'  => 541,
    'SELECT' => 540,
    'L3'     => 539, #left thubstick button
    'R3'     => 538, #right thubstick button
    'L2'     => 546, #lower left trigger (press only)
    'R2'     => 547 #lower right trigger (press only)
  }
  
  # default button configuration
#~   UP = [83,40]
#~   LEFT = [Key['A'],Key['Arrow Left']]
#~   DOWN = [Key['S'],Key['Arrow Down']]
#~   RIGHT = [Key['D'],Key['Arrow Right']]
#~   A = [Key['Shift'], Key['NumberPad 0']]
#~   B = [Key['K'], 101]
#~   C = [Key['J'], Key['NumberPad 4']]
#~   X = [Key['U'], Key['NumberPad 6']]
#~   Y = [Key['I'], Key['NumberPad 7']]
#~   Z = [Key['O'], Key['NumberPad 8']]
#~   L = [Key['Y'], Key['Page Up']]
#~   R = [Key['H'], Key['Page Down']]
#~   F5 = [Key['F5']]
#~   F6 = [Key['F6']]
#~   F7 = [Key['F7']]
#~   F8 = [Key['F8']]
#~   F9 = [Key['F9']]
#~   SHIFT = [Key['Shift']]
#~   CTRL = [Key['Ctrl']]
#~   ALT = [Key['Alt']]
#~   # All keys
#~   ALL_KEYS = (0...256).to_a
#~   Input_Replacement.default_inputs
#~   UP    = [Input_Replacement.check_input('up',0),Input_Replacement.check_input('up',1)]
#~   UP    = [Input_Replacement.check_input('up',0),Input_Replacement.check_input('up',1)]
#~   LEFT  = [Input_Replacement.check_input('left',0),Input_Replacement.check_input('left',1)]
#~   DOWN  = [Input_Replacement.check_input('down',0),Input_Replacement.check_input('down',1)]
#~   RIGHT = [Input_Replacement.check_input('right',0),Input_Replacement.check_input('right',1)]
#~   A = [Input_Replacement.check_input('dash',0),Input_Replacement.check_input('dash',1)]
#~   B = [Input_Replacement.check_input('menu',0),Input_Replacement.check_input('back',1)]
#~   C = [Input_Replacement.check_input('confirm',0),Input_Replacement.check_input('confirm',1)]
#~   X = [Input_Replacement.check_input('hud',0),Input_Replacement.check_input('hud',1)]
#~   Y = [Input_Replacement.check_input('sandbox',0),Input_Replacement.check_input('sandbox',1)]
#~   Z = [Key['Z']]
#~   L = [Input_Replacement.check_input('pgup',0),Input_Replacement.check_input('pgup',1)]
#~   R = [Input_Replacement.check_input('pgdown',0),Input_Replacement.check_input('pgdown',1)]
=begin
    X_UP =        controller_input_data[4]
    X_DOWN =      controller_input_data[6]
    X_LEFT =      controller_input_data[8]
    X_RIGHT =     controller_input_data[10]
    X_DASH =      controller_input_data[12]
    X_CONFIRM =   controller_input_data[14]
    X_MENU =      controller_input_data[16]
    X_HUD =       controller_input_data[18]
    X_PAGEUP =    controller_input_data[20]
    X_PAGEDOWN =  controller_input_data[22]
    X_SANDBOX =   controller_input_data[24]
=end
  def self.convert_to_i(array)
    return array.each_with_index{|n, i| array[i] = n.to_i}
  end
  @@INPUTS = {
    :UP          =>  convert_to_i(($system.config[:KB_Up][1..2].push $system.config[:CT_Up][1].to_i)),
    :DOWN        =>  convert_to_i(($system.config[:KB_Down][1..2].push $system.config[:CT_Down][1].to_i)),
    :LEFT        =>  convert_to_i(($system.config[:KB_Left][1..2].push $system.config[:CT_Left][1].to_i)),
    :RIGHT       =>  convert_to_i(($system.config[:KB_Right][1..2].push $system.config[:CT_Right][1].to_i)),
    :A           =>  convert_to_i(($system.config[:KB_Dash][1..2].push $system.config[:CT_Dash][1].to_i)),
    :B           =>  convert_to_i(($system.config[:KB_Cancel][1..2].push $system.config[:CT_Cancel][1].to_i)),
    :C           =>  convert_to_i(($system.config[:KB_Confirm][1..2].push $system.config[:CT_Confirm][1].to_i)),
    :X           =>  convert_to_i(($system.config[:KB_Display][1..2].push $system.config[:CT_Display][1].to_i)),
    :Y           =>  convert_to_i(($system.config[:KB_Menu][1..2].push $system.config[:CT_Menu][1].to_i)),
    :Z           =>  convert_to_i(($system.config[:KB_Pause][1..2].push $system.config[:CT_Pause][1].to_i)),
    :R           =>  convert_to_i(($system.config[:KB_PageUp][1..2].push $system.config[:CT_PageUp][1].to_i)),
    :L           =>  convert_to_i(($system.config[:KB_PageDown][1..2].push $system.config[:CT_PageDown][1].to_i)),
    #CONSTANT
    :F3          =>  [
                       Key['F3'],
                       -1,
                       -1
                     ],
    :F5          =>  [
                       Key['F5'],
                       -1,
                       -1
                     ],
    :F6          =>  [
                       Key['F6'],
                       -1,
                       -1
                     ],
    :F7          =>  [
                       Key['F7'],
                       -1,
                       -1
                     ],
    :F8          =>  [
                       Key['F8'],
                       -1,
                       -1
                     ],
    :F9          =>  [
                       Key['F9'],
                       -1,
                       -1
                     ],
    :SHIFT       =>  [
                       Key['Shift'],
                       -1,
                       -1
                     ],
    :CTRL        =>  [
                       Key['Ctrl'],
                       -1,
                       -1
                     ],
    :ALT         =>  [ 
                       Key['Alt'],
                       -1,
                       -1
                     ],
    :ENTER       =>  [
                       Key['Enter'],
                       -1,
                       -1
                     ],
    :TAB         =>  [
                       Key['Tab'],
                       -1,
                       -1
                     ],
    :ALL_KEYS   => (0...256).to_a,
  }
  
  def self.inputs
    return @@INPUTS
  end
  
  def self.UP
    return @@INPUTS[:UP]
  end
  def self.UP=(new_value)
    @@INPUTS[:UP] = new_value
  end
  
  def self.DOWN
    return @@INPUTS[:DOWN]
  end
  def self.DOWN=(new_value)
    @@INPUTS[:DOWN] = new_value
  end
  
  def self.LEFT
    return @@INPUTS[:LEFT]
  end
  def self.LEFT=(new_value)
    @@INPUTS[:LEFT] = new_value
  end
  
  def self.RIGHT
    return @@INPUTS[:RIGHT]
  end
  def self.RIGHT=(new_value)
    @@INPUTS[:RIGHT] = new_value
  end
  
  def self.A 
    return @@INPUTS[:A]
  end
  def self.A=(new_value)
    @@INPUTS[:A] = new_value
  end
  
  def self.B
    return @@INPUTS[:B]
  end
  def self.B=(new_value)
    @@INPUTS[:B] = new_value
  end
  
  def self.C
    return @@INPUTS[:C]
  end
  def self.C=(new_value)
    @@INPUTS[:C] = new_value
  end
  
  def self.X
    return @@INPUTS[:X]
  end
  def self.X=(new_value)
    @@INPUTS[:X] = new_value
  end
  
  def self.Y
    return @@INPUTS[:Y]
  end
  def self.Y=(new_value)
    @@INPUTS[:Y]=new_value
  end
  
  def self.Z
    return @@INPUTS[:Z]
  end
  def self.Z=(new_value)
    @@INPUTS[:Z] = new_value
  end
  
  def self.L
    return @@INPUTS[:L]
  end
  def self.L=(new_value)
    @@INPUTS[:L]=(new_value)
  end
  
  def self.R
    return @@INPUTS[:R]
  end
  def self.R=(new_value)
    @@INPUTS[:R]=new_value
  end

  def self.F3
    return @@INPUTS[:F3]
  end
  
  def self.F5
    return @@INPUTS[:F5]
  end
  
  def self.F6
    return @@INPUTS[:F6]
  end
  
  def self.F7
    return @@INPUTS[:F7]
  end
  
  def self.F8
    return @@INPUTS[:F8]
  end
  
  def self.F9
    return @@INPUTS[:F9]
  end
  
  def self.SHIFT
    return @@INPUTS[:SHIFT]
  end
  
  def self.CTRL
    return @@INPUTS[:CTRL]
  end
  
  def self.ALT
    return @@INPUTS[:ALT]
  end
  
  def self.ENTER
    return @@INPUTS[:ENTER]
  end
  
  def self.TAB
    return @@INPUTS[:TAB]
  end
  
  def self.ALL_KEYS
    return @@INPUTS[:ALL_KEYS]
  end
  
  # Win32 API calls
  GetKeyboardState = Win32API.new('user32','GetKeyboardState', 'P', 'I')
  GetKeyboardLayout = Win32API.new('user32', 'GetKeyboardLayout','L', 'L')
  MapVirtualKeyEx = Win32API.new('user32', 'MapVirtualKeyEx', 'IIL', 'I')
  ToUnicodeEx = Win32API.new('user32', 'ToUnicodeEx', 'LLPPILL', 'L')
  # some other constants
  DOWN_STATE_MASK = 0x80
  DEAD_KEY_MASK = 0x80000000
  # data
  @state = "\0" * 256
  @triggered = [false] * 256
  @pressed = [false] * 256
  @released = [false] * 256
  @repeated = [0] * 256
  
  #----------------------------------------------------------------------------
  # update
  # Updates input.
  #----------------------------------------------------------------------------
  def self.update
    # get current language layout
    @language_layout = GetKeyboardLayout.call(0)
    # get new keyboard state
    GetKeyboardState.call(@state)
    # for each key
    self.ALL_KEYS.each do |key|
      # if pressed state
      if @state[key] & DOWN_STATE_MASK == DOWN_STATE_MASK
        # not released anymore
        @released[key] = false
        # if not pressed yet
        if !@pressed[key]
          # pressed and triggered
          @pressed[key] = true
          @triggered[key] = true
        else
          # not triggered anymore
          @triggered[key] = false
        end
        # update of repeat counter
        @repeated[key] < 17 ? @repeated[key] += 1 : @repeated[key] = 15
        # not released yet
      elsif !@released[key]
        # if still pressed
        if @pressed[key]
          # not triggered, pressed or repeated, but released
          @triggered[key] = false
          @pressed[key] = false
          @repeated[key] = 0
          @released[key] = true
        end
      else
        # not released anymore
        @released[key] = false
      end
    end
  end
  
  def self.alt_enter_pressed?
    return ((@pressed[18]and@pressed[13])or(@triggered[18]and@triggered[13]))
  end
  
  #----------------------------------------------------------------------------
  # dir4
  # 4 direction check.
  #----------------------------------------------------------------------------
  def Input.dir4
    return 2 if Input.press?(PadConfig.down)
    return 4 if Input.press?(PadConfig.left)
    return 6 if Input.press?(PadConfig.right)
    return 8 if Input.press?(PadConfig.up)
    return 0
  end
  #----------------------------------------------------------------------------
  # dir8
  # 8 direction check.
  #----------------------------------------------------------------------------
  def Input.dir8
    down = Input.press?(PadConfig.down)
    left = Input.press?(PadConfig.left)
    return 1 if down && left
    right = Input.press?(PadConfig.right)
    return 3 if down && right
    up = Input.press?(PadConfig.up)
    return 7 if up && left
    return 9 if up && right
    return 2 if down
    return 4 if left
    return 6 if right
    return 8 if up
    return 0
  end
  #----------------------------------------------------------------------------
  # trigger?
  # Test if key was triggered once.
  #----------------------------------------------------------------------------
  def Input.trigger?(keys)
    keys = [keys] unless keys.is_a?(Array)
    return keys.any? {|key| @triggered[key]}
  end
  #----------------------------------------------------------------------------
  # press?
  # Test if key is being pressed.
  #----------------------------------------------------------------------------
  def Input.press?(keys)
    keys = [keys] unless keys.is_a?(Array)
    return keys.any? {|key| @pressed[key]}
  end
  #----------------------------------------------------------------------------
  # repeat?
  # Test if key is being pressed for repeating.
  #----------------------------------------------------------------------------
  def Input.repeat?(keys)
    keys = [keys] unless keys.is_a?(Array)
    return keys.any? {|key| @repeated[key] == 1 || @repeated[key] == 16}
  end
  #----------------------------------------------------------------------------
  # release?
  # Test if key was released.
  #----------------------------------------------------------------------------
  def Input.release?(keys)
    keys = [keys] unless keys.is_a?(Array)
    return keys.any? {|key| @released[key]}
  end
  #----------------------------------------------------------------------------
  # get_character
  # vk - virtual key
  # Gets the (0)character from keyboard input using the input locale identifier
  # (formerly called keyboard layout handles).
  #----------------------------------------------------------------------------
  def self.get_character(vk)
    # get corresponding (0)character from virtual key
    c = MapVirtualKeyEx.call(vk, 2, @language_layout)
    # stop if (0)character is non-printable and not a dead key
    return '' if c < 32 && (c & DEAD_KEY_MASK != DEAD_KEY_MASK)
    # get scan code
    vsc = MapVirtualKeyEx.call(vk, 0, @language_layout)
    # result string is never longer than 2 bytes (Unicode)
    result = "\0" * 2
    # get input string from Win32 API
    length = ToUnicodeEx.call(vk, vsc, @state, result, 2, 0, @language_layout)
    return (length == 0 ? '' : result)
  end
  #----------------------------------------------------------------------------
  # get_input_string
  # Gets the string that was entered using the keyboard over the input locale
  # identifier (formerly called keyboard layout handles).
  #----------------------------------------------------------------------------
  def self.get_input_string
    result = ''
    # check every key
    ALL_KEYS.each {|key|
      # if repeated
      if self.repeat?(key)
      # get (0)character from keyboard state
      c = self.get_character(key)
      # add (0)character if there is a (0)character
      result += c if c != ''
    end}
    # empty if result is empty
    return '' if result == ''
    # convert string from Unicode to UTF-8
    return self.unicode_to_utf8(result)
  end
  #----------------------------------------------------------------------------
  # get_input_string
  # string - string in Unicode format
  # Converts a string from Unicode format to UTF-8 format as RGSS does not
  # support Unicode.
  #----------------------------------------------------------------------------
  def self.unicode_to_utf8(string)
    result = ''
    string.unpack('S*').each {|c|
    # characters under 0x80 are 1 byte characters
    if c < 0x0080
      result += c.chr
      # other characters under 0x800 are 2 byte characters
    elsif c < 0x0800
      result += (0xC0 | (c >> 6)).chr
      result += (0x80 | (c & 0x3F)).chr
      # the rest are 3 byte characters
    else
      result += (0xE0 | (c >> 12)).chr
      result += (0x80 | ((c >> 12) & 0x3F)).chr
      result += (0x80 | (c & 0x3F)).chr
    end}
    return result
  end
end
