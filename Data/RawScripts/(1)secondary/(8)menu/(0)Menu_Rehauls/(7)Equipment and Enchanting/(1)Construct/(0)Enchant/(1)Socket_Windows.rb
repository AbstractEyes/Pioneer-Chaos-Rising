class Enchant_Socket_Decision < Window_Selectable

  def initialize(x,y,w,h)
    super(x,y,w,h)
    @wlh2 = 32
    @column_max = 3
  end

  def item_rect(index)
    rect = super(index)
    rect.width = 32
    rect.height = 32
    rect.y += 16
    return rect
  end

  def refresh(db_id)
    db_id = 1 if db_id == -1
    @equip_id = db_id
    @equip = $game_party.equipment[@equip_id]
    @item_max = [1, @equip.max_sockets].max * 3
    @wlh2 = 384 / @item_max * 3
    create_contents
    self.index = 0
    for i in 0...@item_max
      case i % 3
        when 0
          draw_sized_icon(1646, item_rect(i), enchantment_empty?(i))
        when 1
          draw_sized_icon(1677, item_rect(i), !enchantment_empty?(i))
        when 2
          draw_sized_icon(1915, item_rect(i), enchantment_empty?(i))
      end
    end
  end

  def enchantment_empty?(index=self.index)
    return !@equip.sockets.include?(index / 3)
  end

  def draw_sized_icon(icon_index, resized_rect, enabled = true)
    bitmap = Cache.system("Iconset2")
    rect = Rect.new(icon_index % 16 * 32, icon_index / 16 * 32, 32, 32)
    self.contents.stretch_blt(resized_rect, bitmap, rect, enabled ? 255 : 100)
  end

end
class Enchant_Socket_List < Window_Selectable

  def initialize(x,y,w,h)
    super(x,y,w,h)
    @column_max = 1
  end

  def get_id
    return @equip_id
  end

  def item_rect(index)
    rect = super(index)
    rect.height -= 4
    rect.y -= 4
    return rect
  end

  def refresh(db_id)
    db_id = 1 if db_id == -1
    @equip_id = db_id
    @equip = $game_party.equipment[@equip_id]
    @item_max = [1, @equip.max_sockets].max
    @wlh2 = 384 / @item_max
    create_contents
    self.index = 0
    for i in 0...@equip.max_sockets
      draw_equip(i)
    end
  end

  def enchantment
    return @equip.sockets[self.index]
  end

  def create_contents
    self.contents.dispose
    maxbitmap = 8192
    dw = [width - 32, maxbitmap].min
    dh = [[height - 32, row_max * @wlh2 - 16].max, maxbitmap].min
    bitmap = Bitmap.new(dw, dh)
    self.contents = bitmap
    self.contents.font.color = normal_color
  end

  def draw_equip(i)
    r = item_rect(i)
    self.contents.fill_rect(r.x,r.y,18,r.height, PHI.color(:GREY, 100))
    self.contents.fill_rect(r.x+2,r.y+2,12,r.height-4, PHI.color(:GREY, 40))
    self.contents.draw_text(r, @equip.socket_density(i))
    r.x += 16
    r.width -= 16
    if @equip.sockets.keys.include?(i)
      # main icon, weight,
      # p @equip.sockets.inspect
      socket = @equip.sockets[i]
      self.contents.fill_rect(r, socket.color)
      draw_map_icon(socket.icon_index, r.x, r.y + @wlh2 / 2 - 16)
      r.x += 38
      fi = -1
      socket.ordered_keys.reverse.each do |key|
        fi += 1
        fragment = socket[key]
        next if fragment.nil?
        draw_map_icon(fragment.icon_index, r.x + 34 * fi, r.y + @wlh2 / 2 - 16)
        socval = fragment.value.to_s
        socval.insert(0, '+') if fragment.value > 0
        socval += '%'
        fragment.value > 0 ? color = PHI.color(:RED) : color = PHI.color(:CYAN)
        fragment.value > 0 ? color2 = PHI.color(:RED, 128) : color2 = PHI.color(:CYAN, 128)
        self.contents.font.color = color2
        self.contents.draw_text(r.x+34*fi+1, r.y + @wlh2 / 2 - 16 + 1, 32, 32, socval)
        self.contents.font.color = color
        self.contents.draw_text(r.x+34*fi, r.y + @wlh2 / 2 - 16, 32, 32, socval)
        self.contents.font.color = normal_color
      end
      r.x += 70 + 34 * fi
      self.contents.draw_text(r, socket.name)
    else
      self.contents.fill_rect(r, PHI.color(:GREY, 100))
      self.contents.draw_text(r, 'Open')
    end
  end

  def draw_map_icon(icon_index, x, y, enabled = true)
    bitmap = Cache.system("Iconset2")
    rect = Rect.new(icon_index % 16 * 32, icon_index / 16 * 32, 32, 32)
    self.contents.blt(x, y, bitmap, rect, enabled ? 255 : 100)
  end

  def draw_sized_icon(icon_index, resized_rect, enabled = true)
    bitmap = Cache.system("Iconset2")
    rect = Rect.new(icon_index % 16 * 32, icon_index / 16 * 32, 32, 32)
    self.contents.stretch_blt(resized_rect, bitmap, rect, enabled ? 255 : 100)
  end

  def cursor_down(wrap = false)
  end
  def cursor_up(wrap = false)
  end
  def cursor_right(wrap = false)
  end
  def cursor_left(wrap = false)
  end
  def cursor_pagedown
  end
  def cursor_pageup
  end

end

class Enchant_Socket_Header < Window_Base

  def initialize(x,y,w,h)
    super(x,y,w,h)
  end

  def refresh(db_id)
    @equip = $game_party.equipment[db_id]
    draw_equip
  end

  def draw_equip
    return if @equip.nil?
    create_contents
    draw_map_icon(@equip.icon_index, 0, 0)
    self.contents.draw_text(32, 0, 128, WLH, @equip.name)
    self.contents.draw_text(32, 20, 128, WLH, 'Level: ' + @equip.level.to_s)
    #draw equip id, equip name, equip level
  end

end

class Enchant_Socket_Details < Window_Base

  def initialize(x,y,w,h)
    super(x,y,w,h)
    self.visible = false
  end

  def refresh(db_id, socket_id)
    return if socket_id < 0
    @equip = $game_party.equipment[db_id]
    @socket = @equip.sockets[socket_id]
    @socket_id = socket_id
    #@item_max = @socket.ordered_keys.size
    create_contents
    return unless self.visible
    #self.index = 0
    draw_socket
  end

  #def create_contents
  #  self.contents.dispose
  #  maxbitmap = 8192
  #  dw = [width - 32, maxbitmap].min
  #  dh = [[height - 32, row_max * @wlh2 - 16].max, maxbitmap].min
  #  bitmap = Bitmap.new(dw, dh)
  #  self.contents = bitmap
  #  self.contents.font.color = normal_color
  #end

  def draw_socket
    if @equip.sockets.keys.include?(@socket_id)
      #p @socket.inspect
      # main icon, weight,
      # p @equip.sockets.inspect
      #self.contents.fill_rect(r, @socket.color)
      draw_map_icon(@socket.icon_index, 0, 0)
      self.contents.draw_text(34, 4, self.contents.width, 32, @socket.name)
      fi = -1
      @socket.ordered_keys.reverse.each do |key|
        fi += 1
        fragment = @socket[key]
        next if fragment.nil?
        draw_map_icon(fragment.icon_index, 4, 60 + fi * 40)
        socval = fragment.value.to_s
        socval.insert(0, '+') if fragment.value > 0
        socval += '% ' + fragment.name
        fragment.value > 0 ? color = PHI.color(:RED) : color = PHI.color(:CYAN)
        fragment.value > 0 ? color2 = PHI.color(:RED, 128) : color2 = PHI.color(:CYAN, 128)
        self.contents.font.color = color2
        self.contents.draw_text(34 + 4, 60 + fi * 40, self.contents.width, 32, socval)
        self.contents.font.color = color
        self.contents.draw_text(34 + 5, 61 + fi * 40, self.contents.width, 32, socval)
        self.contents.font.color = normal_color
      end
    else
      #self.contents.fill_rect(, PHI.color(:GREY, 100))
      self.contents.draw_text(0, 0, self.contents.width, 32, 'Empty Battery Slot')
    end
  end

  def draw_map_icon(icon_index, x, y, enabled = true)
    bitmap = Cache.system("Iconset2")
    rect = Rect.new(icon_index % 16 * 32, icon_index / 16 * 32, 32, 32)
    self.contents.blt(x, y, bitmap, rect, enabled ? 255 : 100)
  end

  def draw_sized_icon(icon_index, resized_rect, enabled = true)
    bitmap = Cache.system("Iconset2")
    rect = Rect.new(icon_index % 16 * 32, icon_index / 16 * 32, 32, 32)
    self.contents.stretch_blt(resized_rect, bitmap, rect, enabled ? 255 : 100)
  end

end