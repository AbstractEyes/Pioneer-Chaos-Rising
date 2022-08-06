module PHI
  module SE
    # PHI::SE.menu_se(100,50)
    def self.menu_se(volume,pitch)
      RPG::SE.new("SE_Intro", volume, pitch).play
    end
    
  end
end