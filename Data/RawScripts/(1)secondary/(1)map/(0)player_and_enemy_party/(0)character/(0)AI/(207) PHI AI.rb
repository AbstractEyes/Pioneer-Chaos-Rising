class Priority_Queue
  
  def initialize
    @items = []
  end
  
  def clear_queue
    @items.clear
  end
  
  def empty?
    return @items.empty?
  end
  
  def push(item)
    @items.push(item)
    @items.sort! { |item1,item2| item1.priority <=> item2.priority }
    return true
  end
  
  def next
    return @items.shift
  end
  
end

class Game_Player < Game_Character
  attr_accessor :auto_actions
  
  alias initialize_old_bacon initialize
  def initialize
    initialize_old_bacon
    @unit_id = 0                      # player's unit id
    @unit_ai = 0                      # player's unit AI
    @ai_mode = 0                      # player's unique ai configuration
    @actions = Priority_Queue.new     # player's command chain
    @auto_actions = false             # players auto action flag
  end
  
  def update_auto_actions
    #@action_wait = 0 if @action_wait.nil?
    #return if @action_wait > 0 or any_action?
    #seek if @auto_actions
  end
  
  def create_action(action_key,params,priority=0)
    return Map_Action.new(action_key,params,priority)
  end
  
  # Find object based on parameters.
#  def seek
#    return if @in_line
#    case @ai_mode
#    when 0 # Gatherer
#      seek_gatherer
#    when 1 # Hunter
#      seek_hunter
#    when 2 # Defender
#      seek_defender
#    end
#  end
  
#~   EVENT_IDENTS = { 
#~     'PLACEHOLDER'   =>  ['move','travel','climb','jump','swim'],
#~     'OBSTACLE'      =>  ['boulder', 'vines', 'tree', ],
#~     'BREAKABLE'     =>  ['wall','boulder'],
#~     'RESOURCE'      =>  ['ore', 'stone', 'herb', 'shroom', 'fish',],
#~     'MONSTER'       =>  ['normal','big','fast','armored'],
#~     'BOSS'          =>  ['ursaterpis',],
#~   }

  def seek_gatherer
    #@seek_path = [] if @seek_path.nil?
    #return unless @sight
    #return if !@active_action.nil?
    ## Seeks events and makes decisions based on the event.
    #if !@sight_handler.events.empty?
    #  @sight_handler.events.each { |key, array|
    #    event = array[1]
    #    tags = event.tags
    #    next if tags.nil?
    #    type, variation = tags[0].downcase, tags[1]
    #    case type
    #    when "boss"       # Needs to evade immediately.
    #      p "Boss spotted by #{$game_actors[self.actor_id].name}"
    #      action_evade(event)
    #      return
    #    when "monster"    # Needs to evade.
    #      p "MONSTER!!! spotted by #{$game_actors[self.actor_id].name}"
    #      action_evade(event)
    #      return
    #    when "obstacle"   # Needs to clear obstacle.
    #      p "Obstacle."
    #
    #    when "resource"   # Needs to gather.
    #      p "#{$game_actors[self.actor_id].name} added Resource action"
    #      action_gather(event)
    #      return
    #    when "breakable"  # Needs to break.
    #      p "Breakable."
    #    end
    #  }
    #end
    # Seeking.
    #if no_action
    #  p "#{$game_actors[self.actor_id].name} moving randomly."
    #  action_moverandom
    #end
  end
  
  def seek_hunter
    
  end
  
  def seek_defender
    
  end
  
  def join_line
    
  end
  
  def action_evade(enemy)
#~     @actions.push(create_action(:evade_battle, [enemy,[enemy.x,enemy.y]]))
  end
  
  def action_destroy_obstacle
    
  end
  
  def action_gather(event)
    #@actions.push(create_action(:moveto, [event, [event.x,event.y]]))
    #@actions.push(create_action(:gather, [event, [event.x,event.y]]))
  end
  
  def destroy_breakable
    
  end
  
end