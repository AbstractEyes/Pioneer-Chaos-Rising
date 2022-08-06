################################################################################
# Game_Options #
# ------------ #
# This is a proper set of (0)options for all possible settings that can be toggled
# changed, manipulated, or anything of that sort.
################################################################################

class Game_Options
  attr_accessor :autohide
  
  def initialize
    @autohide = true
  end
  
end