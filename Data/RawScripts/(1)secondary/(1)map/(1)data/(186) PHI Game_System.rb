class Game_System
  attr_accessor :scroll_active
  attr_accessor :stored_messages
  alias phi_o_initialize initialize
  def initialize
    phi_o_initialize
    @scroll_active = false
    @stored_messages = []
  end
end