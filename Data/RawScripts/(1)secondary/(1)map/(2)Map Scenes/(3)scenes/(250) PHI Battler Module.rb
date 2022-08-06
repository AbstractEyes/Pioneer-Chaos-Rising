module PHI
    
  class Battle_Action
    attr_accessor :type
    attr_accessor :name
    attr_accessor :startup
    attr_accessor :cooldown
    def initialize(itype, iname, istartup, icooldown)
      self.type = itype
      self.name = iname
      self.startup = istartup
      self.cooldown = icooldown
    end
  end
  
  module BATTLE
    BASIC = :BASIC
    SKILL = :SKILL
    MULTI = :MULTI
    TIERED = :TIERED
    ATTACK = PHI::Battle_Action.new(BASIC, :ATTACK, 0, 30)
    DEFEND = PHI::Battle_Action.new(BASIC, :DEFEND, 0, 0)
    
  end

end