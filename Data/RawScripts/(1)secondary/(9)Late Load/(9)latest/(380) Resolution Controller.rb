=begin
class Resolution

  alias initialize_res initialize unless $@
  def initialize
    initialize_res
    initializeApiMethods
    initializeMainRectVariables
    initializeMetrics
    createNewBackgroundExWindow
#~     overlapNewOverOld
    overlapOldWindowWithNew
#~     getWindowInfo    = Win32API.new('user32', 'GetWindowInfo', 'll', 'l')
#~     checkWindowInfo = getWindowRect(window)
#~     p checkWindowInfo.inspect
#~     client_w, client_h = getSystemMetrics.call(0), getSystemMetrics.call(1)
#~     screenwidth = getSystemMetrics.call(0)
#~     screenheight = getSystemMetrics.call(1)
#~     width_multiplier = width + (getSystemMetrics.call(5)+2)*2
#~     height_multiplier = height + (getSystemMetrics.call(6)+2)*2 + getSystemMetrics.call(4)
#~     moveWindow.call(window,((screenwidth - width_multiplier) / 2),((screenheight - height_multiplier) / 2)-20,width_multiplier,height_multiplier,1)
#~     setWindowLong.call(window, -16, Styles.window)

  end

  def update
    window_updates
    check_position
  end
  
  def initializeApiMethods
    @createWindowEx   = Win32API.new('user32', 'CreateWindowEx', 'lppliiiillll', 'l')
    @updateWindow     = Win32API.new('user32', 'UpdateWindow', 'l', 'l')
    @setWindowPos     = Win32API.new('user32', 'SetWindowPos','lllllll','l')
    @getSystemMetrics = Win32API.new('user32', 'GetSystemMetrics', 'I', 'I')
    @showWindow       = Win32API.new('user32', 'ShowWindow', 'll', 'l')
    @moveWindow       = Win32API.new('user32', 'MoveWindow',['l','i','i','i','i','l'],'l')
    @findWindowEx     = Win32API.new('user32', 'FindWindowEx',['l','l','p','p'],'i')
    @mainWindow       = @findWindowEx.call(0,0,"RGSS Player",0)
    @getWindowRect    = Win32API.new("user32", "GetWindowRect",['P','PP'],'N')
    @getWindowInfo    = Win32API.new('user32', 'GetWindowInfo',['l'], 'l')
    @setWindowLong    = Win32API.new('user32', 'SetWindowLong','lll','l')
    @fillRect         = Win32API.new('user32', 'FillRect', 'lpl', 'l')
    @getDC            = Win32API.new('user32', 'GetDC', 'l', 'l')
    @createSolidBrush = Win32API.new('gdi32' , 'CreateSolidBrush', 'l', 'l')
  end
  
  def initializeMainRectVariables
    @m_rect = f_getMainWindowRect
    @m_r_x1 = @m_rect[0]
    @m_r_y1 = @m_rect[1]
    @m_r_x2 = @m_rect[2]
    @m_r_y2 = @m_rect[3]
    @m_x = @m_r_x1
    @m_y = @m_r_y1
    @m_width = @m_r_x2 - @m_r_x1 
    @m_height = @m_r_y2 - @m_r_y1
  end
  
  def initializeMetrics
    defWidth     = 544
    defHeight    = 416
    screenWidth = @getSystemMetrics.call(0)
    screenHeight = @getSystemMetrics.call(1)
    @width_multiplier = defWidth + (@getSystemMetrics.call(5)+8)*2
    @height_multiplier = defHeight + (@getSystemMetrics.call(6)+7)*2 + @getSystemMetrics.call(4)
    @defaultWidth = (screenWidth - @width_multiplier) / 2
    @defaultHeight = ((screenHeight - @height_multiplier) / 2)
  end
  
  def f_getMainWindowRect
    pw = @mainWindow
    rect = Array.new.fill(0.chr,0..4*4).join
    @getWindowRect.call(pw,rect);
    rect=rect.unpack("i*")
    rect[2]=rect[2]-rect[0] #w=x2-x1
    rect[3]=rect[3]-rect[1] #h=y2-y1
#~     p rect.inspect
    return rect
  end 
  
  def createNewBackgroundExWindow
    @backWindow = @createWindowEx.call(0, "RGSS Player", '', Window_Styles.backWindow,@m_r_x1,@m_r_y1,@width_multiplier,@height_multiplier,0,0,0,0) #0x80000008,
    @showWindow.call(@backWindow, 3)
    @updateWindow.call(@backWindow)
    @setWindowPos.call(@backWindow, 0, @m_r_x1-8,@m_r_y1-30,@width_multiplier+16,@height_multiplier+38, 0)
    @setWindowLong.call(@backWindow, -16, Window_Styles.backWindow)#0x14CA0000)
  end
  
  def overlapOldWindowWithNew
    @showWindow.call(@mainWindow, 5)
    @updateWindow.call(@mainWindow)
    @setWindowPos.call(@mainWindow, 1, @m_r_x1,@m_r_y1,@width_multiplier,@height_multiplier, 0)
    @setWindowLong.call(@mainWindow, -16, Window_Styles.frontWindow)#0x14CA0000)
  end
  
  def overlapNewOverOld
    
    #default window 0x14CA0000

  end

  def resized?
    # Has the window been resized since its last check?
  end

end

class << Graphics
  
  alias initialize_resolution initialize
  def initialize    
    @resolution = Resolution.new if @resolution == nil
    initialize_resolution
  end
end
=end