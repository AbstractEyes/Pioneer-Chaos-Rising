class Window_Party < Window_Selectable
  attr_accessor :locked

  def initialize(x,y,width,height)
    super(x+72,y,width,height)
    @column_max = 5
    @wlh2 = 76
    @locked = -1
    self.index = 0
    self.opacity = 0
    prepare_child
    refresh
  end

  def prepare_child
    @child = Window_Base.new(self.x-72,self.y-16,self.width+80,self.height+32)
    @child.z = self.z - 1
    @child.create_contents
    @child.contents.fill_rect(16,4,  @child.width-16,92, PHI.color(:RED, 120))
    @child.contents.draw_text(0,0,  @child.width,WLH, "Active")
    @child.contents.fill_rect(16,100, @child.width-16,144, PHI.color(:CYAN, 20))
    @child.contents.draw_text(0,96, @child.width,WLH, "Reserve")
  end

  def dispose
    @child.dispose
    super
  end

  def update
    @child.update
    super
  end

  def member
    return nil if $game_party.all_members[@locked].nil?
    return $game_party.all_members[@locked]
  end

  def get_member(index)
    return nil if $game_party.all_members[index].nil?
    return $game_party.all_members[index]
  end

  def set
    last_xy = [$game_player.x, $game_player.y]
    $game_party.set_sorted_member(self.index, member.id)
    #$game_party.set_player(member.id)
    $game_party.active_snap_line(last_xy[0],last_xy[1])
  end

  def refresh
    @item_max = 15
    create_contents
    draw_party
    draw_locked
  end

  def locked?
    return @locked > -1
  end

  def lock
    @locked = self.index
  end

  def unlock
    @locked = -1
  end


  def draw_party
    for i in 0...@item_max
      next if i > $game_party.all_members.size
      next if $game_party.all_members[i].nil?
      next if $game_party.all_members[i] == -1
      next if get_member(i).nil?
      next if i == @locked
      rect = item_rect(i)
      draw_actor_face(get_member(i), rect.x, rect.y, 76)
    end
  end

  def draw_locked
    if @locked >= 0
      return if $game_party.all_members[@locked] == -1
      return if member.nil?
      rect = item_rect(self.index)
      rect.x += 8
      rect.y += 8
      draw_actor_face(member, rect.x, rect.y, 64)
    end
  end


end