class System_Config
  attr_reader   :config

  def initialize
    load_config
    set_window
    save_config
  end

  def set_window
    $def_x = x
    $def_y = y
    $def_width = w
    $def_height = h
  end

  def screen
    return Coord.new(x,y)
  end

  def x
    return @config[:window_x][1].to_i
  end
  def x=(new_x)
    @config[:window_x][1] = new_x.to_s
  end

  def y
    return @config[:window_y][1].to_i
  end
  def y=(new_y)
    @config[:window_y][1] = new_y.to_s
  end

  def w
    return @config[:window_w][1].to_i
  end
  def w=(new_w)
    @config[:window_w][1] = new_w.to_s
  end

  def h
    return @config[:window_h][1].to_i
  end
  def h=(new_h)
    @config[:window_h][1] = new_h.to_s
  end

  def version
    return @config[:version][1]
  end

  def music_volume
    return (@config[:music_volume][1].to_i * (master_volume / 100.0)).to_i
  end
  def music_volume=(new_volume)
    @config[:music_volume][1] = new_volume.to_s
  end

  def sfx_volume
    return (@config[:sfx_volume][1].to_i * (master_volume / 100.0)).to_i
  end
  def sfx_volume=(new_volume)
    @config[:sfx_volume][1] = new_volume.to_s
  end

  def ambient_volume
    return (@config[:ambient_volume][1].to_i * (master_volume / 100.0)).to_i
  end
  def ambient_volume=(new_volume)
    @config[:ambient_volume][1] = new_volume.to_s
  end

  def master_volume
    return @config[:master_volume][1].to_i
  end
  def master_volume=(new_volume)
    @config[:master_volume][1] = new_volume.to_s
  end

  def self.kb_inputs=(input)
    @config[:KB_Up]       = input[0][1]
    @config[:KB_Down]     = input[1][1]
    @config[:KB_Left]     = input[2][1]
    @config[:KB_Right]    = input[3][1]
    @config[:KB_Dash]     = input[4][1]
    @config[:KB_Cancel]   = input[5][1]
    @config[:KB_Confirm]  = input[6][1]
    @config[:KB_Display]  = input[7][1]
    @config[:KB_Menu]     = input[8][1]
    @config[:KB_Pause]    = input[9][1]
    @config[:KB_PageUp]   = input[10][1]
    @config[:KB_PageDown] = input[11][1]
  end

  def self.ct_inputs=(input)
    @config[:CT_Up]       = input[0][1]
    @config[:CT_Down]     = input[1][1]
    @config[:CT_Left]     = input[2][1]
    @config[:CT_Right]    = input[3][1]
    @config[:CT_Dash]     = input[4][1]
    @config[:CT_Cancel]   = input[5][1]
    @config[:CT_Confirm]  = input[6][1]
    @config[:CT_Display]  = input[7][1]
    @config[:CT_Menu]     = input[8][1]
    @config[:CT_Pause]    = input[9][1]
    @config[:CT_PageUp]   = input[10][1]
    @config[:CT_PageDown] = input[11][1]
  end

  def save_config
    begin
      file = File.open('config.txt','w')
      @config.sort { |a, b| a[1] <=> b[1] }.each do |key, val|
        if val.size == 1
          val1 = val[1]
          val2 = ''
        else
          val1 = val[1]
          val2 = val[2]
        end
        file.write(key.to_s + ' ' + val1.to_s + ' ' + val2.to_s + "\n")
      end
    rescue
      Exception.raise('Failed to save config file, exiting program.')
      exit
    end

  end
private
  def load_config
    begin
      @config = {}
      file = File.open('config.txt', 'r')
      sort_val = 0
      file.each_line { |line|
        p line.inspect
        next if line.empty?
        next if line[0..1] == "\n"
        next if line.include?('#')
        nl = line.split(' ')
        @config[nl[0].to_sym] = [sort_val]
        @config[nl[0].to_sym] += nl[1..2]
        sort_val+=1
      }
    rescue
      Exception.raise('Failed to load config file. Check to make sure its not in use.')
      exit
    end

  end

end

$system = System_Config.new