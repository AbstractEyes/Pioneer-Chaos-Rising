=begin
class << Graphics  
  @@createWindowEx   = Win32API.new('user32', 'CreateWindowEx', 'lppliiiillll', 'l')
  @@updateWindow     = Win32API.new('user32', 'UpdateWindow', 'l', 'l')
  @@setWindowPos     = Win32API.new('user32', 'SetWindowPos','lllllll','l')
  @@getSystemMetrics = Win32API.new('user32', 'GetSystemMetrics', 'I', 'I')  
  @@showWindow       = Win32API.new('user32', 'ShowWindow', 'll', 'l')
  @@moveWindow       = Win32API.new('user32', 'MoveWindow',['l','i','i','i','i','l'],'l')
  @@findWindowEx     = Win32API.new('user32', 'FindWindowEx',['l','l','p','p'],'i')
  @@mainWindow       = @@findWindowEx.call(0,0,"RGSS Player",0)
  @@getWindowRect    = Win32API.new("user32", "GetWindowRect",['P','PP'],'N')
  @@getWindowInfo    = Win32API.new('user32', 'GetWindowInfo',['l'], 'l')
  @@setWindowLong    = Win32API.new('user32', 'SetWindowLong','lll','l')
  @@fillRect         = Win32API.new('user32', 'FillRect', 'lpl', 'l')
  @@getDC            = Win32API.new('user32', 'GetDC', 'l', 'l')
  @@createSolidBrush = Win32API.new('gdi32' , 'CreateSolidBrush', 'l', 'l')
  
  @@getThreadProcess = Win32API.new('user32', 'GetWindowThreadProcessId', 'LP','L')  
  @@getForeWindow    = Win32API.new('user32', 'GetForegroundWindow', [], 'l')
  @@getActiveWindow  = Win32API.new('user32', 'GetActiveWindow', [], 'l')
  @@backWindow       = nil
  
  @@ratioValue       = 1.30769230769231
  @@screenWidth      = @@getSystemMetrics.call(0)
  @@screenHeight     = @@getSystemMetrics.call(1)
  
  def setDefaultWindow
    initialize_data
  end

  alias update_replace update unless $@
  def update
    update_replace
    if changed?
      force_resolution
      initialize_data
    end
  end
  
  def initialize_data
    initializeMainRectVariables
    initializeMetrics 
    setUpMainWindow
  end
  
  def initializeMainRectVariables
    @@m_rect = f_getMainWindowRect
    @@m_r_x1 = @@m_rect[0]
    @@m_r_y1 = @@m_rect[1]
    @@m_r_x2 = @@m_rect[2]
    @@m_r_y2 = @@m_rect[3]
    @@m_x = @@m_r_x1
    @@m_y = @@m_r_y1
    @@m_width = @@m_r_x2 - @@m_r_x1 
    @@m_height = @@m_r_y2 - @@m_r_y1
  end
  
  def initializeMetrics
    defWidth     = $def_width
    defHeight    = $def_height
    screenWidth = @@getSystemMetrics.call(0)
    screenHeight = @@getSystemMetrics.call(1)
    @@width_multiplier = defWidth + (@@getSystemMetrics.call(5)+8)*2
    @@height_multiplier = defHeight + (@@getSystemMetrics.call(6)+7)*2 + @@getSystemMetrics.call(4)
    @@defaultWidth = ((screenWidth - @@width_multiplier) / 2)
    @@defaultHeight = ((screenHeight - @@height_multiplier) / 2)
  end
  
  def f_getMainWindowRect
    pw = @@mainWindow
    rect = Array.new.fill(0.chr,0..4*4).join
    @@getWindowRect.call(pw,rect);
    rect=rect.unpack("i*")
    rect[2]=rect[2]-rect[0] #w=x2-x1
    rect[3]=rect[3]-rect[1] #h=y2-y1
    return rect
  end 
  
  def setUpMainWindow
    @@showWindow.call(@@mainWindow, 5)
    @@updateWindow.call(@@mainWindow)
    @@setWindowLong.call(@@mainWindow, -16, Window_Styles.backWindow)#0x14CA0000)
    @@setWindowPos.call(@@mainWindow, 0, $def_x,$def_y,@@width_multiplier,@@height_multiplier, 0)
  end

  def changed?
    rect = f_getMainWindowRect
    if $def_x != rect[0] or $def_y != rect[1] or 
          $def_width != (rect[2] - 18) or 
          $def_height != (rect[3] - 38)
      $def_x = rect[0]
      $def_y = rect[1]
      $def_width = (rect[2] - 18)
      $def_height = (rect[3] - 38)
      return true
    end
    return false
  end
    
  # Runs the logical process to create a proper valued ratio for the
  # main game window.  This loop is still buggy, but it is much better
  # than the last loop.
  def force_resolution
    # Determines ratio from constant
    saved_ratio = (@@ratioValue*10000).truncate.to_i
    # Checks if ratio is less than the minimum limit.
    $def_width = 544 if $def_width < 544
    $def_height = 416 if $def_height < 416
    # Checks if the ratio is too large compared to your monitor.
    $def_width -= ($def_width * 0.20).to_i if $def_width > @@screenWidth
    $def_height -= ($def_height * 0.20).to_i if $def_height > @@screenHeight
    # Chops off the extra counts from the ratioif need be.
    $def_width = $def_width - ($def_width % 17) if $def_width % 17 != 0
    $def_height = $def_height - ($def_height % 13) if $def_height % 13 != 0
    # Creates a new ratio from the chopped counts
    new_ratio = (($def_width.to_f/$def_height.to_f)*10000).truncate.to_i
    # Runs a loop until the new ratio equals the saved ratio.
    until new_ratio == saved_ratio
      # If the ratio is greater than the ratio, the width is larger, so
      # increase the height
      if new_ratio > saved_ratio
        if $def_height < @@screenHeight
          $def_height += 13
        else
          $def_width -= 17
        end
      # Elseif increase the width, because the width needs to be changed.
      elsif new_ratio < saved_ratio
        if $def_width < @@screenWidth
          $def_width += 17
        else
          $def_height -= 13
        end
      end
      # Resets the main loop's variable to test again.
      new_ratio = (($def_width.to_f/$def_height.to_f)*10000).truncate.to_i
    end
    if $def_width > @@screenWidth or $def_height > @@screenHeight
      $def_width -= ($def_width * 0.10).to_i
      $def_height -= ($def_height * 0.10).to_i
    end
    # Repositions the window if the window is out of balance
    $def_x = 0 if $def_x < 0
    $def_x = (@@screenWidth / 2).to_i if $def_x > @@screenWidth
    $def_y = 0 if $def_y < 0
    $def_y = (@@screenHeight / 2).to_i if $def_y > @@screenHeight
    # Checks if the window is too far to the right.
    $def_x = (@@screenWidth - $def_width) if ($def_x + $def_width) > @@screenWidth
    $def_y = (@@screenHeight - $def_height) if ($def_y + $def_height) > @@screenHeight
    # Once the new resolution is ready, it saves to file.
    save_resolution_file
  end
  
  # In case you somehow break it, you have an out.
  def save_resolution_file
    fpath = "System/saved_resolution.txt"
    File.open(fpath, 'w') do |file|
      file.puts "#{$def_x}"
      file.puts "#{$def_y}"
      file.puts "#{$def_width}"
      file.puts "#{$def_height}"
      file.puts "#{$use_controller}"
    end
  end
  
end

=end

#~   
#~   def createNewBackgroundExWindow
#~     @@backWindow = @@createWindowEx.call(0, "RGSS Player", 'Pioneercraft', Window_Styles.backWindow,@@m_r_x1,@@m_r_y1,@@width_multiplier,@@height_multiplier,0,0,0,0) #0x80000008,
#~     @@backWindowClass = System_Window.new(@@backWindow)
#~     @@showWindow.call(@@backWindow, 3)
#~     @@updateWindow.call(@@backWindow)
#~     @@backWindowClass.x = @@m_r_x1-8
#~     @@backWindowClass.y = @@m_r_y1-30
#~     @@backWindowClass.width = @@width_multiplier+16
#~     @@backWindowClass.height = @@height_multiplier+38
#~     @@setWindowPos.call(@@backWindow, 0, @@backWindowClass.x,@@backWindowClass.y,@@backWindowClass.width,@@backWindowClass.height, 0)
#~     @@setWindowLong.call(@@backWindow, -16, Window_Styles.backWindow)#0x14CA0000)
#~   end
#~   
#~   def sub_window_selected?
#~     current_window = @@getForeWindow.call

#~     pid = [0].pack('L')
#~     windThread = @@getThreadProcess.call(current_window,pid)
#~     pid = pid.unpack('L')[0]
#~     if current_window == @@backWindowClass.window
#~       p "working"
#~       @@showWindow.call(@@mainWindow, 0)
#~       @@updateWindow.call(@@mainWindow)
#~       wait(60)
#~       @@showWindow.call(@@mainWindow, 5)
#~     end
#~   end
#~   
#~   def resized?
#~     # Has the window been resized since its last check?
#~   end

#~   def back_window_metrics
#~     
#~   end
