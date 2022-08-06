=begin
module PHI
  module AIRSHIP_DATA
    
    REGION_DATA = {
#~       "name" => [id, 
#~                  level,
#~                  icon, 
#~                  [bosses], 
#~                  [requirements], 
#~                  [description], 
#~                  [area_changes],],
      0      => ["Protected Coast",
                 0, 
                 "1-10",
                 1, 
                 [["Ursa-Terpis", "10", "Eats fish, breaks walls, and bullies monsters."]], 
                 [], 
                 ["Don't feel too safe here in the coast, ", "Its protected from the lake by cliffs.",
                 "However, the Ursa-Terpis is here.",], 
                 [],
                 335,
                 ],
      1      => ["Lakefront",
                 1, 
                 "10-20",
                 10, 
                 [["Stagnum-Anguis", "20", "Eats fish rapidly."]], 
                 [], 
                 ["This lake is quite hazardous."], 
                 [],
                 335,
                 ],
      
    }
    
#~       ["Lakefront",1],
#~       ["Oceanside",2],
#~       ["Marsh Inlet",3],
#~       ["Mountainside Woods",4],
#~       ["Natural Cave",5],
#~       ["Volcanic Chasm",6],
#~       ["Chaos Realm",7],
#~       ["Dimensional Pocket",8],
#~       ["Sapphire Ruins",9],
#~       ["Abandoned Skyship",10],]
#~     
  end
  
  class REGION_AREA
    def initialize
      @name = ""
      @id = 0
      @level = ""
      @icon = 0
      @bosses = []
      @requirements = []
      @description = []
      @area_changes = []
      @map_id = 0
    end
    attr_accessor :name
    attr_accessor :id
    attr_accessor :level
    attr_accessor :icon
    attr_accessor :bosses
    attr_accessor :requirements
    attr_accessor :description
    attr_accessor :area_changes
    attr_accessor :map_id
  end
  
  def self.region_list
    @results = []
    data = PHI::AIRSHIP_DATA::REGION_DATA
    for i in 0...data.size
      region = PHI::REGION_AREA.new
      region.name = data[i][0]
      region.id = data[i][1]
      region.level = data[i][2]
      region.icon = data[i][3]
      region.bosses = data[i][4]
      region.requirements = data[i][5]
      region.description = data[i][6]
      region.area_changes = data[i][7]
      region.map_id = data[i][8]
      @results.push region
    end
    region_exit = PHI::REGION_AREA.new
    region_exit.name = "Exit"
    region_exit.id = @results.size
    region_exit.level = 0
    region_exit.icon = 1
    region_exit.bosses = []
    region_exit.requirements = []
    region_exit.description = []
    region_exit.area_changes = []
    region_exit.map_id = 0
    @results.push region_exit
    return @results
  end
  
end
=end