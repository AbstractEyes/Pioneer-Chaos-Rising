

class Enchant_Battery_Icons < Window_Base
  def initialize(x,y,w,h)
    super(x,y,w,h)
    create_contents
    for i in 0...9
      rect = Rect.new(0,i*32,32,32)
      self.draw_map_icon(PHI::ICONS::STATS[PHI::ENCHANTMENT.elemental_keys[i]][0], rect.x, rect.y)
    end
  end
end

class Dynamic_Icon < Sprite
  def prepare(icon_index, enabled, key, data, positive)
    draw_map_icon(icon_index, 0,0, enabled)
    #convert = PHI::ENCHANTMENT::CONVERTED_FRAGMENT_KEYS[key]
    #p convert
    #if enabled
    #  color = self.bitmap.font.color
    #  self.bitmap.font.size = 14
    #  self.bitmap.draw_text(0, 0, 40, 20, positive ? '+'+convert.to_s.upcase+'%' : '-'+convert.to_s.upcase+'%')
    #  self.bitmap.font.color = color
    #end
    @flash_duration = 0
    @flashing = false
    @max_duration = 0
    @flash_color = nil
    @data = data
  end

  def update
    super
    @flash_duration -= 1 if @flash_duration > 0
    if @flashing && @flash_duration == 0
      @flash_duration = @max_duration
      self.flash(@flash_color, @max_duration)
    end
  end

  def turn_red
    self.color = PHI.color(:RED)
  end

  def restore_color
    self.color = Color.new(0, 0, 0, 0)
  end

  def start_flash(color,duration)
    @max_duration = duration
    @flash_color = color
    @flash_duration = 0
    @flashing = true
  end

  def stop_flash
    @max_duration = 0
    @flashing = false
    @flash_duration = 0
    @flash_color = nil
  end

  def draw_map_icon(icon_index, x, y, enabled = true)
    bitmap = Cache.system("Iconset2")
    rect = Rect.new(icon_index % 16 * 32, icon_index / 16 * 32, 32, 32)
    self.bitmap = Bitmap.new(32,32) if self.bitmap.nil?
    self.bitmap.blt(x, y, bitmap, rect, enabled ? 255 : 40)
  end

end

class Enchant_Grid_Interface < Window_Selectable

  def initialize(x,y,w,h)
    super(x,y,w,h)
    @item_max = 108
    @column_max = 12
    @wlh2 = 32
    self.index = 0
    @spacing = 0
    @icon_trim = Enchant_Battery_Icons.new(self.x - 64, self.y, 64, self.height)
    @icon_trim.visible = false
    @last_index = -1
    @icons = []
  end

  def book_key
    PHI::ENCHANTMENT::EQUIPMENT_FRAGMENT_TABLE[:ele_key_order][self.index / 12]
  end

  def column
    return self.index % 12 / 3
  end

  def enchantment
    edata = @flat_data[self.index]
    if edata.is_a?(Array)
      # element
      type = edata[0]
      e_id = edata[1]
      fdata = PHI::ENCHANTMENT::FRAGMENT_TYPE_DATA[edata[0]]
      value = fdata[1]
      costs = fdata[2]
    else
      # normal
      type = edata
      e_id = -1
      fdata = PHI::ENCHANTMENT::FRAGMENT_TYPE_DATA[edata]
      value = fdata[1]
      costs = fdata[2]
    end
    return Enchantment_Fragment.new(type, value, book_key, e_id, 1, costs)
  end

  def update
    super
    if self.index != @last_index && !@icons.empty?
      @last_index = self.index
      @icons.each {|icon| icon.stop_flash}
      if self.active
        @icons[self.index].start_flash(PHI.color(:WHITE, 100), 10)
      end
    end
    @icon_trim.update
    @icons.each {|icon| icon.update} unless @icons.empty?
  end

  def dispose
    super
    @icon_trim.dispose
    @icons.each {|icon| icon.dispose} unless @icons.empty?
    @icons.clear
  end

  def active=(new_active)
    @icons.each {|icon| icon.stop_flash }
    if new_active && !@icons.empty?
      @icons[self.index].start_flash(PHI.color(:WHITE, 100), 10)
    end
    super
  end

  def visible=(new_visible)
    @icon_trim.visible = new_visible
    @last_index = -1 if new_visible
    unless @icons.nil?
      @icons.each {|icon| icon.stop_flash } unless new_visible
      @icons.each {|icon| icon.visible = new_visible}
    end
    super
  end

  def refresh(db_id, socket_id)
    return if socket_id < 0
    @equip = $game_party.equipment[db_id]
    @socket = @equip.sockets[socket_id]
    @socket_id = socket_id
    #prepare
    create_contents
    #$game_party.unlock_all_enchant_books
    @data = PHI::ENCHANTMENT.book_list
    @flat_data = PHI::ENCHANTMENT.flat_book_list
    @unlocked = $game_party.enchant_books
    return unless @icons.empty?
    for i in 0...PHI::ENCHANTMENT.elemental_keys.size
      element = PHI::ENCHANTMENT.elemental_keys[i]
      for bi in 0...@data[element].size
        enabled = @unlocked.keys.include?(element)
        enabled = @unlocked[element].include?(bi) if enabled
        draw_book(@data[element][bi], i*4+bi, enabled)
      end
    end
  end

  def refresh_functionality

  end

  def draw_book(book, position_index, enabled)
    i = position_index * 3
    rect = item_rect(i)
    rect.x -= 48

    for n in 0...book.size
      rect = item_rect(i + n)
      #rect.x += 32
      book[n].is_a?(Array) ? sym = book[n][0] : sym = book[n]
      case sym
        when :ele_res, :ele_dam
          icon = Dynamic_Icon.new
          icon.prepare(PHI::ICONS::STATS[(PHI::ENCHANTMENT.physical_elements + PHI::ENCHANTMENT.elemental_keys)[book[n][1]-1]][0],
                       enabled,
                       :ele_dam,
                       PHI::ENCHANTMENT::FRAGMENT_TYPE_DATA[:ele_dam], true)
          icon.x = self.x + rect.x + 18
          icon.y = self.y + rect.y + 18
          icon.z = self.z + 1
          @icons.push icon
        #self.draw_map_icon()
        else
          icon = Dynamic_Icon.new
          icon.prepare(PHI::ICONS::STATS[sym][0], enabled,
                       sym,
                       PHI::ENCHANTMENT::FRAGMENT_TYPE_DATA[sym],
                       true)
          icon.x = self.x + rect.x + 18
          icon.y = self.y + rect.y + 18
          icon.z = self.z + 1
          @icons.push icon
        #self.draw_map_icon(PHI::ICONS::STATS[sym][0], rect.x, rect.y)
      end
    end
  end

  def draw_enchantment(pos, index)

  end

end

class Enchant_Grid_Help < Window_Base

  def initialize(x,y,w,h)
    super(x,y,w,h)
  end

  def refresh

  end

end

