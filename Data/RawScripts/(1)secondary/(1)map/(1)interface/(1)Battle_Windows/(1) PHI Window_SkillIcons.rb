

class Float
  def floor2(exp = 0)
    multiplier = 10 ** exp
    ((self * multiplier).floor).to_f/multiplier.to_f
  end
end
class Array

  def rotate(cnt=1)
    out = self.clone
    for i in 0...cnt
      out.push(out.shift)
    end
    return out
  end

  def rotate!(cnt=1)
    for i in 0...cnt
      self.push(self.shift)
    end
    return self
  end

end

class Skill_Icon < Sprite

  def initialize(*args)
    super(*args)
    @destination = nil
    @steps = 0
    @step_amount = 0
  end

  def update
    super
    @background.update if @background != nil
    if @steps > 0
      step_position
      @steps -= 1
      if @steps == 0
        set_destination
      end
    end
  end

  def dispose
    @background.dispose if @background != nil
    super
  end
  def x=(new_x)
    @background.x -= self.x - new_x unless @background.nil?
    super
  end
  def y=(new_y)
    @background.y -= self.y - new_y unless @background.nil?
    super
  end
  def z=(new_z)
    @background.z = new_z - 1 unless @background.nil?
    super
  end
  def visible=(new_visible)
    @background.visible = new_visible
    super
  end

  def zoom_x=(new_zoom)
    super
    @background.zoom_x = new_zoom
  end
  def zoom_y=(new_zoom)
    super
    @background.zoom_y = new_zoom
  end

  def animate(destination_x, destination_y, destination_zoom_x, destination_zoom_y, destination_z, steps = 12)
    @destination = Coord.new(destination_x, destination_y)
    @zoom = Coord.new(destination_zoom_x, destination_zoom_y)
    @z_destination = destination_z
    @steps = steps
    @step_x = (self.x - @destination.x).to_f / @steps
    @cur_step_x = 0
    @step_y = (self.y - @destination.y).to_f / @steps
    @cur_step_y = 0
    @step_zoom_x = (self.zoom_x - @zoom.x).to_f / @steps
    @cur_step_zoom_x = 0
    @step_zoom_y = (self.zoom_y - @zoom.y).to_f / @steps
    @cur_step_zoom_y = 0
    @step_z = (self.z - destination_z).to_f / @steps
    @cur_step_zoom_z = 0
  end

  def step_position
    self.x -= @step_x
    self.y -= @step_y
    self.zoom_x -= @step_zoom_x
    self.zoom_y -= @step_zoom_y
    self.z -= @step_z
  end

  def set_destination
    self.x = @destination.x
    self.y = @destination.y
    self.z = @z_destination
    self.zoom_x = @zoom.x
    self.zoom_y = @zoom.y
    @destination = nil
    @zoom = nil
    @z_destination = nil
  end

  def animating?
    return @steps > 0
  end

  def draw_icon(icon_index)
    @background.dispose unless @background.nil?
    @background = ::Sprite.new(self.viewport)
    @background.visible = self.visible
    @background.opacity = self.opacity
    @background.x = self.x
    @background.y = self.y
    @background.z = self.z - 1
    @background.bitmap = Bitmap.new(32, 32)
    @background.bitmap.fill_rect(0,0,32,32,PHI.color(:WHITE, 255))
    @background.bitmap.fill_rect(1,1,30,30,PHI.color(:BLACK, 200))
    self.bitmap = Cache.system("Iconset2")
    rect = Rect.new(icon_index % 16 * 32, icon_index / 16 * 32, 32, 32)
    self.src_rect.set(rect.x, rect.y, rect.width, rect.height)
  end

end

class Skill_Help < Window_Base

  def initialize(x,y,width,height)
    super(x,y,width,height)
    @x1 = x
    @y1 = y
    @w1 = width
    @h1 = height
    @skill = nil
    @expand = false
    @column_max = 3.0
    self.back_opacity = 255
  end

  def refresh(skill)
    self.contents.clear
    return if skill.nil?
    @skill = skill
    @expand ? expanded_refresh : retracted_refresh
  end

  def skill
    @skill
  end

  def retracted_refresh
    self.x = @x1
    self.y = @y1
    self.width = @w1
    self.height = @h1
    baked_height = 0
    baked_height += get_node_height(skill.dam_attr)
    baked_height += get_node_height(skill.costs_chopped)
    self.height = baked_height + 80 + 32 + 12
    self.y = @y1 - self.height
    create_contents
    rounded_outline = Rect.new(2, 2, self.contents.width-4, 80)
    rounded_fill = Rect.new(4, 4, self.contents.width-8, 76)
    draw_primary_information(rounded_fill, rounded_outline)
    if has_costs?
      rounded_outline.y += rounded_outline.height+4
      rounded_fill.y += rounded_outline.height+4
      rounded_outline.height = get_node_height(skill.costs_chopped)
      rounded_fill.height = rounded_outline.height - 4
      draw_node_information(rounded_fill, rounded_outline, skill.costs_chopped, 'Costs')
    end
    if has_elements?
      rounded_outline.y += rounded_outline.height+4
      rounded_fill.y += rounded_outline.height+4
      rounded_outline.height = get_node_height(skill.get_ele_dam)
      rounded_fill.height = rounded_outline.height - 4
      draw_node_information(rounded_fill, rounded_outline, skill.get_ele_dam, 'Element Damage')
    end
  end

  def has_damages?
    for damage in skill.damages.values; return true unless damage.empty?; end
    return false
  end
  def has_costs?
    for cost in skill.costs.values; return true unless cost.empty?; end
    return false
  end
  def has_attributes?
    skill.dam_attr.size > 0
  end
  def has_elements?
    skill.ele_dam.size > 0
  end

  def expanded_refresh
    self.x = @x1
    self.y = @y1 - 328
    self.width = @w1
    self.height = @h1 + 328
    create_contents
    rounded_outline = Rect.new(2, 2, self.contents.width-4, 80)
    rounded_fill = Rect.new(4, 4, self.contents.width-8, 76)
    draw_primary_information(rounded_fill, rounded_outline)
    if has_costs?
      rounded_outline.y += rounded_outline.height+4
      rounded_fill.y += rounded_outline.height+4
      rounded_outline.height = get_node_height(skill.costs_chopped)
      rounded_fill.height = rounded_outline.height - 4
      draw_node_information(rounded_fill, rounded_outline, skill.costs_chopped, 'Costs')
    end
    if has_elements?
      rounded_outline.y += rounded_outline.height+4
      rounded_fill.y += rounded_outline.height+4
      rounded_outline.height = get_node_height(skill.get_ele_dam)
      rounded_fill.height = rounded_outline.height - 4
      draw_node_information(rounded_fill, rounded_outline, skill.get_ele_dam, 'Elements')
    end
    if has_attributes?
      rounded_outline.y += rounded_outline.height+4
      rounded_fill.y += rounded_outline.height+4
      rounded_outline.height = get_node_height(skill.dam_attr)
      rounded_fill.height = rounded_outline.height - 4
      draw_attribute_information(rounded_fill, rounded_outline)
    end
    if has_damages?
      rounded_outline.y += rounded_outline.height+4
      rounded_fill.y += rounded_outline.height+4
      rounded_outline.height = get_node_height(skill.damages_chopped)
      rounded_fill.height = rounded_outline.height - 4
      draw_node_information(rounded_fill, rounded_outline, skill.damages_chopped, 'Stats')
    end
  end

  def get_node_height(hash)
    return 0 if hash.is_a?(Array) && hash.size == 0
    return 0 if hash.is_a?(Hash) && hash.keys.size == 0
    return (hash.size / 3.0).ceil * 32 if hash.is_a?(Array)
    return (hash.keys.size / 3.0).ceil * 32
  end

  def draw_primary_information(rect_container, rect_outline)
    self.contents.fill_rounded_rect(rect_outline,PHI.color(:GREY, 200))
    self.contents.fill_rounded_rect(rect_container,PHI.color(:GREY, 20))
    draw_map_icon(skill.icon_index, 6, 6)
    self.contents.draw_text(rect_container.x+36, 0, self.contents.width, 32, skill.name)
    self.contents.font.size = 12
    self.contents.draw_text(rect_container.x+36, 20, self.contents.width, 32, skill.type)
    self.contents.font.size = 14
    self.contents.draw_text(rect_container.x, rect_container.y+32, rect_container.width, 32, skill.description) if skill.description.size <= 30
    self.contents.draw_text(rect_container.x, rect_container.y+32, rect_container.width, 32, skill.description[0...30]) if skill.description.size > 30
    self.contents.draw_text(rect_container.x, rect_container.y+32+16, rect_container.width, 32, skill.description[30...skill.description.size]) if skill.description.size > 30
  end

  def draw_node_information(rect_container, rect_outline, hash, title, priority_hash=nil)
    self.contents.fill_rounded_rect(rect_outline, PHI.color(:GREY, 200))
    self.contents.fill_rounded_rect(rect_container, PHI.color(:GREY, 20))
    saved_size = self.contents.font.size
    self.contents.font.size = 12
    rect_container.y -= 12
    rect_container.x += 22
    bc = rect_container.height
    rect_container.height = 32
    self.contents.draw_text(rect_container, title)
    rect_container.y += 12
    rect_container.x -= 22
    rect_container.height = bc
    self.contents.font.size = saved_size
    hash.sort_by { |key, value| PHI::ICONS::STAT_PRIORITY[key] }.each_with_index do |(key,value),index|
      x2 = rect_container.x + ((((rect_container.width/@column_max).ceil * index) % @column_max.to_i) * (rect_container.width / @column_max))
      y2 = rect_container.y + (32*(index / @column_max.to_i))
      color = self.contents.font.color.clone
      self.contents.font.color = PHI::ICONS::STATS[key][1]
      size = self.contents.font.size
      self.contents.font.size = 11
      draw_icon(PHI::ICONS::STATS[key][0], x2, y2)
      self.contents.draw_text(x2, y2, 32, 32, key.to_s.upcase)
      self.contents.font.size = size
      value[0].is_a?(Array) ? out_val = value[0][0] : out_val = value[0]
      self.contents.draw_text(x2+26, y2, 40, 32, out_val.to_s)
      self.contents.font.color = color
    end
  end

  def draw_attribute_information(rect_container, rect_outline)
    self.contents.fill_rounded_rect(rect_outline, PHI.color(:GREY, 200))
    self.contents.fill_rounded_rect(rect_container, PHI.color(:GREY, 20))
    xn = 0
    saved_size = self.contents.font.size
    self.contents.font.size = 12
    rect_container.y -= 12
    rect_container.x += 22
    self.contents.draw_text(rect_container, 'Stat Use')
    rect_container.y += 12
    rect_container.x -= 22
    self.contents.font.size = saved_size
    skill.dam_attr.sort_by{|value| PHI::ICONS::STAT_PRIORITY[value[0]] }.each do |value1|
      next if value1.empty?
      key, value = value1[0],value1[1]
      x2 = rect_container.x + ((rect_container.width/3.0).ceil * xn); xn += 1
      if PHI::ICONS::STATS[key].nil? or
          !PHI::ICONS::STATS.keys.include?(key) or
          PHI::ICONS::STATS[key][1].nil?
        p skill.name + ' failed key access: draw_attribute_information ' + key.to_s + ' ' + value.to_s + ' ' + PHI::ICONS::STATS.inspect
        next
      end
      color = self.contents.font.color.clone
      self.contents.font.color = PHI::ICONS::STATS[key][1]
      size = self.contents.font.size
      self.contents.font.size = 11
      draw_icon(PHI::ICONS::STATS[key][0], x2, rect_container.y)
      self.contents.draw_text(x2, rect_container.y, 32, 32, key.to_s.upcase)
      self.contents.font.size = size
      #self.contents.font.color = color
      x2 += 32
      self.contents.draw_text(x2, rect_container.y, rect_container.width, rect_container.height, value.to_s+'%')
      self.contents.font.color = color
    end
  end

  def expanded?
    @expand
  end

  def switch_expand
    !@expand ? expand : retract
  end

  def expand
    @expand = true
    return if skill.nil?
    expanded_refresh
  end

  def retract
    @expand = false
    return if skill.nil?
    refresh(@skill)
  end

end

class Window_SkillIcons < Window_Base
  attr_accessor :active
  attr_reader   :tree

  def initialize(x,y,width,height)
    super(x,y,width,height)
    @data = []
    @index1_old = 0
    @index2_old = 0
    @index3_old = 0
    @old_tree = 0
    @actor_id = -1
    @icons1 = []
    @icons2 = []
    @icons3 = []
    @active = false
    self.opacity = 0
    @help = Skill_Help.new(self.x+32*6+12, self.y+32, 240, 64)
    @help.visible = false
    @last_skill = nil
    @armor = false
  end

  def one_tree?
    return @armor
  end

  def tree
    return 0
    return 2 if one_tree?
    return $game_index.tree
  end

  def index
    return $game_index.index3 if one_tree?
    return $game_index.index1 if $game_index.tree == 0
    return $game_index.index2 if $game_index.tree == 1
    return 0
  end

  def next_tree
    return if animating? or one_tree?
    if $game_index.tree != 0
      $game_index.tree = 0
    else
      $game_index.tree = 1
    end
  end

  def switch_expand
    @help.switch_expand
  end

  def expanded?
    @help.expanded?
  end

  def last
    return if animating?
    if $game_index.tree == 0 or one_tree?
      if one_tree?
        $game_index.index3 += 1
        $game_index.index3 = 0 if $game_index.index3 > @icons3.size - 1
      else
        $game_index.index1 += 1
        $game_index.index1 = 0 if $game_index.index1 > @icons1.size - 1
      end
    else
      $game_index.index2 += 1
      $game_index.index2 = 0 if $game_index.index2 > @icons2.size - 1
    end
  end

  def next
    return if animating?
    if $game_index.tree == 0 or one_tree?
      if one_tree?
        $game_index.index3 -= 1
        $game_index.index3 = @icons3.size - 1 if $game_index.index3 < 0
      else
        $game_index.index1 -= 1
        $game_index.index1 = @icons1.size - 1 if $game_index.index1 < 0
      end
    else
      $game_index.index2 -= 1
      $game_index.index2 = @icons2.size - 1 if $game_index.index2 < 0
    end
  end

  def animating?
    return false if @icons1.nil? or @icons2.nil? or @icons3.nil?
    (@icons1 + @icons2 + @icons3).each {|icon| return true if icon.animating?}
    return false
  end

  def visible=(new_visible)
    @icons1.each { |icon| icon.visible = new_visible } unless @icons1.nil?
    @icons2.each { |icon| icon.visible = new_visible } unless @icons2.nil?
    @icons3.each { |icon| icon.visible = new_visible } unless @icons3.nil?
    @help.visible = new_visible unless @help.nil?
    super
  end

  def x=(new_x)
    (@icons1 + @icons2 + @icons3).each {|icon| icon.x -= self.x - new_x} if !@icons1.nil? && !@icons2.nil? && !@icons3.nil?
    @help.x -= self.x - new_x unless @help.nil?
    super
  end
  def y=(new_y)
    (@icons1 + @icons2 + @icons3).each {|icon| icon.y -= self.y - new_y} if !@icons1.nil? && !@icons2.nil? && !@icons3.nil?
    @help.y -= self.y - new_y unless @help.nil?
    super
  end
  def dispose
    (@icons1 + @icons2 + @icons3).each {|sprite| sprite.dispose} if !@icons1.nil? && !@icons2.nil? && !@icons3.nil?
    @help.dispose unless @help.nil?
    @help = nil
    super
  end

  def update
    super
    (@icons1 + @icons2 + @icons3).each {|sprite| sprite.update} if !@icons1.nil? && !@icons2.nil? && !@icons3.nil?
    @help.update unless @help.nil?
    if @index1_old != $game_index.index1
      p 'updating skill icons 1'
      animate_icon_movement(@icons1, $game_index.index1, @index1_old)
      @index1_old = $game_index.index1
    end
    if @index2_old != $game_index.index2
      p 'updating skill icons 2'
      animate_icon_movement(@icons2, $game_index.index2, @index2_old)
      @index2_old = $game_index.index2
    end
    if @index3_old != $game_index.index3
      p 'updating skill icons 3'
      animate_icon_movement(@icons3, $game_index.index3, @index3_old)
      @index3_old = $game_index.index3
    end
    if @old_tree != $game_index.tree
      p 'updating skill icons tree'
      animate_icon_tree_movement
      @old_tree = $game_index.tree
    end
    if skill != @last_skill
      p 'updating skill icon help'
      @help.refresh(skill) unless skill.nil?
      @last_skill = skill
    end
  end

  def animate_icon_movement(icons, index, old_index)
    return if icons.nil?
    icons.each {|icon| icon.visible = false unless self.visible }
    return unless self.visible
    for i in 0...icons.size
      break if i > icons.rotate(index).reverse.size
      icon = icons.rotate(index)[i]
      icon.visible = true
      unless icon.animating?
        old_icon = icons.rotate(old_index)[i]
        if icons.rotate(index).index(old_icon) > 5
          old_icon.visible = false
          old_icon.update
        end
        x_dest = old_icon.x
        y_dest = old_icon.y
        x_zoom = old_icon.zoom_x
        y_zoom = old_icon.zoom_y
        z_dest = old_icon.z
        steps = 10
        icon.animate(x_dest, y_dest, x_zoom, y_zoom, z_dest, steps)
      end
    end
  end

  def animate_icon_tree_movement
    for i in 0...5
      if one_tree?
        icon1 = @icons3.rotate($game_index.index3)[i]
      else
        icon1 = @icons1.rotate($game_index.index1)[i]
      end

      icon2 = @icons2.rotate($game_index.index2)[i]
      x_dest = icon1.x
      y_dest = icon1.y
      x_zoom = icon1.zoom_x
      y_zoom = icon1.zoom_y
      z_dest = icon1.z
      steps = 10
      x_dest2 = icon2.x
      y_dest2 = icon2.y
      x_zoom2 = icon2.zoom_x
      y_zoom2 = icon2.zoom_y
      z_dest2 = icon2.z
      steps2 = 10
      icon1.animate(x_dest2, y_dest2, x_zoom2, y_zoom2, z_dest2, steps2)
      icon2.animate(x_dest, y_dest, x_zoom, y_zoom, z_dest, steps)
    end
  end

  def refresh(tree1, tree2, tree3, armor)
    @armor = armor
    @tree1, @tree2, @tree3 = tree1, tree2, tree3
    @index1_old, @index2_old, @index3_old = $game_index.index1, $game_index.index2, $game_index.index3
    prepare_icons

    draw_primary_weapon_tree
    draw_secondary_weapon_tree

  end

  def prepare_icons
    @icons1.each { |icon| icon.dispose }
    @icons1.clear
    @tree1.each do |skill|
      icon = Skill_Icon.new
      icon.draw_icon(skill.icon_index)
      @icons1.push icon
    end
    @icons2.each { |icon| icon.dispose}
    @icons2.clear
    return if @tree2.nil?
    @tree2.each do |skill|
      icon = Skill_Icon.new
      icon.draw_icon(skill.icon_index)
      @icons2.push icon
    end
    @icons3.each { |icon| icon.dispose}
    @icons3.clear
    return if @tree3.nil?
    @tree3.each do |skill|
      icon = Skill_Icon.new
      icon.draw_icon(skill.icon_index)
      @icons3.push icon
    end
    draw_primary_weapon_tree
    draw_secondary_weapon_tree
  end

  def display_armor_tree
    #Todo: Prepare armor tree.
  end

  def skill
    if $game_index.tree == 0 or one_tree?
      if one_tree?
        return nil if @tree3.nil?
        @tree3[$game_index.index3]
      else
        return nil if @tree1.nil?
        @tree1[$game_index.index1]
      end
    else
      return nil if @tree2.nil?
      @tree2[$game_index.index2]
    end
  end


  def draw_primary_weapon_tree
    if one_tree?
      return if @icons3.empty?
      for i in 0...@icons3.size
        icon = @icons3.rotate($game_index.index3)[i]
        place_primary_icon(i, icon)
      end
    else
      if $game_index.tree == 0
        return if @icons1.empty?
        for i in 0...@icons1.size
          icon = @icons1.rotate($game_index.index1)[i]
          place_primary_icon(i, icon)
        end
      else
        return if @icons2.empty?
        for i in 0...@icons2.size
          icon = @icons2.rotate($game_index.index2)[i]
          place_primary_icon(i, icon)
        end
      end

    end
  end

  def place_primary_icon(i, icon)
    if i == 0
      icon.zoom_x = 1.5
      icon.zoom_y = 1.5
    else
      icon.zoom_x = 1
      icon.zoom_y = 1
    end
    icon.x = self.x
    icon.y = self.y - 20
    if i < 5
      icon.x += i * 32
      icon.visible = self.visible
      icon.z = self.z + 200 - (i*2)# + 200
    else
      icon.visible = false
    end
  end

  def draw_secondary_weapon_tree
    return if one_tree?
    if $game_index.tree == 0
      return if @icons2.empty?
      for i in 0...@icons2.size
        icon = @icons2.rotate($game_index.index2)[i]#.reverse[i]
        # Is active tree
        place_secondary_icon(i, icon)
      end
    else
      return if @icons1.empty?
      for i in 0...@icons1.size
        icon = @icons1.rotate($game_index.index1)[i]#.reverse[i]
        # Is active tree
        place_secondary_icon(i, icon)
      end
    end

  end

  def place_secondary_icon(i, icon)
    icon.zoom_x = 1
    icon.zoom_y = 1
    icon.x = self.x + 16
    icon.y = self.y - 45
    if i < 5
      icon.x += i * 32
      icon.visible = self.visible
      icon.z = self.z + 100 - i + 1# + 200
    else
      icon.visible = false
    end
  end

end