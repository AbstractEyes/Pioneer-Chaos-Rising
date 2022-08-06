# ---------------------------------------------------------------------------- #
# V_Maps Class            #
# Virtual maps made easy. #
# * By Funplayer          #
# ----------------------- #
#
# Description:
#   This is the class that handles all the virtual maps in the same
#   fashion the $game_map itself is handled.  None of them have active
#   interpreters.  The main active interpreter in $game_map handles all
#   of the interpreter updates and changes.
# 
# Commands:
#   
#   create(map_id)
#     initializes a map as virtual, it works if you're inside of it.
#   destroy(map_id)
#     destroys an existing virtual map, no exceptions raise if doesn't exist.
#   halt(map_id)
#     forces a map to not update, best to use this when entering a map, or
#     to just never use it.  its automatic.
#   
# Read the comments on the methods if you want to know what they do.
# ---------------------------------------------------------------------------- #
class V_Maps
  attr_accessor :data
  
  def initialize
    @data = {}
  end
  # Returns the map hash, can also be called with .data for 
  # external modification.
  def _all
    return @data
  end
  def maps
    return @data
  end
  # Returns one map based on id.
  def map(map_id)
    return @data[map_id]
  end
  # Does a map exist?
  def exists?(map_id)
    return @data.has_key?(map_id)
  end
  # Creates a new map inside of the hash.
  def create(map_id = $game_map.map_id)
    @data[map_id] = Game_Map.new(false)
    @data[map_id].setup(map_id)
    #@data[map_id].interpreter = nil
  end
  # Destroys a map from its id.
  def destroy(map_id)
    @data.delete(map_id)
  end
  # Replaces a virtual map's events with the provided events.
  def replace_events(map_id, events)
    return if @data[map_id].nil?
    @data[map_id].events = events
  end
  # Stop the map from updating.
  def halt(map_id)
    @data[map_id].halt = true
  end
  # Resume the maps updating.
  def resume(map_id)
    @data[map_id].halt = false
  end
  # Replaces the interpreter with a brand new one.
  def new_interpreter(map_id)
    @data[map_id].interpreter = Game_Interpreter.new(0, false)
  end
  # Frame updates the vmaps
  def update
    return unless @data.is_a?(Hash)
    for map in @data.values
      map.update unless map.halt
    end
  end
  # Forces a refresh, still doesn't work if halted.
  def refresh_force
    return unless @data.is_a?(Hash)
    for map in @data.values
      map.refresh unless map.halt
    end
  end
  # Refreshes with checks.
  def refresh
    return unless @data.is_a?(Hash)
    for map in @data.values
      map.refresh if map.need_refresh and !map.halt
    end
  end
end