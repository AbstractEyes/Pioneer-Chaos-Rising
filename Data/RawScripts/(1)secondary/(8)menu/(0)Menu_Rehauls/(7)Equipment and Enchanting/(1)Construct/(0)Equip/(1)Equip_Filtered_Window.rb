class Equip_Filtered_Window < Window_Selectable

  def initialize(x,y,w,h)
    super(x,y,w,h)
  end

  def locked_equipment

  end

  def refresh(member_id, slot)
    @data = $game_party.equipment.get_equippable(member_id, slot)
  end

end