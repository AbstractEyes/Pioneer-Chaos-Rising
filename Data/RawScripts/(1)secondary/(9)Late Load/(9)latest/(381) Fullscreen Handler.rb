=begin
# Fullscreen++ v1.0 by Zeus81
# Description :
#   Permet d'avoir un mode plein écran plus intelligent qui utilise un maximum
#   de la surface de l'écran tout en gardant le bon ratio.
#   Alt+Entreé utilise toujours l'ancien mode plein.
#   Pour utiliser ce nouveau mode plein écran appuyez sur F5.
#   Pour faire démarrer le jeu automatiquement en plein écran voir ligne 14.
# Méthodes :
#   Graphics.fullscreen?     : pour savoir si on est en mode plein écran ou pas.
#   Graphics.fullscreen_mode : passe en mode plein écran.
#   Graphics.windowed_mode   : passe en mode fenêtré.
#   Graphics.toggle_mode     : passe d'un mode à l'autre.
class << Graphics
  fullscreen_start = false
  
  FindWindow       = Win32API.new('user32', 'FindWindow'      , 'pp'          , 'l')
  CreateWindowEx   = Win32API.new('user32', 'CreateWindowEx'  , 'lpplllllllll', 'l')
  UpdateWindow     = Win32API.new('user32', 'UpdateWindow'    , 'l'           , 'l')
  ShowWindow       = Win32API.new('user32', 'ShowWindow'      , 'll'          , 'l')
  SetWindowLong    = Win32API.new('user32', 'SetWindowLong'   , 'lll'         , 'l')
  SetWindowPos     = Win32API.new('user32', 'SetWindowPos'    , 'lllllll'     , 'l')
  GetSystemMetrics = Win32API.new('user32', 'GetSystemMetrics', 'l'           , 'l')
  GetDC            = Win32API.new('user32', 'GetDC'           , 'l'           , 'l')
  FillRect         = Win32API.new('user32', 'FillRect'        , 'lpl'         , 'l')
  CreateSolidBrush = Win32API.new('gdi32' , 'CreateSolidBrush', 'l'           , 'l')
  getWindowRect    = Win32API.new('user32', 'GetWindowRect', 'll', 'l')
  if first_start = !method_defined?(:zeus81_fullscreen_update)
    @@MainWindow = FindWindow.call('RGSS Player', 0)
    @@FullBackWindow = CreateWindowEx.call(Styles.window, 'Static', '', 0x80000000, 0, 0, 0, 0, 0, 0, 0, 0)
#~     @@BackWindow = CreateWindowEx.call(0x08000008, 'Static', '', 0x80000000, 0, 0, 0, 0, 0, 0, 0, 0)
    @@FillRectArgs = [GetDC.call(@@FullBackWindow), [0,0,0xFFFF,0xFFFF].pack('L4'), CreateSolidBrush.call(0)]
    @@fullscreen = false
    alias zeus81_fullscreen_resize_screen resize_screen
    alias zeus81_fullscreen_update        update
  end
  def update
    zeus81_fullscreen_update
    toggle_mode if Input.trigger?(Input.F3)
  end
  def resize_screen(width, height)
    zeus81_fullscreen_resize_screen(width, height)
    fullscreen_mode if fullscreen?
  end
  def fullscreen?() @@fullscreen end
  def toggle_mode() fullscreen? ? windowed_mode : fullscreen_mode end
  def fullscreen_mode
    client_w, client_h = GetSystemMetrics.call(0), GetSystemMetrics.call(1)
    w, h = client_w, client_w * height / width
    h, w = client_h, client_h * width / height if h > client_h
    ShowWindow.call(@@FullBackWindow, 3)
    UpdateWindow.call(@@FullBackWindow)
    FillRect.call(*@@FillRectArgs)
    SetWindowPos.call(@@MainWindow, -1, (client_w-w)/2, (client_h-h)/2, w, h, 0)
    SetWindowLong.call(@@MainWindow, -16, 0x14000000)
    @@fullscreen = true
  end
  def windowed_mode
    client_w, client_h = GetSystemMetrics.call(0), GetSystemMetrics.call(1)
    w = width + (GetSystemMetrics.call(5)+2)*2
    h = height + (GetSystemMetrics.call(6)+2)*2 + GetSystemMetrics.call(4)
    ShowWindow.call(@@FullBackWindow, 0)
    UpdateWindow.call(@@FullBackWindow)
    FillRect.call(*@@FillRectArgs)

    SetWindowPos.call(@@MainWindow, -2, (client_w-w)/2, (client_h-h)/2, w, h, 0)
    SetWindowLong.call(@@MainWindow, -16, Styles.window)#0x14CA0000)
    #0x14CA0000
    $game_party.resolution_handler
    @@fullscreen = false
  end
  alias update_new update unless $@
  def update
    update_new
    @saved_w_rect = Graphics.getWindowLocation
    Graphics.createBlackBars(@saved_w_rect)
  end
  def getWindowLocation
    getWindowRect = Win32API.new("user32.dll", "GetWindowRect",['P','PP'],'N')
    pw = @@MainWindow
    rect = Array.new.fill(0.chr,0..4*4).join
    getWindowRect.call(pw,rect);
    rect=rect.unpack("i*")
    rect[2]=rect[2]-rect[0] #w=x2-x1
    rect[3]=rect[3]-rect[1] #h=y2-y1
    return rect
  end 
  def getBlackBarRects(w_rect)
    
  end
  Graphics.fullscreen_mode if first_start and fullscreen_start
end
=end