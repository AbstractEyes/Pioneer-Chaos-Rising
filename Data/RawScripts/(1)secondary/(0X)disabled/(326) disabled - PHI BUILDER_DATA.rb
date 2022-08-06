module PHI
  module BUILDER_DATA
    
    BASE_LIST = {
      #Key           => ["Name", description_id,],
      0    => ["Ramsey",   0, ],
      1    => ["Garet",    0, ],
      2    => ["Kathy",    0, ],
      3    => ["Barry",    0, ],
      4    => ["Brock",    0, ],
      5    => ["John",     0, ],
      6    => ["Ezra",     0, ],
      7    => ["Claire",   0, ],
      8    => ["Kathy",    0, ],
      9    => ["Adam",     0, ],
     10    => ["Karen",    0, ],
     11    => ["Blane",    0, ],
     12    => ["Brittany", 0, ],
     13    => ["Glenn",    0, ],
     14    => ["Duncan",   0, ],
     15    => ["Larry",    0, ],
    }
  
  end
  
  class BUILDER
    def initialize
      @id = 0
      @name = ""
      @icon_id = 1
      @color = Color.new(0,0,0,255)
      @description_id = 0
      @quotes = []
      @hired = false
      @active = false
    end
    attr_accessor :id
    attr_accessor :name
    attr_accessor :icon_id
    attr_accessor :color
    attr_accessor :description_id
    attr_accessor :hired
    attr_accessor :active

  end
  
end