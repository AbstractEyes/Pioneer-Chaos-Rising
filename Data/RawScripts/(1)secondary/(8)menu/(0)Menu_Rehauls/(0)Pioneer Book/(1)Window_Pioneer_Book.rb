class Sprite
  def xy=(coord = Coord.new(0,0))
    self.x = coord.x
    self.y = coord.y
  end
end

class Ribbon_Sprite < Sprite

  def initialize(*args)
    super(*args)
    @base_pos = Coord.new(self.x,self.y)
    @base_color = Color.new(0,0,0,0)
    @flash_color = Color.new(255,255,255,80)
    @flash = false
    @ascending = true
    @flash_time = 0
    @flash_max_time = 40.0
    self.visible = false
  end

  def bitmap=(new_bitmap)
    super
    @saved_ribbon = new_bitmap.clone
  end

  def set_bitmap(new_bitmap)
    self.bitmap = new_bitmap
  end

  def chop_end
    self.bitmap.clear_rect(72,
                           0,
                           self.bitmap.width,
                           self.bitmap.height)
  end

  def revert_end
    self.bitmap = @saved_ribbon.clone
  end

  def dispose
    super
    @saved_ribbon.dispose
  end

  def flashing?
    return @flash
  end

  def x=(new_x)
    super
    @base_pos.x = new_x if @base_pos.x == 0
  end
  def y=(new_y)
    super
    @base_pos.y = new_y if @base_pos.y == 0
  end

  def update
    super
    if @flash
      update_flash
    end
  end

  def update_flash
    temp = @flash_color.clone
    temp.alpha = (temp.alpha / @flash_max_time) * @flash_time
    self.color = temp
    if @ascending && @flash_time < @flash_max_time
      @flash_time += 1
    elsif !@ascending && @flash_time > 0
      @flash_time -= 1
    end
    if @flash_time == @flash_max_time
      @ascending = false
    elsif @flash_time == 0
      @ascending = true
    end
  end

  def normalize
    self.color = @base_color
    @flash_time = 0
    @flash = false
    self.x = @base_pos.x
    self.y = @base_pos.y
  end

  def std_flash
    @flash_time = 0
    @flash = true
    self.x -= 56 + 24
  end

end

class Window_Pioneer_Book < Window_Base
  attr_reader   :main_ribbons
  attr_accessor :page
  attr_accessor :contents_index
  attr_accessor :secondary_index

  def initialize(x,y,w,h)
    super(x,y,w,h)
    self.opacity = 0
    @contents_index = 0
    @secondary_index = 0
    @page = 0
    @last_page = -1
    @book = {}
    @main_ribbons = {}
    @team_ribbons = {}
    @inventory_ribbons = {}
    @guild_ribbons = {}
    @shown = false
    create_book
    create_primary_ribbons
    create_team_ribbons
    create_inventory_ribbons
    create_guild_ribbons
    hide_ribbons
    refresh
  end

  def item_max
    case @page
      when 0 #cover
        return @main_ribbons.keys.size
      when 1 #team
        return @team_ribbons.keys.size
      when 2 #inventory
        return @inventory_ribbons.keys.size
      when 3 #guild
        return @guild_ribbons.keys.size
      #when 3
      #when 4
      #when 5
      else

    end
  end

  def page_max
    return 4
  end

  def index=(new_val)
    case @page
      when 0
        @contents_index = new_val
      when 1
        @secondary_index = new_val
    end
    refresh
  end

  def index
    case @page
      when 0
        return @contents_index
      else
        return @secondary_index
    end
  end

  def create_book
    @book[0] = Sprite.new
    @book[0].bitmap = Cache.system('\book\pioneer_book_closed').clone

    @book[1] = Sprite.new
    @book[1].bitmap = Cache.system('\book\pioneer_book_open1').clone

    @book[2] = Sprite.new
    @book[2].bitmap = Cache.system('\book\pioneer_book_open2').clone

    @book[3] = Sprite.new
    @book[3].bitmap = Cache.system('\book\pioneer_book_open3').clone

    @book[4] = Sprite.new
    @book[4].bitmap = Cache.system('\book\pioneer_book_open4').clone

    @book[5] = Sprite.new
    @book[5].bitmap = Cache.system('\book\pioneer_book_open5').clone

    @book[6] = Sprite.new
    @book[6].bitmap = Cache.system('\book\pioneer_book_open6').clone

    @book[7] = Sprite.new
    @book[7].bitmap = Cache.system('\book\pioneer_book_open7').clone
    @book.each_value {|book| book.visible = false}

    @backup_open_page = @book[7].bitmap.clone

  end

  def animate_book_zoom_out
    @book.each_value { |img| img.visible = false }
    @book[@book.keys.sort.last].visible = true
    @book[@book.keys.sort.last].ox = 100
    @book[@book.keys.sort.last].oy = 40
    @book[@book.keys.sort.last].zoom_x = 1.4
    @book[@book.keys.sort.last].zoom_y = 1.4
    @book[@book.keys.sort.last].update
    for i in 0...4
      @book[@book.keys.sort.last].zoom_x -= 0.1
      @book[@book.keys.sort.last].zoom_y -= 0.1
      @book[@book.keys.sort.last].ox -= 100 / 4
      @book[@book.keys.sort.last].oy -= 40 / 4
      @book[@book.keys.sort.last].update
      Graphics.update
    end
    @shown = true
  end

  def animate_book_zoom_in
    hide_ribbons
    @book.each_value { |img| img.visible = false }
    @book[@book.keys.sort.last].visible = true
    #@book[@book.keys.sort.last].ox = 100
    #@book[@book.keys.sort.last].oy = 40
    @book[@book.keys.sort.last].zoom_x = 1
    @book[@book.keys.sort.last].zoom_y = 1
    @book[@book.keys.sort.last].update
    for i in 0...4
      @book[@book.keys.sort.last].zoom_x += 0.085
      @book[@book.keys.sort.last].zoom_y += 0.1
      @book[@book.keys.sort.last].ox += 28
      @book[@book.keys.sort.last].oy += 20
      @book[@book.keys.sort.last].update
      Graphics.update
    end
  end

  def animate_book_open
    i = 0
    @book[0].visible = true
    @book[0].update
    while i < 12
      i += 1
      Graphics.update
      @book[0].x += 11
      @book[0].update
    end
    @book[0].visible = false
    @book[0].update
    done = false
    @book.keys.sort.each do |index|
      if index > 3 && !done
        refresh_contents
        done = true
      end
      @book[index].visible = true
      @book[index].update
      Graphics.update
      @book[index].visible = false
      @book[index].update
    end
    @book[@book.keys.sort.last].visible = true
    @shown = true
    refresh
  end

  def animate_book_close
    #hide_ribbons
    @book.each_value {|value| value.visible = false}
    done = false
    @book.keys.sort.reverse.each do |index|
      if index < 3 && !done
        hide_ribbons
        done = true
      end
      @book[index].visible = true
      @book[index].update
      Graphics.update
      @book[index].visible = false
      @book[index].update
    end
    @book[@book.keys.sort[0]].visible = true
  end

  def create_ribbon(hash, location, x, y, gap=64)
    pos = hash.keys.size
    hash[pos]         = Ribbon_Sprite.new
    hash[pos].bitmap  = Cache.system(location).clone
    hash[pos].xy      = Coord.new(x,y+(gap*pos))
  end

  def create_primary_ribbons
    create_ribbon(@main_ribbons, '\book\ribbon_team', 534, 100)
    create_ribbon(@main_ribbons, '\book\ribbon_inventory', 534, 100)
    create_ribbon(@main_ribbons, '\book\ribbon_guild', 534, 100)
    create_ribbon(@main_ribbons, '\book\ribbon_fly', 534, 100)
    create_ribbon(@main_ribbons, '\book\ribbon_options', 534, 100)
  end

  def create_team_ribbons
    create_ribbon(@team_ribbons, '\book\ribbon_status', 534, 122)
    create_ribbon(@team_ribbons, '\book\ribbon_skills', 534, 122)
    create_ribbon(@team_ribbons, '\book\ribbon_members', 534, 122)
    create_ribbon(@team_ribbons, '\book\ribbon_formations', 534, 122)
  end

  def create_inventory_ribbons
    create_ribbon(@inventory_ribbons, '\book\ribbon_storage', 534,  100, 54)
    create_ribbon(@inventory_ribbons, '\book\ribbon_equip', 534,    100, 54)
    create_ribbon(@inventory_ribbons, '\book\ribbon_craft', 534,    100, 54)
    create_ribbon(@inventory_ribbons, '\book\ribbon_upgrade', 534,  100, 54)
    create_ribbon(@inventory_ribbons, '\book\ribbon_enchant', 534,  100, 54)
    create_ribbon(@inventory_ribbons, '\book\ribbon_grinder', 534,  100, 54)
  end

  def create_guild_ribbons
    create_ribbon(@guild_ribbons, '\book\ribbon_requests', 534, 122)
    create_ribbon(@guild_ribbons, '\book\ribbon_tasks', 534, 122)
    create_ribbon(@guild_ribbons, '\book\ribbon_completed', 534, 122)
  end

  def dispose
    @book.each_value{ |book| book.dispose }
    @main_ribbons.each_value{ |ribbon| ribbon.dispose }
    @team_ribbons.each_value{ |ribbon| ribbon.dispose }
    @inventory_ribbons.each_value{ |ribbon| ribbon.dispose }
    @guild_ribbons.each_value{ |ribbon| ribbon.dispose }
    super
  end

  def update
    super
    b_keys = @book.keys; keys = @main_ribbons.keys; keys2 = @team_ribbons.keys;
    keys3 = @inventory_ribbons.keys; keys4 = @guild_ribbons.keys;
    for i in 0...b_keys.size; @book[b_keys[i]].update; end
    for i in 0...keys.size; @main_ribbons[keys[i]].update; end
    for i in 0...keys2.size; @team_ribbons[keys2[i]].update; end
    for i in 0...keys3.size; @inventory_ribbons[keys3[i]].update; end
    for i in 0...keys4.size; @guild_ribbons[keys4[i]].update; end
  end

  def last_item
    case @page
      when 0
        @contents_index -= 1
        if @contents_index < 0
          @contents_index = item_max - 1
        end
      else
        @secondary_index -= 1
        if @secondary_index < 0
          @secondary_index = item_max - 1
        end
    end
    refresh
  end

  def next_item
    case @page
      when 0
        @contents_index += 1
        if @contents_index > item_max - 1
          @contents_index = 0
        end
      else
        @secondary_index += 1
        if @secondary_index > item_max - 1
          @secondary_index = 0
        end
    end
    refresh
  end

  def next_category
    @secondary_index = 0
    @page += 1
    if @page > page_max
      @page = 0
    end
    refresh
  end

  def last_category
    @secondary_index = 0
    @page -= 1
    if @page < 0
      @page = page_max
    end
    refresh
  end

  def set_category(input = 0)
    @page = input
    refresh
  end

  def hide_ribbons
    @main_ribbons.each_value{ |ribbon| ribbon.visible = false }
    @team_ribbons.each_value{ |ribbon| ribbon.visible = false  }
    @inventory_ribbons.each_value{ |ribbon| ribbon.visible = false  }
    @guild_ribbons.each_value{ |ribbon| ribbon.visible = false  }
  end

  def refresh
    return unless @shown
    if @page != @last_page
      hide_ribbons
      @last_page = @page
      #@secondary_index = 0 if @page > 0
      refresh_contents
    end
    case @page
      when 0
        refresh_contents
      when 1
        refresh_team
      when 2
        refresh_inventory
      when 3
        refresh_guild
    end
    update
  end

  def refresh_team
    draw_list
    @team_ribbons.each_value {|ribbon| ribbon.normalize; ribbon.visible = true;}
    @secondary_index = 0 unless @team_ribbons.keys.include?(@secondary_index)
    @team_ribbons[@secondary_index].std_flash
    @team_ribbons.each_value {|ribbon| ribbon.flashing? ? ribbon.revert_end : ribbon.chop_end }
  end

  def refresh_inventory
    draw_list
    @inventory_ribbons.each_value {|ribbon| ribbon.normalize; ribbon.visible = true}
    @secondary_index = 0 unless @inventory_ribbons.keys.include?(@secondary_index)
    @inventory_ribbons[@secondary_index].std_flash
    @inventory_ribbons.each_value {|ribbon| ribbon.flashing? ? ribbon.revert_end : ribbon.chop_end }
  end

  def refresh_contents
    draw_list
    @main_ribbons.each_value { |ribbon| ribbon.normalize; ribbon.visible = true }
    @contents_index = 0 unless @main_ribbons.keys.include?(@contents_index)
    @main_ribbons[@contents_index].std_flash
    @main_ribbons.each_value {|ribbon| ribbon.flashing? ? ribbon.revert_end : ribbon.chop_end }
    if @page > 0
      @book[@book.keys.size - 1].bitmap = Cache.system('\book\pioneer_book_open7').clone
      @main_ribbons.each_value {|ribbon| ribbon.visible = false unless ribbon.flashing?; ribbon.y = 48; ribbon.x = 480;}
    else
      sfont = @book[@book.keys.size - 1].bitmap.font.size
      @book[@book.keys.size - 1].bitmap.font.color = PHI.color(:BLACK)
      @book[@book.keys.size - 1].bitmap.font.size = 52
      @book[@book.keys.size - 1].bitmap.draw_text(400,40,self.width,52,'Contents')
      @book[@book.keys.size - 1].bitmap.font.size = sfont
    end
  end

  def refresh_guild
    draw_list
    @guild_ribbons.each_value { |ribbon|ribbon.normalize; ribbon.visible = true }
    @secondary_index = 0 unless @guild_ribbons.keys.include?(@secondary_index)
    @guild_ribbons[@secondary_index].std_flash
    @guild_ribbons.each_value {|ribbon| ribbon.flashing? ? ribbon.revert_end : ribbon.chop_end }
  end

  def draw_list
    #Todo: draw list for this page
  end


end