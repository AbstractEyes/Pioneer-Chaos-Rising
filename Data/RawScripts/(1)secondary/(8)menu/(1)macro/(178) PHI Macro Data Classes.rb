# This is a single macro piece with arguments.
class M_Piece
  attr_reader :type
  attr_reader :args
  attr_accessor :priority
  def initialize(priority,req,type,*args)
    @priority = priority
    @req = req
    @type = type
    @args = args
  end
end

# Holds all the pieces for the requirement procedure.
class M_Requirement
  def initialize(bool, priority, target, statistic, 
              type_comparison, direct_param, compare_param)
    @bool = bool
    @priority = priority
    @target = target
    @statistic = statistic
    @type_comparison = type_comparison
    @direct_param = direct_param
    @compare_param = compare_param
  end
end

# Creates a macro, and has data flow functions.
class Macro
  def initialize(req,*pieces)
    super(pieces)
    @req = req
    @pieces = pieces
    @index = pieces.size
  end
  def add(piece)
    @pieces.push(piece)
    set_index
  end
  def get
    @pieces.pop
    set_index
  end
  def set_index
    @index = @pieces.size
  end
end

# This is a macro interpreter for each battler.
class Macro_Interpreter
  
  # Initializes the macro for the user and the target, does not
  # discriminate.  Utilizes the battler class.
  def initialize(user, macros)
    @user = user
    @macros = user.macros.sort { |a, b| a.priority <=> b.priority }
  end
  
  def get
    return @macros
  end
  
  # This will only run if your atb meter is full.  
  # This is to prevent any action when the meter is not.
  # Only needed if the macro is executing and interrupted.
  def update
  end
  
end