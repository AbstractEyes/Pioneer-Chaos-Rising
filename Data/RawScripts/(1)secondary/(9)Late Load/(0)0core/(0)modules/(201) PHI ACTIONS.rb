module PHI
  
  
  SIMPLE_ACTIONS = {
    :move_direction =>  [0],
    :moveto         =>  [0,[0,0]],
    :move_random    =>  [0],
    :destroy        =>  [0,[0,0]],
    :create         =>  [0,[0,0]],
    :evade_battle   =>  [0,[0,0]],
    :call           =>  [0,[0,0]],
    :use_item       =>  [[0,[0,0]],[0,[0,0]]],
    :gather         =>  [0,[0,0]],
    :battle_command =>  [],
  }
=begin
  GATHERER_MACROS = {
    :seek             =>  [0,:move_random, :spot],
    :gather           =>  [1,:moveto, :gather],
    :destroy_blockage =>  [1,:moveto, :destroy],
    :build_path       =>  [1,:moveto, :create],
    :avoid            =>  [2,:evade_battle, :spot],
    :call_assistance  =>  [2,:call, :moveto],
  }
  
  HUNTER_MACROS = {
  
  }
  
  DEFENDER_MACROS = {
  
  }
  
  def self.basic(key)
    return SIMPLE_ACTIONS[key].clone
  end
  
  def self.macro(type, key)
    case type
    when 0
      return GATHERER_MACROS[key].clone
    when 1
      return HUNTER_MACROS[key].clone
    when 2
      return DEFENDER_MACROS[key].clone
    end
  end
=end
end

class Map_Params
  attr_accessor :event_id
  attr_accessor :x
  attr_accessor :y
  attr_accessor :tx
  attr_accessor :ty
  attr_accessor :actor_id
  attr_accessor :battle_action
  attr_accessor :item_id
  attr_accessor :caller
  attr_accessor :direction
  attr_accessor :target
  
  def initialize(option,params)
    @option = option
    @params = params
    @direction = 0
    @event_id = 0
    @x = 0
    @y = 0
    @tx = 0
    @ty = 0
    @actor_id = 0
    @item_id = 0
    @target = nil
    @battle_action = nil
    prepare_params
  end
  
  def type
    return @option
  end
  
  def prepare_params
    case @option
    when :move_direction
      @direction = @params
    when :moveto
      @target, @x, @y = @params[0],@params[1][0],@params[1][1]
    when :move_random
      @direction = @params
    when :destroy
      @event_id, @x, @y = @params[0],@params[1][0],@params[1][1]
    when :create
      @event_id, @x, @y = @params[0],@params[1][0],@params[1][1]
    when :evade_battle
      @target, @x, @y = @params[0],@params[1][0],@params[1][1]
    when :call
      @actor_id, @x, @y = @params[0],@params[1][0],@params[1][1]
    when :use_item
      @item_id, @tx, @ty = @params[0][0],@params[0][1][0],@params[0][1][1]
      @actor_id, @x, @y = @params[1][0], @params[1][1][0],@params[1][1][1]
    when :gather
      @target, @x, @y = @params[0],@params[1][0],@params[1][1]
    when :battle_command
      @battle_action = @params[0]
      @target = @params[1]
    end
  end
end


class Map_Action
  attr_accessor :finished
  attr_accessor :started
  attr_accessor :option
  attr_accessor :params
  attr_accessor :priority
  
  def initialize(option,params,priority=0,wait_count=0,startup_count=0)
    @finished = false
    @started = false
    @option = option
    @params = Map_Params.new(option,params)
    @priority = priority
    @startup = startup_count
    @wait = wait_count
  end

  def start
    @started = true
  end
  
  def done?
    return @finished
  end
  
  def not_running?
    return !@started
  end
  
end