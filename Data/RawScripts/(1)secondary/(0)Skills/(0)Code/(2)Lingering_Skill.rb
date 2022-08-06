class Lingering_Skill
  attr_accessor :stacks
  attr_accessor :timer
  attr_accessor :steps
  attr_accessor :skill

  def initialize(skill)
    @skill = skill

    @max_timer = skill.timer    #   The amount of frames between each step.
    @timer = 0

    @max_steps = skill.steps  #   The amount of required steps before the state wears off.
    @steps = 0

    @max_stacks = skill.stacks  #   If 1 or greater, can stack multiple buffs/debuffs on battlers.
    @stacks = 0
  end

  def step
    # Seconds per step per turn
    return if done?
    #steps the skill one frame
    @timer += 1
    if timer_to_step?
      @timer = 0
      @steps += 1
    end
  end

  def stack_up
    @stacks += 1 if @stacks < @max_stacks
  end

  def timer_to_step?
    return @timer == @max_timer
  end

  def activate?
    return (@steps % (@max_steps.to_f / @max_timer.to_f).to_i == 0)
  end

  def done?
    return @steps == @max_steps
  end

end