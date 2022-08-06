class Game_Macros
  
  def initialize
    @party = {}
    @default_macros = PHI::Macro_Data::DEFAULT_MACROS
    set_up_party
  end
  
  def set_up_party
    for member in $game_party.members
      @party[member.id] = []
    end
  end
  
  def populate_macros
    
  end
  
end