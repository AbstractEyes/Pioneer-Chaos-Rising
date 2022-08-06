class Player_Sight
  
  attr_accessor :matrices
  attr_reader   :x
  attr_reader   :y
  attr_reader   :direction
  attr_accessor :sight_moved
  
  def initialize(character)
    @matrices = []
    
    @character = character
    
    @x = 0
    @y = 0
    @direction = 0
    enables
  end
  
  def enables
    @active = true
  end
  
  def disable
    @active = false
  end
  
  def add_matrix(matrix)
    return if matrix.nil?
    @matrices.push matrix
  end
  
  def clear_matrices
    return if @matrices.nil?
    @matrices.clear
  end
  
  def move(x,y,direction = @character.direction)
    @x, @y = x, y
    @direction = direction
    @matrices.each {|matrix|
      matrix.refresh(@x,@y) if matrix.is_a?(Rect_Matrix);
      matrix.refresh(@x,@y,@direction) if matrix.is_a?(Line_Matrix);
    }
  end

  def base_x
    @matrices.each { |matrix|
      if matrix.is_a?(Rect_Matrix)
        return matrix.x - matrix.w
      end
    }
    return @x
  end

  def base_y
    @matrices.each { |matrix|
      if matrix.is_a?(Rect_Matrix)
        return matrix.y - matrix.h
      end
    }
    return @y
  end

  def width
    out = 0
    @matrices.each { |matrix|
      out = matrix.width if matrix.is_a?(Rect_Matrix) && matrix.width > out
    }
    return out + 1
  end

  def height
    out = 0
    @matrices.each { |matrix|
      out = matrix.height if matrix.is_a?(Rect_Matrix) && matrix.height > out
    }
    return out + 1
  end

  def nodes
    return [] if @matrices.empty?
    out = []
    @matrices.each { |matrix|
      matrix.nodes.each { |node|
        out.push node
      }
    }
    return out.uniq
  end

  def inside?(x,y)
    for matrix in @matrices
      return true if matrix.inside?(x,y)
    end
    return false
  end
  
end