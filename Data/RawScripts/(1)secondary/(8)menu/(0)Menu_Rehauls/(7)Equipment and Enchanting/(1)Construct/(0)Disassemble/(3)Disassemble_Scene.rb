class Disassemble_Scene < Scene_Base

  def start
    super
    @background = Sprite.new
    @background.bitmap = Cache.system('/book/background')
  end
end
