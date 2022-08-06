module PHI
  module GATHER
    # [[id, odds],[id, odds]],

    class Gather_Chunk
      attr_accessor :reward_items
      attr_accessor :required_items
      attr_accessor :max_count

      def initialize(required_items, max_count, reward_items)
        self.required_items = required_items
        self.reward_items = reward_items
        self.max_count = max_count
      end

      def random_item
        rand_number = rand(100) + 1
        for item in self.reward_items
          return item[0] if item[1].include?(rand_number)
        end
        return self.reward_items[0][0]
      end

    end

    RESOURCE_CHUNKS = {
        # Ores
        #    => Gather_Chunk.new([required_items], max_amount, [[item_number, begining_rng_range...end_rng_range], ...])
        1    => Gather_Chunk.new([9,10,11,12], 5, [[100, 1..50],[101, 51..75],[102, 76..100]])
        #2    => [[102, 50],[103, 35],[104, 15]],
        #3    => [[104, 50],[105, 35],[106, 15]],
        #4    => [[105, 50],[106, 35],[107, 15]],
        #5    => [[106, 50],[107, 35],[108, 15]],
        #6    => [[107, 50],[108, 35],[109, 15]]
    }
  end
end

class Hotspot_Manager < Hash
  RATIO = 100

  def set_node(map_id, event_id, tree_index)
    self[map_id] = {} if self[map_id].nil?
    self[map_id][event_id] = get_resource_count(tree_index) unless node_exists?(map_id, event_id)
  end

  def node_complete?(map_id, event_id)
    return (self[map_id][event_id].nil? or self[map_id][event_id] <= 0)
  end


  def node_exists?(map_id, event_id)
    return false unless self.keys.include?(map_id)
    return self[map_id].is_a?(Hash) && self[map_id].keys.include?(event_id)
  end

  def get_gather_item_number(map_id, event_id)
    PHI::GATHER::RESOURCE_CHUNKS[map_id][event_id]
  end

  def reduce_gather_spot_count(map_id, event_id)
    self[map_id][event_id] -= 1
  end

  def get_resource_count(tree_index)
    return (rand(PHI::GATHER::RESOURCE_CHUNKS[tree_index].max_count) + 1)
  end

  def gather_tree(tree_index)
    return PHI::GATHER::RESOURCE_CHUNKS[tree_index]
  end

  def dump_all
    for map_id in self.keys
      for event_id in self[map_id].keys
        $game_self_switches.delete([map_id, event_id, "A"])
      end
    end
    self.clear
  end

  def dump_map(map_id)
    self.remove(map_id)
  end

end

class Game_Event < Game_Character

  def is_gather_spot?
    return gather_spot_tree != 0
  end

  def gather_spot_tree
    unless @list.nil?
      for i in 0...@list.size - 1
        next if @list[i].code != 108
        if @list[i].parameters[0].include?('gather_index')
          return clip_gather(@list[i].parameters[0]).to_i
        end
      end
    end
    return 0
  end

  def clip_gather(input)
    p 'clip gather ' + input.delete('<>gather_index ')
    return input.delete('<>gather_index ')
  end

end

class Game_Interpreter

  def reset_gather_points
    p ' dumping hotspots '
    p $hotspot_container.inspect
    $hotspot_container.dump_all
    p $hotspot_container.inspect
  end

  def minus_gather
    $hotspot_container.reduce_gather_spot_count($game_map.map_id, @event_id)
  end

  def hotspot_done?
    return $hotspot_container.node_complete?($game_map.map_id, @event_id)
  end

  def gather_node_exists?
    return $hotspot_container.node_exists?($game_map.map_id, @event_id)
  end

  def create_gather_node
    return $hotspot_container.set_node($game_map.map_id, @event_id, get_gather_tree_index)
  end

  def get_gather_tree_index
    get_event.gather_spot_tree
  end

  def get_gather_item_number
    return $hotspot_container.gather_tree(get_gather_tree_index).random_item
  end

  def spawn_resource
    p 'Create item'
    if !gather_node_exists?
      create_gather_node
      $game_self_switches[[@map_id, @event_id, "A"]] = false
    elsif hotspot_done?
      $game_self_switches[[@map_id, @event_id, "A"]] = true
    end
    $game_map.create_item(get_event.x, get_event.y, get_gather_item_number)
    $game_map.ev_handler.newest_event.move_random
    $game_map.ev_handler.newest_event.update
    $scene.spriteset.minimap_refresh if $scene.is_a?(Scene_Map)
    #while $game_map.ev_handler.newest_event.moving?
    #  Graphics.wait(1)
    #  $game_map.ev_handler.newest_event.update
    #  $scene.spriteset.update
    #end
    minus_gather
  end

  def display_mining_failed
    p 'No pickaxes'
    $scene.display_text('No pickaxes.')
  end

end