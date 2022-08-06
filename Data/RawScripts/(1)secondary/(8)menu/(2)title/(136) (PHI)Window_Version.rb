class Window_Version < Window_Base
  
  def initialize(x,y,width,height)
    super(x,y,width,height)
    set_version
  end
  
  def set_version
    current_version = "Version: #{$system.version}"
    self.contents.draw_text(0,0,width,WLH,current_version)
  end
  
end