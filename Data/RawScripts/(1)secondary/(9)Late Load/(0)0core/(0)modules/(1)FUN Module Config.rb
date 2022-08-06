module MAP_DATA
  
  # Enabled or disabled virtual maps.
  # MAP_DATA::VIRTUAL_ENABLED
  # Note this doesn't fully disable virtual mode.  It just disables updates.
  VIRTUAL_ENABLED = true
    
  # This is the map_id for the map that contains all your placeholder events.
  # EVERYTHING inside of the event_controller interpreter, is tied to THIS map
  # for use when creating and destroying events from maps.
  PLACEHOLDER_MAP = 1
  
  # If you are experiencing heavy lag enable update lock.
  # Update lock locks all updates for all virtual maps.
  # i don't think this is currently enabled.
  $update_lock = false

end

module EVENT_CONFIG
  # This is the limit of events that can be created in a single map.
  #EVENT_CONFIG::EVENT_CAPACITY
  EVENT_CAPACITY = 150
end

module BOSS_CONFIG

  # The wait counter for the boss before it triggers its behaviors
  # This is in frames.
  # 1 second = 60 frames
  # or seconds * 60 will also fit here
  # Default is 5 seconds.
  BOSS_WAIT_COUNTER = 5 * 60
end

module EVENT_TAGS
  
  # These are used to determine what each event is, if it is
  #   anything at all.
  # @return [Array]
  EVENT_IDENTS = {
    'PLACEHOLDER'   =>  ['move','travel','climb','jump','swim'],
    'OBSTACLE'      =>  ['boulder', 'vines', 'tree', ],
    'BREAKABLE'     =>  ['wall','boulder'],
    'RESOURCE'      =>  ['item', 'ore', 'stone', 'herb', 'shroom', 'fish',],
    'MONSTER'       =>  ['normal','big','fast','armored'],
    'BOSS'          =>  ['ursaterpis',],
  }


  EVENT_IDENT_COLORS = {
    :item       => PHI::COLORS[:WHITE],
    :none       => PHI::COLORS[:WHITE],
    :move       => PHI::COLORS[:INV],
    :travel     => PHI::COLORS[:WHITE],
    :climb      => PHI::COLORS[:RED],
    :boulder    => PHI::COLORS[:GREY],
    :vines      => PHI::COLORS[:GREEN], 
    :tree       => PHI::COLORS[:GREEN], 
    :wall       => PHI::COLORS[:BLUE],
    :ore        => PHI::COLORS[:GREEN],
    :stone      => PHI::COLORS[:GREEN],
    :herb       => PHI::COLORS[:GREEN],
    :shroom     => PHI::COLORS[:GREEN],
    :fish       => PHI::COLORS[:GREEN],
    :normal     => PHI::COLORS[:DRKRED],
    :big        => PHI::COLORS[:DRKRED],
    :fast       => PHI::COLORS[:DRKRED],
    :armored    => PHI::COLORS[:DRKRED],
    :ursaterpis => PHI::COLORS[:DRKRED],
    :placeholder=> PHI::COLORS[:WHITE],
    :obstacle   => PHI::COLORS[:GREY],
    :breakable  => PHI::COLORS[:BLUE],
    :resource   => PHI::COLORS[:GREEN],
    :monster    => PHI::COLORS[:DRKRED],
    :boss       => PHI::COLORS[:DRKRED],
    :player     => PHI::COLORS[:CYAN],
  }

end