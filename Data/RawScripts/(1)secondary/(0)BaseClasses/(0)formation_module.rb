module Matrix
  def self.rotate(o)
    rows, cols = o.size, o[0].size
    Array.new(cols){|i| Array.new(rows){|j| o[j][cols - i - 1]}}
  end
end

module PHI
  module Formation

    FORMS = {
      :primary => 0,
      0 => {
        :name => 'Point',
        :matrix => [
          [0,0,0,0,0],
          [0,0,1,0,0],
          [0,2,0,3,0],
          [4,0,0,0,5],
          [0,0,0,0,0]
        ]
      },
      1 => {
        :name => 'Spear tip',
        :matrix => [
          [0,0,1,0,0],
          [0,0,0,0,0],
          [0,2,0,3,0],
          [0,0,0,0,0],
          [4,0,0,0,5]
        ]
      },
      2  => {
        :name => 'Wall',
        :matrix => [
          [0,0,1,0,0],
          [4,2,0,3,5],
          [0,0,0,0,0],
          [0,0,0,0,0],
          [0,0,0,0,0]
        ],
      },
      3 => {
        :name => 'M',
        :matrix => [
            [0,2,0,3,0],
            [0,0,0,0,0],
            [0,0,1,0,0],
            [0,0,0,0,0],
            [4,0,0,0,5]
        ]
      },
      4 => {
        :name => 'V',
        :matrix => [
            [1,0,0,0,2],
            [0,0,0,0,0],
            [0,3,0,4,0],
            [0,0,0,0,0],
            [0,0,5,0,0]
        ]
      }
    }

    @amount = 3

    def self.primary
      return FORMS[:primary]
    end
    def self.primary=(new_primary)
      FORMS[:primary] = new_primary
    end

    def self.formations
      return FORMS
    end

    def self.set_formations(input_formations)
      FORMS.clear
      input_formations.each { |k, v|
        FORMS[k] = v
      }
    end

    def self.set(key, array_input)
      matrix = []
      for i in 0...5
        i2 = i * 5
        matrix.push array_input[i2...i2+5]
      end
      FORMS[key][:matrix] = matrix
    end

    def self.add
      @amount += 1 #if @amount < MAX_FORMATIONS
    end
    def self.remove
      @amount -= 1 #if @amount > 3
    end

    def self.rotate(matrix, times)
      out = matrix
      for i in 0...times
        out = Matrix.rotate(out)
      end
      return out
    end

    def self.prepare
      return [] unless $scene.is_a?(Scene_Map)
      return if $game_party.any_player_moving?
      matrix = self.prepare_matrix(self.rotate_by_direction(self.formations[self.formations[:primary]][:matrix], $game_player.direction))
      px, py = $game_player.x - 2, $game_player.y - 3
      members = $game_party.sorted_members[0...5]
      mx, my = 0, 0
      for x in px...px+5
        for y in py...py+5
          val = matrix[self.to_index(mx, my)]
          if val != 0
            next if members[(val-1)] == -1
            player = $game_party.players[members[(val-1)]]
            player.force_path(x,y)
           # player.direction = dir_4($game_player.direction)
          end
          my += 1
        end
        my = 0
        mx += 1
      end
    end

    def self.to_index(x,y)
      return (x + (5 * y))
    end

    def self.dir_4(direction)
      case direction
        when 1, 4
          return 4
        when 3, 2
          return 2
        when 9, 6
          return 6
        when 7, 8
          return 8
        else
          return 5
      end
    end

    def self.rotate_by_direction(matrix, direction)
      case direction
        when 1, 4
          return rotate(matrix, 1)
        when 3, 2
          return rotate(matrix, 2)
        when 9, 6
          return rotate(matrix, 3)
        when 7, 8
          return matrix
        else
          return matrix
      end
    end


    def self.prepare_matrix(raw)
      matrix = []
      for i in 0...raw.size
        matrix.concat(raw[i])
      end
      return matrix
    end

  end
end