class Game_Actor < Game_Battler
  attr_accessor :status_update
  alias initialize_addon_parameters initialize
  def initialize(*args, &block)
    initialize_addon_parameters(*args, &block)
    @status_update = ""
  end
  
  def set_message(message)
    @status_update = message
  end
  
end