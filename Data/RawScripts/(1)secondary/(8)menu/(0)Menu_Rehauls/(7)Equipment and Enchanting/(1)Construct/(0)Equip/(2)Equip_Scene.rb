class Equip_Icon < Sprite

  def update
    super
    @flash_timer = 0 if @flash_timer.nil?
    @max_flash_timer = 60 if @max_flash_timer.nil?
    if @flash_timer > 0 && self.visible
      @flash_timer -= 1
      self.opacity = 255 - @flash_timer * 4
      if @flash_timer <= 0
        @flash_timer = @max_flash_timer
      end
    end
  end

  def prepare(item)
    rect = Rect.new(0,0,44,44)
    self.bitmap = Bitmap.new(rect.width, rect.height)
    self.bitmap.fill_rounded_rect(rect, PHI.color(:BROWN, 120), 11)
    draw_equipment(rect, item)
    #self.bitmap.draw_text(rect, 'lvl ' + i.to_s)
  end

  def draw_equipment(rect, item, color = :CYAN)
    return if item.nil?
    draw_sized_icon(rect, item.icon_index)
    fcolor = self.bitmap.font.color.clone
    self.bitmap.font.color = PHI.color(color)
    fsize = self.bitmap.font.size
    #rect.x -= 4
    rect.y -= 12
    self.bitmap.font.size = 16
    if item.level > 99
      self.bitmap.draw_text(rect, item.level.to_s)
    else
      self.bitmap.draw_text(rect, 'lvl ' + item.level.to_s)
    end
    self.bitmap.font.color = fcolor
    self.bitmap.font.size = fsize
    rect.y += 24
    #self.bitmap.draw_text(rect, 'o' * item.max_sockets)
    #self.contents.draw_text(rect.x + 38, rect.y, rect.width, rect.height, item.name)
  end

  def draw_sized_icon(resized_rect, icon_index, enabled = true)
    bitmap_i = Cache.system("Iconset2")
    rect_i = Rect.new(icon_index % 16 * 32, icon_index / 16 * 32, 32, 32)
    self.bitmap.stretch_blt(resized_rect, bitmap_i, rect_i, enabled ? 255 : 100)
  end

end

class Equipment_Management_Scene < Scene_Base

  def initialize(preserved_windows=nil)
    @equip_help = preserved_windows if preserved_windows != nil
  end

  def start
    super
    @background = Sprite.new
    @background.bitmap = Cache.system('/book/background')

    @equip_icon = Equip_Icon.new
    @equip_icon.visible = false
    @equip_icon.x = 0
    @equip_icon.y = 0

    @equip_window = Equip_Inventory.new(0, 0, $screen_width / 2, $screen_height / 2, 0)
    @equip_window.active = true
    @equip_window.index = $game_index.equip_index

    @equip_inventory = Equip_Inventory.new(0,$screen_height/2, $screen_width/2, $screen_height/2, 3)
    @equip_inventory.active = false
    @equip_inventory.visible = true

    @equip_help = Equipment_Help.new($screen_width / 2, 4, $screen_width / 2, $screen_height)
    @equip_help.visible = true
    @equip_help.refresh(@equip_window.ordered_equipment_keys[0])
    @equip_help.opacity = 0

  end

  def terminate
    super
    @background.dispose
    @equip_window.dispose
    @equip_icon.dispose
    @equip_help.dispose
    @equip_inventory.dispose
  end

  def update
    super
    update_windows
    update_activity
    update_equipment_index
    update_inventory_index
  end
  def update_windows
    @equip_icon.update
    @background.update
    @equip_window.update
    @equip_help.update
    @equip_inventory.update
  end
  def update_activity
    if @equip_window.active
      update_equip_inputs
    elsif @equip_inventory.active
      update_inventory_inputs
    end
  end

  def update_equipment_index
    if @last_equip_index != @equip_window.index
      @last_equip_index = @equip_window.index
      $game_index.equip_index = @last_equip_index
      @equip_help.refresh(@equip_window.item)
      @equip_inventory.refresh(@equip_window.item)
    end
  end

  def update_inventory_index
    if @last_inventory_index != @equip_inventory.index
      @last_inventory_index = @equip_inventory.index
      $game_index.equip_inventory_index = @last_inventory_index
      if @equip_inventory.active
        @equip_help.refresh(@equip_window.item, @equip_inventory.item)
      end
    end
  end

  def return_scene
    $scene = Scene_Pioneer_Book.new
  end

  def open_equip_interface
    @equip_window.visible = true
    @equip_help.visible = true
    @equip_window.active = true
  end

  def close_equip_interface
    @last_equip_index = -1
    @equip_window.visible = false
    @equip_help.visible = false
    @equip_window.active = false
    @equip_icon.visible = false
  end

  def update_inventory_inputs
    if Input.trigger?(PadConfig.decision)
      Sound.play_equip
      act = @equip_window.get_actor(@equip_window.item)
      act.change_equip(act.equip_ids.index(@equip_window.item), @equip_inventory.item)
      @equip_inventory.index = 0
      @equip_inventory.active = false
      @equip_window.active = true
      @equip_window.refresh
      @equip_inventory.refresh(@equip_window.item)
      @equip_help.refresh(@equip_window.item)
    elsif Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      @equip_inventory.index = 0
      @equip_inventory.active = false
      @equip_window.active = true
      @equip_help.refresh(@equip_window.item)
    end
  end

  def update_equip_inputs
    if Input.trigger?(PadConfig.decision)
      return Sound.play_buzzer unless @equip_inventory.has_equips?
      Sound.play_equip
      @equip_window.active = false
      @equip_inventory.refresh(@equip_window.item)
      @equip_inventory.active = true
      @equip_help.refresh(@equip_window.item, @equip_inventory.item_at(0))
    elsif Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      return_scene
    elsif Input.trigger?(PadConfig.menu)
      $game_party.equipment.new_random_gear
      $game_party.equipment.sort_by
      @equip_inventory.refresh(@equip_window.item)
    end
  end


end
=begin
class Equipment_Management_Scene < Scene_Base

  def initialize(preserved_windows=nil)
    @equip_help = preserved_windows if preserved_windows != nil
  end

  def start
    super
    @dispose_help = true
    @background = Sprite.new
    @background.bitmap = Cache.system('/book/background')

    @equip_icon = Equip_Icon.new
    @equip_icon.visible = false
    @equip_icon.x = 0
    @equip_icon.y = 0

    @equip_window = Equip_Inventory.new(0, 0, $screen_width / 2, $screen_height)
    @equip_window.active = true

    @equip_help = Equipment_Help.new($screen_width / 2, 4, $screen_width / 2, $screen_height)
    @equip_help.visible = true
    @equip_help.refresh(@equip_window.ordered_equipment_keys[0], 0, -1)
    @equip_help.opacity = 0

    #if @equip_help == nil
    #  @equip_help = []
    #  for i in 0...@equip_window.ordered_equipment_keys.size
    #    @equip_help[i] = Equipment_Help.new($screen_width / 2, 4, $screen_width / 2, $screen_height)
    #    @equip_help[i].opacity = 0
    #    @equip_help[i].refresh(@equip_window.ordered_equipment_keys[i], i, -1)
    #    @equip_help[i].visible = false
    #  end
    #else
    #  @equip_help.each {|help| help.visible = false}
    #  @equip_help[$game_index.equip_index].visible = true
    #end

    #@locked_equip = $game_index.locked_equip
    #@locked_index = $game_index.locked_index
    #@lock_type = $game_index.equip_lock_type
    @last_locked_equip = -1
    @last_locked_menu_selection = 1
    @done_locking = false

  end

  def terminate
    super
    @background.dispose
    @equip_window.dispose
    @equip_icon.dispose
    @equip_help.dispose
    #@equip_help.each {|e| e.dispose} if @dispose_help
  end

  def update
    super
    update_windows
    update_activity
    update_locked_equipment_index
    #update_enchantment_indexes
    update_equipment_index
  end
  def update_windows
    @equip_icon.update
    @background.update
    @equip_window.update
    @equip_help.update
    #@equip_help.each {|e| e.update }
  end
  def update_activity
    update_equip_locked_item
    if @equip_window.active
      update_equip_inputs
    end
    #elsif @equip_options.visible
    #  update_option_inputs
  end

  def update_equipment_index
    if @last_equip_index != @equip_window.index && !locked?
      @last_equip_index = 0 if @last_equip_index.nil?
      #for i in 0...@equip_help.size; @equip_help[i].visible = false; end
      #if @equip_window.visible
        #@equip_help[@equip_window.index].visible = true
      @last_equip_index = @equip_window.index
      $game_index.equip_index = @last_equip_index
      @equip_help.refresh_basic(@equip_window.item, @equip_window.index)
      @last_locked_menu_selection = @equip_window.index
      #end
    end
  end
  def update_locked_equipment_index
    if $game_index.locked_equip != @last_locked_equip
      @last_locked_equip = $game_index.locked_equip
      # update locked equip window
      if locked? and !@done_locking
        @equip_window.refresh_item($game_index.locked_equip_index) #if @locked_equip >= 0
        @done_locking = true
      elsif !locked? and @done_locking
        @equip_window.refresh_item($game_index.locked_equip_index)
        #@equip_window.locked_refresh(@locked_equip)#@equip_window.unlocked_refresh #if @locked_equip >= 0
        @done_locking = false
      end
    end
  end

  def equip
    return nil if $game_index.locked_equip < 0
    return $game_party.equipment[$game_index.locked_equip]
  end

  def update_equip_locked_item
    unless @equip_window.active
      @equip_icon.visible = false
      return
    end
    if $game_index.locked_equip >= 0 && !@equip_icon.visible
      @equip_icon.prepare(self.equip)
      @equip_icon.x = @equip_window.item_rect(@equip_window.index).x + 12
      @equip_icon.y = @equip_window.item_rect(@equip_window.index).y + 12
      @equip_icon.z = @equip_window.z + 1000
      @equip_icon.visible = true
    elsif $game_index.locked_equip >= 0 && @equip_icon.visible
      @equip_icon.x = @equip_window.item_rect(@equip_window.index).x + 12
      @equip_icon.y = @equip_window.item_rect(@equip_window.index).y + 12
    elsif $game_index.locked_equip < 0 && @equip_icon.visible
      @equip_icon.visible = false
    end
  end

  def return_scene
    @dispose_help = true
    $scene = Scene_Map.new
  end

  def open_equip_interface
    @equip_window.visible = true
    @equip_help.visible = true
    @equip_window.active = true
  end

  def close_equip_interface
    @last_equip_index = -1
    @equip_window.visible = false
    @equip_help.visible = false
    @equip_window.active = false
    @equip_icon.visible = false
  end


  def locked?
    return $game_index.lock_type > -1
  end

  def unlock_equip
    $game_index.locked_equip = -1
    $game_index.lock_type = -1
    $game_index.locked_equip_index = -1
  end

  def lock_equip
    $game_index.locked_equip = @equip_window.item
    $game_index.lock_type = @equip_window.lock_type
    $game_index.locked_equip_index = @equip_window.index
  end

  def update_equip_inputs
    if Input.trigger?(PadConfig.decision)
      Sound.play_equip
      #todo: refresh and open equipment display to match index/character
    elsif Input.trigger?(PadConfig.hud)

    elsif Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      return_scene
    elsif Input.trigger?(PadConfig.menu)
      @equip_window.refresh_item($game_party.equipment.new_random_gear, true)
    end
  end


end

=end
#if @equip_window.index == 1
#  # Temper
#  if locked?
#    Sound.play_decision
#    #$scene = Temper_Scene.new(@equip_help)
#  else
#    Sound.play_buzzer
#  end
#elsif @equip_window.index == 2
#  # Enchant
#  if locked?
#    Sound.play_decision
#    close_equip_interface
#    @dispose_help = false
#    $scene = Enchant_Scene.new(@equip_help)
#  else
#    Sound.play_buzzer
#  end
#elsif @equip_window.index == 3
#  # Rename
#elsif @equip_window.index == 4
#  # Disassemble
#elsif @equip_window.index == 5
#  # Sort / Cancel / Placeholder
#  Sound.play_equip
#  if $game_index.locked_equip >= 0
#    unlock_equip
#  end
#  $game_party.equipment.sort_by(true)
#  @equip_window.refresh
#  for i in 0...@equip_window.ordered_equipment_keys.size
#    @equip_help[i].refresh(@equip_window.ordered_equipment_keys[i], i, -1)
#  end
#elsif @equip_window.index > 5
=begin
  def refresh_actor_windows(equip_id)
    m = nil
    $game_party.all_members_safe.each do |mem|
      if mem.equip_ids.include?(equip_id)
        for i in 0...mem.equip_ids.size
          @equip_help[@equip_window.ordered_equipment_keys.index(m.equip_ids[i])].refresh(m.equip_ids[i], 8)
        end
        break
      end
    end
  end

  def lock_equip_sequence
    if @equip_window.item == $game_index.locked_equip
      Sound.play_cursor
      #put down item
      @equip_window.index = $game_index.locked_equip_index
      unlock_equip
      #@equip_window.index = @last_locked_menu_selection
    else
      if $game_index.lock_type == 0 # Locked to an equipped item.
        #locked and selecting another equip item
        if @equip_window.lock_type == 0

          #locked and selecting an inventory slot
        elsif @equip_window.lock_type == 1
          # Swapping from equipment to inventory empty slot, cannot work.
          if @equip_window.item == -1
            Sound.play_buzzer
            return
            # Swapping from equipment to inventory non empty slot.
          else
            if @equip_window.equippable_from?($game_index.locked_equip, @equip_window.item, $game_index.locked_equip_index)
              p 'equipped and swapping for an unequipped'
              #o_item = @equip_window.item
              act = @equip_window.get_actor($game_index.locked_equip)
              act.change_equip(act.equip_ids.index($game_index.locked_equip), @equip_window.item)
              #@equip_help[@equip_window.index].refresh_basic(@equip_window.index)
              @equip_window.refresh_equips
              #@equip_help[@equip_window.index].refresh($game_index.locked_equip, 7)
              #for i in ($game_index.locked_equip_index - $game_index.locked_equip_index%6)...(($game_index.locked_equip_index - $game_index.locked_equip_index % 6))
              #  @equip_help[i].refresh(@equip_window.item_at(i), 7)
              #end
              #@equip_help[@locked_index].refresh(o_item, 7)
              unlock_equip
              @equip_window.refresh
              @equip_help.refresh_basic(@equip_window.item, @equip_window.index)
              Sound.play_decision
              return
            end
          end
        end
      elsif $game_index.lock_type == 1 # Locked to an item in the inventory.
        #locked and selecting another equip item
        if @equip_window.lock_type == 0
          if $game_index.locked_equip > -1 # item from bag equipping to character
            if @equip_window.equippable_to?(@equip_window.item, $game_index.locked_equip)
              p 'item from bag equipping to character'
              o_item = @equip_window.item
              @equip_window.get_actor(@equip_window.item).change_equip(@equip_window.index % 6, $game_index.locked_equip)
              #refresh_actor_windows(@locked_equip)
              @equip_window.refresh_equips
              #@equip_help[@equip_window.index].refresh(@locked_equip, 7)
             # for i in (@equip_window.index - (@equip_window.index%6))...((@equip_window.index - (@equip_window.index % 6)))
             #   @equip_help.refresh(@equip_window.item_at(i), 7)
             # end
              #@equip_help[$game_index.locked_equip_index].refresh(o_item, 7)
              unlock_equip
              @equip_window.refresh
              @equip_help.refresh_basic(@equip_window.item, @equip_window.index)
              Sound.play_decision
              return
            else
              Sound.play_buzzer
              return
            end
          else # Cannot unequip to empty slot, or cannot equip target item.
            Sound.play_buzzer
            return
          end
          #locked and selecting an inventory slot
        elsif @equip_window.lock_type == 1 # Swap whatever in the inventory
          p 'not equipped and swapping for not equipped'
          $game_party.equipment.swap(@equip_window.sorted_index - 1,
                                     $game_party.equipment.sorted.index($game_index.locked_equip))
          #todo: add refresh for the two windows of swapped items.
          unlock_equip
          @equip_window.refresh
          Sound.play_decision
          return
        end
      end
    end
    #Sound.play_buzzer
  end
=end
=begin
  def update_option_inputs
    if Input.trigger?(PadConfig.decision)
      @equip_options.visible = false
      # Cannot LOCK empty slot.
      Sound.play_decision
      lock_equip
      @equip_options.visible = false
      @equip_window.active = true
    elsif Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      @equip_options.visible = false
      @equip_window.active = true
    elsif Input.trigger?(PadConfig.left)    # swap equip
      # Display window only containing swappable equipment
      # If selecting equipment with no character that can equip it,
      #   swap is disabled and plays buzzer
      # else
      #   pick up equipment and display window.
      # end
      lock_equip
    elsif Input.trigger?(PadConfig.right)   # enchant equip
      # Display enchant scene
      # lock equipment
      # open enchant scene
      # be sure to UNLOCK equipment when returning
      lock_equip
    elsif Input.trigger?(PadConfig.up)      # upgrade equip
      # Display upgrade scene
      # lock equipment
      # open upgrade scene
      # be sure to UNLOCK equipment when returning
    elsif Input.trigger?(PadConfig.down)    # rename equip
      # display rename box
    end
  end
=end
=begin
class Equip_Icon < Sprite

  def update
    super
    @flash_timer = 0 if @flash_timer.nil?
    @max_flash_timer = 60 if @max_flash_timer.nil?
    if @flash_timer > 0 && self.visible
      @flash_timer -= 1
      self.opacity = 255 - @flash_timer * 4
      if @flash_timer <= 0
        @flash_timer = @max_flash_timer
      end
    end
  end

  def prepare(item)
    rect = Rect.new(0,0,44,44)
    self.bitmap = Bitmap.new(rect.width, rect.height)
    self.bitmap.fill_rounded_rect(rect, PHI.color(:BROWN, 120), 11)
    draw_equipment(rect, item)
    #self.bitmap.draw_text(rect, 'lvl ' + i.to_s)
  end

  def draw_equipment(rect, item, color = :CYAN)
    return if item.nil?
    draw_sized_icon(rect, item.icon_index)
    fcolor = self.bitmap.font.color.clone
    self.bitmap.font.color = PHI.color(color)
    fsize = self.bitmap.font.size
    #rect.x -= 4
    rect.y -= 12
    self.bitmap.font.size = 16
    if item.level > 99
      self.bitmap.draw_text(rect, item.level.to_s)
    else
      self.bitmap.draw_text(rect, 'lvl ' + item.level.to_s)
    end
    self.bitmap.font.color = fcolor
    self.bitmap.font.size = fsize
    rect.y += 24
    self.bitmap.draw_text(rect, 'o' * item.max_sockets)
    #self.contents.draw_text(rect.x + 38, rect.y, rect.width, rect.height, item.name)
  end

  def draw_sized_icon(resized_rect, icon_index, enabled = true)
    bitmap_i = Cache.system("Iconset2")
    rect_i = Rect.new(icon_index % 16 * 32, icon_index / 16 * 32, 32, 32)
    self.bitmap.stretch_blt(resized_rect, bitmap_i, rect_i, enabled ? 255 : 100)
  end

end

class Equipment_Management_Scene < Scene_Base

  def initialize(preserved_windows=nil)
    @equip_help = preserved_windows if preserved_windows != nil
  end

  def start
    super
    @dispose_help = true
    @background = Sprite.new
    @background.bitmap = Cache.system('/book/background')

    @equip_icon = Equip_Icon.new
    @equip_icon.visible = false
    @equip_icon.x = 0
    @equip_icon.y = 0

    @equip_window = Equip_Inventory.new(0, 0, $screen_width / 2, $screen_height)
    @equip_window.active = true

    if @equip_help == nil
      @equip_help = []
      for i in 0...@equip_window.ordered_equipment_keys.size
        @equip_help[i] = Equipment_Help.new($screen_width / 2, 4, $screen_width / 2, $screen_height)
        @equip_help[i].opacity = 0
        @equip_help[i].refresh(@equip_window.ordered_equipment_keys[i], i, -1)
        @equip_help[i].visible = false
      end
    else
      @equip_help.each {|help| help.visible = false}
      @equip_help[$game_index.equip_index].visible = true
    end

    #@locked_equip = $game_index.locked_equip
    #@locked_index = $game_index.locked_index
    #@lock_type = $game_index.equip_lock_type
    @last_locked_equip = -1
    @last_locked_menu_selection = 1
    @done_locking = false

  end

  def terminate
    super
    @background.dispose
    @equip_window.dispose
    @equip_icon.dispose
    @equip_help.each {|e| e.dispose} if @dispose_help
  end

  def update
    super
    update_windows
    update_activity
    update_locked_equipment_index
    #update_enchantment_indexes
    update_equipment_index
  end
  def update_windows
    @equip_icon.update
    @background.update
    @equip_window.update
    @equip_help.each {|e| e.update }
  end
  def update_activity
    update_equip_locked_item
    if @equip_window.active
      update_equip_inputs
    end
  end

  def update_equipment_index
    if @last_equip_index != @equip_window.index && !locked?
      @last_equip_index = 0 if @last_equip_index.nil?
      for i in 0...@equip_help.size; @equip_help[i].visible = false; end
      if @equip_window.visible
        @equip_help[@equip_window.index].visible = true
        @last_equip_index = @equip_window.index
        $game_index.equip_index = @last_equip_index
        @last_locked_menu_selection = @equip_window.index if @equip_window.index < 5
      end
    end
  end
  def update_locked_equipment_index
    if $game_index.locked_equip != @last_locked_equip
      @last_locked_equip = $game_index.locked_equip
      # update locked equip window
      if locked? and !@done_locking
        @equip_window.refresh_item($game_index.locked_equip_index) #if @locked_equip >= 0
        @done_locking = true
      elsif !locked? and @done_locking
        @equip_window.refresh_item($game_index.locked_equip_index)
        #@equip_window.locked_refresh(@locked_equip)#@equip_window.unlocked_refresh #if @locked_equip >= 0
        @done_locking = false
      end
    end
  end

  def equip
    return nil if $game_index.locked_equip < 0
    return $game_party.equipment[$game_index.locked_equip]
  end

  def update_equip_locked_item
    unless @equip_window.active
      @equip_icon.visible = false
      return
    end
    if $game_index.locked_equip >= 0 && !@equip_icon.visible
      @equip_icon.prepare(self.equip)
      @equip_icon.x = @equip_window.item_rect(@equip_window.index).x + 12
      @equip_icon.y = @equip_window.item_rect(@equip_window.index).y + 12
      @equip_icon.z = @equip_window.z + 1000
      @equip_icon.visible = true
    elsif $game_index.locked_equip >= 0 && @equip_icon.visible
      @equip_icon.x = @equip_window.item_rect(@equip_window.index).x + 12
      @equip_icon.y = @equip_window.item_rect(@equip_window.index).y + 12
    elsif $game_index.locked_equip < 0 && @equip_icon.visible
      @equip_icon.visible = false
    end
  end

  def return_scene
    @dispose_help = true
    $scene = Scene_Map.new
  end

  def open_equip_interface
    @equip_window.visible = true
    @equip_help.each { |e| e.visible = false }
    @equip_help[@equip_window.index].visible = true
    @equip_window.active = true
  end

  def close_equip_interface
    @last_equip_index = -1
    @equip_window.visible = false
    @equip_help.each { |e| e.visible = false }
    @equip_help[@equip_window.index].visible = false
    @equip_window.active = false
    @equip_icon.visible = false
  end


  def locked?
    return $game_index.lock_type > -1
  end

  def unlock_equip
    $game_index.locked_equip = -1
    $game_index.lock_type = -1
    $game_index.locked_equip_index = -1
  end

  def update_equip_inputs
    if Input.trigger?(PadConfig.decision)
      if @equip_window.index == 1
        # Temper
        if locked?
          Sound.play_decision
          #$scene = Temper_Scene.new(@equip_help)
        else
          Sound.play_buzzer
        end
      elsif @equip_window.index == 2
        # Enchant
        if locked?
          Sound.play_decision
          close_equip_interface
          @dispose_help = false
          $scene = Enchant_Scene.new(@equip_help)
        else
          Sound.play_buzzer
        end
      elsif @equip_window.index == 3
        # Rename
      elsif @equip_window.index == 4
        # Disassemble
      elsif @equip_window.index == 5
        # Sort / Cancel / Placeholder
        Sound.play_equip
        if $game_index.locked_equip >= 0
          unlock_equip
        end
        $game_party.equipment.sort_by(true)
        @equip_window.refresh
        for i in 0...@equip_window.ordered_equipment_keys.size
          @equip_help[i].refresh(@equip_window.ordered_equipment_keys[i], i, -1)
        end
      elsif @equip_window.index > 5
        if locked?
          lock_equip_sequence
        else
          # Cannot LOCK empty slot.
          if @equip_window.item == -1
            Sound.play_buzzer
            return
          else
            Sound.play_decision
            $game_index.locked_equip = @equip_window.item
            $game_index.lock_type = @equip_window.lock_type
            $game_index.locked_equip_index = @equip_window.index
          end
        end
      end
    elsif Input.trigger?(PadConfig.cancel)
      Sound.play_cancel
      if locked?
        if @equip_window.index <= 4
          @equip_window.index = $game_index.locked_equip_index
          $game_index.locked_equip_index = -1
        end
        unlock_equip
      else
        return_scene
      end
    elsif Input.trigger?(PadConfig.hud)
      @equip_window.refresh_item($game_party.equipment.new_random_gear, true)
    end
  end

  def refresh_actor_windows(equip_id)
    m = nil
    $game_party.all_members_safe.each do |mem|
      if mem.equip_ids.include?(equip_id)
        for i in 0...mem.equip_ids.size
          @equip_help[@equip_window.ordered_equipment_keys.index(m.equip_ids[i])].refresh(m.equip_ids[i], 8)
        end
        break
      end
    end
  end

  def lock_equip_sequence
    if @equip_window.item == $game_index.locked_equip
      Sound.play_cursor
      @equip_window.index = @last_locked_menu_selection
    else
      if $game_index.lock_type == 0 # Locked to an equipped item.
        #locked and selecting another equip item
        if @equip_window.lock_type == 0

          #locked and selecting an inventory slot
        elsif @equip_window.lock_type == 1
          # Swapping from equipment to inventory empty slot, cannot work.
          if @equip_window.item == -1
            Sound.play_buzzer
            return
            # Swapping from equipment to inventory non empty slot.
          else
            if @equip_window.equippable_from?($game_index.locked_equip, @equip_window.item, $game_index.locked_equip_index)
              p 'equipped and swapping for an unequipped'
              #o_item = @equip_window.item
              act = @equip_window.get_actor($game_index.locked_equip)
              act.change_equip(act.equip_ids.index($game_index.locked_equip), @equip_window.item)
              #@equip_help[@equip_window.index].refresh_basic(@equip_window.index)
              @equip_window.refresh_equips
              @equip_help[@equip_window.index].refresh($game_index.locked_equip, 7)
              for i in ($game_index.locked_equip_index - $game_index.locked_equip_index%6)...(($game_index.locked_equip_index - $game_index.locked_equip_index % 6)+6)
                @equip_help[i].refresh(@equip_window.item_at(i), 7)
              end
              #@equip_help[@locked_index].refresh(o_item, 7)
              unlock_equip
              @equip_window.refresh
              Sound.play_decision
              return
            end
          end
        end
      elsif $game_index.lock_type == 1 # Locked to an item in the inventory.
        #locked and selecting another equip item
        if @equip_window.lock_type == 0
          if $game_index.locked_equip > -1 # item from bag equipping to character
            if @equip_window.equippable_to?(@equip_window.item, $game_index.locked_equip)
              p 'item from bag equipping to character'
              o_item = @equip_window.item
              @equip_window.get_actor(@equip_window.item).change_equip(@equip_window.index % 6, $game_index.locked_equip)
              #refresh_actor_windows(@locked_equip)
              @equip_window.refresh_equips
              #@equip_help[@equip_window.index].refresh(@locked_equip, 7)
              for i in (@equip_window.index - (@equip_window.index%6))...((@equip_window.index - (@equip_window.index % 6))+6)
                @equip_help[i].refresh(@equip_window.item_at(i), 7)
              end
              @equip_help[$game_index.locked_equip_index].refresh(o_item, 7)
              unlock_equip
              @equip_window.refresh
              Sound.play_decision
              return
            else
              Sound.play_buzzer
              return
            end
          else # Cannot unequip to empty slot, or cannot equip target item.
            Sound.play_buzzer
            return
          end
          #locked and selecting an inventory slot
        elsif @equip_window.lock_type == 1 # Swap whatever in the inventory
          p 'not equipped and swapping for not equipped'
          $game_party.equipment.swap(@equip_window.sorted_index - 1,
                                     $game_party.equipment.sorted.index($game_index.locked_equip))
          #todo: add refresh for the two windows of swapped items.
          unlock_equip
          @equip_window.refresh
          Sound.play_decision
          return
        end
      end
    end
    #Sound.play_buzzer
  end

end
=end