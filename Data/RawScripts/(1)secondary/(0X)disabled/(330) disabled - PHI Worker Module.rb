module PHI
  module WORKER_SCRIPT
    
    MINER_COLOR = "Color.new(155,255,155,255)"
    FISHER_COLOR = ""
    FARMER_COLOR = ""
    HUNTER_COLOR = ""
    
    Worker_names = { 
      #WORKER_ID => [ [ "Name", Worker_Type, Level_Req ], ]
     0  => ["Bartle",    'miner',  0  ],
     1  => ["Fergus",    'miner',  10 ], 
     2  => ["Jonny",     'miner',  20 ],
     3  => ["Linus",     'miner',  30 ], 
     4  => ["Salty",     'fisher', 0  ],
     5  => ["Ahob",      'fisher', 10 ],
     6  => ["Skipper",   'fisher', 20 ],
     7  => ["Blackbeard",'fisher', 30 ],
     8  => ["Ole Pete",  'farmer', 0  ],
     9  => ["John",      'farmer', 10 ],
     10 => ["Mac",       'farmer', 20 ],
     11 => ["Luna",      'farmer', 30 ],
     12 => ["Drake",     'hunter', 0  ],
     13 => ["Logan",     'hunter', 10 ],
     14 => ["Redding",   'hunter', 20 ],
     15 => ["Orragon",   'hunter', 30 ],

    }
    
    Worker_descriptions = { # 36 characters at most per line
      0 => [["Bartle was a very good miner, until"],
            ["the day he forgot his pickaxe."],
            [""],
            ["Then he was only a drinker."], ],
                          
      1 => [["Fergus makes sure to always be     "],
            ["prepared.  Even if he is just      "],
            ["sleeping, eating, or washing.      "],
            ["                                   "], ],
                          
      2 => [["If Jonny isn't busy mining ores, he"],
            ["is busy trying to figure out how to"],
            ["mine ores better.                  "],
            ["                                   "], ],
                          
      3 => [["Linus is the best weaponsmith in   "],
            ["the land.                          "],
            ["He accepts no less than perfection,"],
            ["so he likes to mine his own ore."], ],
                          
      4 => [["Salty finds the little things in   "],
            ["life to enjoy.  Like the sea, salt,"],
            ["and even more interesting things.  "],
            ["Very salty.                        "], ],
                          
      5 => [["Ahob used to have two thumbs,      "],
            ["until a large mouthed bass ate one."],
            ["Now he travels the 7 great lakes   "],
            ["searching for bass revenge.        "], ],
                          
      6 => [["The fisherman skipper, handles most"],
            ["of the boating and sailing without "],
            ["hassle.                            "],
            ["                                   "], ],
                          
      7 => [["The great pirate Blackbeard can do "],
            ["a whole lot of things, other than  "],
            ["plundering and pillaging.          "],
            ["Right now he happens to fish.      "], ],
                          
      8 => [["Farmer Pete handles the farm like  "],
            ["no other.  He likes to poke around "],
            ["and do things to help out the town."],
            ["                                   "], ],
                          
      9 => [["If there ever was a farmers farmer,"],
            ["John would be your choice to farm. "],
            ["There are none that farm better.   "],
            ["                                   "], ],
                          
     10 => [["Farmer Mac does well when it comes "],
            ["to farming.  He can't find his     "],
            ["pants sometimes though.            "],
            ["                                   "], ],
                          
     11 => [["Luna farms better at night, than   "],
            ["during the day.  The farm only runs"],
            ["at night when Luna is farming.     "],
            ["                                   "], ],
                          
     12 => [["Drake became a hunter because her  "],
            ["father went missing on a hunting   "],
            ["trip.  She looks for him every time"],
            ["she goes hunting.                  "], ],
                          
     13 => [["If there ever was a more ferocious "],
            ["hunter than Logan, it wasn't this  "],
            ["generation of people.              "],
            ["                                   "], ],
                          
     14 => [["The other hunters are afraid of him"],
            ["because of his immense size and    "],
            ["bad body odor.  He kills well      "],
            ["nonetheless though.                "], ],
                          
     15 => [["Orragon finds trails nobody else   "],
            ["can find, eats food nobody else    "],
            ["will eat, and breathes water.      "],
            ["Okay maybe not breathes water.     "], ],

    
    }
    
    Worker_areas = {
    
#~  i => ["name", 
#~  0     type, 
#~  1     cycles, 
#~  2     lvl_req, 
#~  3     uni_lv_req, 
#~  4     exp_rew, 
#~  5     cost,
#~  6     [[item_id,item_id,item_id]],]
#~  1 mining, 2 fishing, 3 farming, 4 hunting 
    0  => [nil, nil, nil, nil, nil, nil, nil, [[nil],[nil]], ],#[level,odds,item]
    1  => ["Shallow Cave",          1, 3, 0, 0, 50,   10, [
            [1,3,100],[2,3,101],[3,3,102],[4,3,103]], ],   
    2  => ["Speulking Cavern",      1, 4, 0, 4, 100,   50, [
            [3,10,102],[4,20,103],[5,30,104],[6,40,105]], ],
    3  => ["Volcanic Mountain",     1, 5, 0, 6, 250, 100, [
            [5,3,104],[6,3,105],[7,3,106],[8,3,107]], ],
    4  => ["Chaotic Aftermath",     1, 6, 0, 8, 500, 500, [
            [5,3,105],[6,3,106],[7,3,107],[8,3,108],[8,3,109]], ],
    5  => ["Safe Coastline",        2, 3, 0, 0, 50,   10, [
            [1,3,77],[2,3,78],[3,3,79],[4,3,80]], ],   
    6  => ["Shallow Cove",          2, 4, 1, 2, 100,   50, [
            [3,10,79],[4,20,80],[5,30,81],[6,40,82]], ],
    7  => ["Rocky Waters",          2, 5, 2, 4, 250, 100, [
            [5,3,81],[6,3,82],[7,3,83],[8,3,84]], ],
    8  => ["Dangerous Waters",      2, 6, 3, 6, 500, 500, [
            [7,3,83],[8,3,83],[9,3,84],[10,3,84]], ],
    9  => ["Gather Ingredients",    3, 3, 0, 0, 50,   10, [
            [1,3,39],[2,3,39],[3,3,39],[1,3,40],[2,3,40],[3,3,40]], ],   
    10 => ["Grow Carrots",          3, 4, 1, 2, 100,   50, [
            [2,10,41],[3,20,41],[4,30,41],[5,40,41],[6,40,41]], ],
    11 => ["Gather Honey",          3, 5, 2, 4, 250, 100, [
            [3,3,42],[4,3,42],[5,3,42],[6,3,42],[7,3,42]], ],
    12 => ["Grow Seeds",            3, 6, 3, 6, 500, 500, [
            [5,3,43],[5,3,44],[5,3,45],[5,3,46]], ],
    13 => ["Lowest Level Area",     4, 3, 0, 0, 50,   10, [
            [1,3,124],[1,3,127],[1,3,133],[2,3,136],[2,3,124],[3,3,121]], ],   
    14 => ["Low Level Area",        4, 4, 1, 2, 100,   50, [
            [1,10,100],[2,20,101],[3,30,102],[4,40,103]], ],
    15 => ["Mid Level Area",        4, 5, 2, 4, 250, 100, [
            [1,3,100],[2,3,101],[3,3,102],[4,3,103]], ],
    16 => ["High Level Area",       4, 6, 3, 6, 500, 500, [
            [1,3,100],[2,3,101],[3,3,102],[4,3,103]], ],

    } 
    
    Miner_hire_quotes = {
    
      0  => ["The most important part of mining, is drinking!"],
      1  => ["Perhaps I will find something better this time."],
      2  => ["I should eat something before I go mining."],
      3  => ["The most interesting part of mining, is the mining."],
      4  => ["The most interes- wait, wheres my pickaxe?"],
      5  => ["I forgot to wash my feet this morning."],
      6  => ["Off I go!"],
      7  => ["Eggs and steak and steak and eggs!"],
      8  => ["I'll get right on it boss."],
      9  => ["Get right to it."],
      10 => ["I'll be on my way now."],
      11 => ["Too bad I can't carry more food."],
      12 => ["This time, I'll hit the rocks harder."],
      13 => ["That ore is just waitin for me!"],
      14 => ["Those rocks are no match for my ferocity."],
      15 => ["I promise not to drink too much while mining."],
    }
    
       
    Fisher_hire_quotes = {
    
      0  => ["Off to the seas!"],
      1  => ["Next time I hope I get a spear."],
      2  => ["I should bring more buckets this time."],
      3  => ["Off for the long haul."],
      4  => ["Inside the ocean is my prey."],
      5  => ["I hope the boat doesn't sway too much, I get sick."],
      6  => ["I hope I don't get seasick today."],
      7  => ["Next trip I bring a better oar."],
      8  => ["Perhaps I should fish where the algae is."],
      9  => ["Off to work I go!"],
      10 => ["Arr you'll never get me booty."],
      11 => ["The most important part of fishing, is not talking a lot."],
      12 => ["Each time I fish, I get better."],
      13 => ["I row faster when I have a spear."],
      14 => ["I'd feel safer with a fishing spear."],
    }
    
    Farmer_hire_quotes = {
      
      0  => ["Tillin' can't go out of style on my watch." ],
      1  => ["At least I'm not cooking today." ],
      2  => ["I'll be planting what I find in the woods I suppose." ],
      3  => ["Welp I better get to diggin."],
      4  => ["Maybe I'll find some roots today."],
      5  => ["I wonder if I'll catch a squirell today."],
      6  => ["I better be careful around the shovels."],
      7  => ["Lets take care of business."],
      8  => ["Off I go to do some tillin'!"],
      9  => ["Lets get this party started... I guess."],
      10  => ["Perhaps next time we can chop?"],
      11  => ["I can handle rejection, but not when my plants die!"],
      12  => ["Lets take care of this."],
      13  => ["Business is blooming, as usual."],
      14  => ["Lets plant these seeds then!"],
      15  => ["Gotta make sure I plant these correctly."],
    }
    
    Hunter_hire_quotes = {
      
      0  => ["I must tread softly, for they hear my approach." ],
      1  => ["I better wear some mud this time." ],
      2  => ["I hope they don't spot me through the brush." ],
      3  => ["We must be very careful when tackling bigger game." ],
      4  => ["Tread softly, but carry a big stick." ],
      5  => ["It would be nice to have better armor." ],
      6  => ["I love to squish things." ],
      7  => ["I'll make sure to get quality material... Hopefully." ],
      8  => ["Lets see if I can bag me an Ogre!" ],
      9  => ["Oh goodness, I hope theres not too many Ogres this time!" ],
      10  => ["Lets tackle the biggest monsters!" ],
      11  => ["Lets take care of business, squishy style!" ],
      12  => ["Take your time, and tread carefully." ],
      13  => ["The odd one out, is the one without a weapon." ],
    }

  end
  class Worker
    def initialize
      @id = 0
      @name = ""
      @type = ''
      @level_required = 0
      @level = 0
      @overall_exp = 0
      @current_level_exp = 0
      @exp_to_level = 0
      @icon_id = 1
      @color = nil
      @description_id = 0
      @quotes = []
      @hired = false
      @active = false
      @working_area = false
      @current_area = nil
    end
    attr_accessor :id
    attr_accessor :name
    attr_accessor :type
    attr_accessor :level_required
    attr_accessor :level
    attr_accessor :current_level_exp
    attr_accessor :exp_to_level
    attr_accessor :overall_exp
    attr_accessor :icon_id
    attr_accessor :color
    attr_accessor :description_id
    attr_accessor :hired
    attr_accessor :active
    attr_accessor :working_area
    attr_accessor :current_area
  end
end
