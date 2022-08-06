#==============================================================================
#  Path Finding
#  Version: 2.0
#  Author: modern algebra (rmrk.net)
#  Date: April 10, 2008
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Thanks:
#    Patrick Lester! For his tutorial on A* Pathfinding algorithm (found at:
#        http://www.gamedev.net/reference/articles/article2003.asp) as well as
#        another amazingly helpful tutorial on using binary heaps (found at:
#        http://www.policyalmanac.org/games/binaryHeaps.htm). Without his excellent
#        tutorials, this script would not exist. So major thanks to him.
#    Zeriab, for tricking me into believing that this was an actual exercise.
#        Also, his table printout actually makes Tables useable :P
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Instructions:
#    To use, merely use this code in a script call INSIDE a Move Event:
#
#      find_path (target_x, target_y, diagonal, max_iterations)
#
#    where target_x and target_y are the target coordinates and diagonal is an
#    optional boolean value (true or false) stating whether or not to allow
#    diagonal movement. max_iterations is also optional, and you can set this if
#    you want the algorithm to quit if it is taking too long. The number you set
#    here refers to how many nodes you let it search through before cancelling
#    the process. If this is set to 0, it will take as many iterations as
#    necessary to find the shortest path.
#
#    You can also set a default value for diagonal and max_iterations
#    by call script with the codes:
#      
#      $game_system.pathfinding_diagonal = true/false # Allow diagonal movement
#      $game_system.pathfinding_iterations = integer # When <= 0, no limit
#
#    For scripters, you can force-move a (0)character down a path via:
#
#      (0)character.force_path (x, y, diagonal, max_iterations)
#
#    (0)character is any Game_Character object, such as $game_player or an event.
#
#    Then, when you do not specifically set diagonal or limit, it will default
#    to the values you set in there
#==============================================================================
#==============================================================================
# ** Game_System
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Summary of Changes:
#    new instance variables - pathfinding_diagonal, pathfinding_iterations
#    aliased method - initialize
#==============================================================================

class Game_System
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Public Instance Variables
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_accessor :pathfinding_diagonal
  attr_accessor :pathfinding_iterations
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Object Initialization
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias modalg_pathfinding_options_init_j5yt initialize
  def initialize
    modalg_pathfinding_options_init_j5yt
    @pathfinding_diagonal = true
    @pathfinding_iterations = 0
  end
end

#==============================================================================
# ** Game_Character
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Summary of Changes:
#    new methods - find_path
#==============================================================================

class Game_Character
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Find Path
  #    trgt_x, trgt_y : the target coordinates
  #    diagonal       : Is diagonal movement allowed?
  #    max_iterations : maximum number of iterations
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def find_path (trgt_x, trgt_y, diagonal = $game_system.pathfinding_diagonal,
                    max_iterations = $game_system.pathfinding_iterations)
    path = $game_map.find_path(self.x, self.y, trgt_x, trgt_y, diagonal,
                     max_iterations, self)
    # Add the path to the move route being executed.
    @move_route.list.delete_at(@move_route_index)
    path.each { |i| @move_route.list.insert(@move_route_index, i) }
    @move_route_index = 0
    p 'FIND PATH' + path.inspect
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Force Path
  #    trgt_x, trgt_y : target coordinates
  #    diagonal       : Is diagonal movement allowed?
  #    max_iterations : maximum number of iterations
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def force_path(trgt_x, trgt_y, diagonal = $game_system.pathfinding_diagonal,
                    max_iterations = $game_system.pathfinding_iterations,
                    direction = 5)
    path = $game_map.find_path(self.x, self.y, trgt_x, trgt_y, diagonal,
                          max_iterations, self)
    # The path retrieved is actually backwards, so it must be reversed
    path.reverse!
    # Add an end command
    path.push(RPG::MoveCommand.new(0))
    move_route = RPG::MoveRoute.new
    move_route.list = path
    move_route.repeat = false
    force_move_route(move_route)
    p 'FORCE PATH' + move_route.inspect
    #self.direction = direction if direction != 5
  end

  def offset_force_path(trgt_x, trgt_y, offset=1, diagonal = $game_system.pathfinding_diagonal,
                        max_iterations = $game_system.pathfinding_iterations)
    path = $game_map.find_path(self.x, self.y, trgt_x, trgt_y, diagonal,
                               max_iterations, self)
    # The path retrieved is actually backwards, so it must be reversed
    path.reverse!
    # Add an end command
    for i in path.size-offset...path.size; path.delete_at(i); end
    path.push(RPG::MoveCommand.new(0))
    move_route = RPG::MoveRoute.new
    move_route.list = path
    move_route.repeat = false
    force_move_route(move_route)
    p 'OFFSET FORCE PATH' + move_route.inspect
  end

  def halt_movement
    move_route = RPG::MoveRoute.new
    move_route.list = [RPG::MoveCommand.new(0)]
    move_route.repeat = false
    force_move_route(move_route)
    #p 'HALT MOVEMENT' + move_route.inspect
  end

end

#==============================================================================
# ** Game_Map
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Summary of Changes:
#    new method - removefrom_binaryheap, find_path
#==============================================================================
class Game_Map
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Remove from Heap
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def removefrom_binaryheap
    @open_nodes[1] = @open_nodes[@listsize]
    @listsize -= 1
    v = 1
    loop do
      u = v
      w = 2*u
      # Check if it's cost is greater than that of it's children
      if w + 1 <= @listsize # If both children exist
        v = w if @total_cost[@open_nodes[u]] >= @total_cost[@open_nodes[w]]
        v = w + 1 if @total_cost[@open_nodes[v]] >= @total_cost[@open_nodes[w + 1]]
      elsif w <= @listsize # If only one child exists
        v = w if @total_cost[@open_nodes[u]] >= @total_cost[@open_nodes[w]]
      end
      # Break if parent has less cost than it's children
      if u == v
        break
      else
        temp = @open_nodes[u]
        @open_nodes[u] = @open_nodes[v]
        @open_nodes[v] = temp
      end
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Find Path
  #    src_x, src_y   : the source coordinates
  #    trgt_x, trgt_y : the target coordinates
  #    diagonal       : Is diagonal movement allowed?
  #    max_iterations : maximum number of iterations
  #    char           : (0)character to follow the path
  #--------------------------------------------------------------------------
  #  Uses the A* method of pathfinding to find a path
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def find_path (src_x, src_y, trgt_x, trgt_y, diagonal, max_iterations, char)
    # No possible path if the target itself is impassable
    path = []
    # Finished if Target Location is closed
    return path unless char.passable?(trgt_x, trgt_y)
    # Initialize
    max_elements = width*height + 2
    openx = Table.new(max_elements)
    openy = Table.new(max_elements)
    @open_nodes = Table.new(max_elements)
    @total_cost = Table.new(max_elements)
    heuristic = Table.new(max_elements)
    step_cost = Table.new(width, height)
    parent_x = Table.new(width, height)
    parent_y = Table.new(width, height)
    actual_list = Table.new(width, height)
    # Add the source node to the open list
    new_openid = 1
    @open_nodes[1] = 1
    openx[1] = src_x
    openy[1] = src_y
    dist = [(trgt_x - src_x).abs, (trgt_y - src_y).abs]
    heuristic[1] = diagonal ? (dist.max*14) + (dist.min*10) : (dist[0] + dist[1])*10
    @total_cost[1] = heuristic[1]
    actual_list[src_x, src_y] = 1
    @listsize = 1
    count = 0
    loop do
      break if actual_list[trgt_x, trgt_y] != 0
      count += 1
      # Update Graphics every 500 iterations
      Graphics.update if count % 500 == 0
      return path if count == max_iterations
      return path if @listsize == 0
      node = @open_nodes[1]
      # Set the x and y value as parent to all possible children
      parent_xval, parent_yval = openx[node], openy[node]
      actual_list[parent_xval, parent_yval] = 2
      removefrom_binaryheap
      # Check all adjacent squares
      for i in 0...8
        break if i > 3 && !diagonal
        # Get the node
        x, y = case i
          when 0 then [parent_xval, parent_yval - 1] # UP
          when 1 then [parent_xval, parent_yval + 1] # DOWN
          when 2 then [parent_xval - 1, parent_yval] # LEFT
          when 3 then [parent_xval + 1, parent_yval] # RIGHT
          when 4 then [parent_xval - 1, parent_yval - 1] # UP LEFT
          when 5 then [parent_xval + 1, parent_yval - 1] # UP RIGHT
          when 6 then [parent_xval - 1, parent_yval + 1] # DOWN LEFT
          when 7 then [parent_xval + 1, parent_yval + 1] # DOWN RIGHT
        end
        # Next if this node is already in the closed list
        next if actual_list[x,y] == 2
        # Next if this tile in impassable
        next unless char.passable?(x, y) # Is the tile passable?
        # Take into account diagonal passability concerns
        if i > 3
          next unless case i
            when 4 then char.passable?(x - 1, y) || char.passable?(x, y - 1)
            when 5 then char.passable?(x + 1, y) || char.passable?(x, y - 1)
            when 6 then char.passable?(x - 1, y) || char.passable?(x, y + 1)
            when 7 then char.passable?(x + 1, y) || char.passable?(x, y + 1)
          end
        end
        # Check if this node already open
        plus_step_cost = ((x - parent_xval).abs + (y - parent_yval).abs) > 1 ? 14 : 10
        temp_step_cost = step_cost[parent_xval, parent_yval] + plus_step_cost
        if actual_list[x,y] == 1
          # If this is a better path to that node
          if temp_step_cost < step_cost[x, y]
            # Change Parent, step, and total cost
            parent_x[x, y] = parent_xval
            parent_y[x, y] = parent_yval
            step_cost[x, y] = temp_step_cost
            # Find index of this position
            index = 1
            while index < @listsize
              index += 1
              break if openx[@open_nodes[index]] == x &&
                                                openy[@open_nodes[index]] == y
            end
            @total_cost[@open_nodes[index]] = temp_step_cost + heuristic[@open_nodes[index]]
          else
            next
          end
        else # If not on open nodes
          # Add to open nodes
          new_openid += 1 # New Id for new item
          @listsize += 1 # Increase List Size
          @open_nodes[@listsize] = new_openid
          step_cost[x, y] = temp_step_cost
          # Calculate Heuristic
          d = [(trgt_x - x).abs, (trgt_y - y).abs]
          heuristic[new_openid] = diagonal ? (d.max*14) + (d.min*10) : (d[0] + d[1])*10
          @total_cost[new_openid] = temp_step_cost + heuristic[new_openid]
          parent_x[x, y] = parent_xval
          parent_y[x, y] = parent_yval
          openx[new_openid] = x
          openy[new_openid] = y
          index = @listsize
          actual_list[x, y] = 1
        end
        # Sort Binary Heap
        while index != 1
          temp_node = @open_nodes[index]
          if @total_cost[temp_node] <= @total_cost[@open_nodes[index / 2]]
            @open_nodes[index] = @open_nodes[index / 2]
            index /= 2
            @open_nodes[index] = temp_node
          else
            break
          end
        end
      end
    end
    out_list = {}
    for list_x in (src_x - 10)...(src_x + 10)
      for list_y in (src_y - 10)...(src_y + 10)
        out_list[list_x] = [] unless out_list.keys.include?(list_x)
        out_list[list_x].push(actual_list[list_x, list_y])
      end
    end
    for list_x in out_list.keys.sort
      p out_list[list_x].inspect
    end
    # Get actual target node
    path_x, path_y = trgt_x, trgt_y
    # Make an array of MoveRoute Commands
    while path_x != src_x || path_y != src_y
      # Get Parent x, Parent Y
      prnt_x, prnt_y = parent_x[path_x, path_y], parent_y[path_x, path_y]
      # DOWN = 1, LEFT = 2, RIGHT = 3, UP = 4, DL = 5, DR = 6, UL = 7, UR = 8
      if path_x < prnt_x # LEFT
        # Determine if upper, lower or direct left
        code = path_y < prnt_y ? 7 : path_y > prnt_y ? 5 : 2
      elsif path_x > prnt_x # RIGHT
        # Determine if upper, lower or direct right
        code = path_y < prnt_y ? 8 : path_y > prnt_y ? 6 : 3
      else # UP or DOWN
        code = path_y < prnt_y ? 4 : 1
      end
      path.push (RPG::MoveCommand.new (code))
      path_x, path_y = prnt_x, prnt_y
    end
    return path
  end
end