class Formation_Bench < Window_Selectable

  def initialize(x, y, width, height)
    super(x,y,width,height)
    @wlh2 = 32
    self.active = false
    self.visible = true
    @column_max = 5
    @item_max = 5
    refresh
  end

  def refresh
    create_contents
    draw_party
  end

  def update
    super
  end

  def draw_party
    for i in 0...5
      next if $game_party.sorted_members[i] < 0
      player = $game_party.players[$game_party.sorted_members[i]]
      next if player.nil?
      rect = item_rect(i)
      draw_actor_graphic(player, rect.x+20, rect.y+64)
    end
  end

  def draw_actor_graphic(actor, x, y)
    draw_locked_character(actor.character_name, actor.character_index, x, y)
  end

  def draw_locked_character(character_name, character_index, x, y)
    return if character_name == nil
    bitmap = Cache.character(character_name)
    sign = character_name[/^[\!\$]./]
    if sign != nil and sign.include?('$')
      cw = bitmap.width / 3
      ch = bitmap.height / 4
    else
      cw = bitmap.width / 12
      ch = bitmap.height / 8
    end
    n = character_index
    src_rect = Rect.new((n%4*3+1)*cw+4, (n/4*4)*ch+4, cw-6, ch-6)
    self.contents.blt(x - cw / 2, y - ch, bitmap, src_rect)
  end
end