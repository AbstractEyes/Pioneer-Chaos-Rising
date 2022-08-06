# // Script Installation Order
# // ATS
# // YERD Menu System Options
# // This Patch
module IRS
  
  def self.get_windowskin_name
    unless $game_variables.nil?()
      winvar = YE::SYSTEM::WINDOW_VARIABLE
      if $game_variables[winvar] == 0
        $game_variables[winvar] = YE::SYSTEM::DEFAULT_WINDOW
      elsif !YE::SYSTEM::WINDOW_HASH.include?($game_variables[winvar])
        $game_variables[winvar] = YE::SYSTEM::DEFAULT_WINDOW
      end
      mso_windowskin = YE::SYSTEM::WINDOW_HASH[$game_variables[winvar]]
    else
      mso_windowskin = YE::SYSTEM::WINDOW_HASH[YE::SYSTEM::DEFAULT_WINDOW]
    end
    return mso_windowskin
  end
  
end
#=begin
class Game_Message
  
  alias :ips_gmms_clear :clear unless $@
  def clear( *args, &block )
    ips_gmms_clear( *args, &block )
    reset_windowskins()
  end
  
  def reset_windowskins()
    wsn = IRS.get_windowskin_name()
    self.message_windowskin    = wsn
    self.face_windowskin       = wsn
    self.choice_windowskin     = wsn
    self.choicehelp_windowskin = wsn
    self.name_windowskin       = wsn
    self.word_windowskin       = wsn
  end
  
end

class Window_WordBox
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Set Stats
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def set_stats
    self.windowskin = Cache.windows ($game_message.word_windowskin)
    self.opacity = $game_message.word_opacity
    self.back_opacity = $game_message.word_backopacity
    create_back_sprite ($game_message.word_dim, $game_message.word_use_dim)
    self.contents.font.name = $game_message.word_fontname
    self.contents.font.size = $game_message.word_fontsize
    self.contents.font.color = text_color ($game_message.word_fontcolour)
  end
  
end

class Window_NameBox
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Set Stats
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def set_stats
    self.opacity = $game_message.name_opacity
    self.back_opacity = $game_message.name_backopacity
    create_back_sprite ($game_message.name_dim, $game_message.name_use_dim)
    self.windowskin = Cache.windows ($game_message.name_windowskin)
  end
  
end

class Window_FaceBox
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Remake Window
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def remake_window (width = $game_message.face_width, height = $game_message.face_height)
    self.width = [width + 2*$game_message.face_border_size, 33].max
    self.height = [height + 2*$game_message.face_border_size, 33].max
    create_contents
    self.windowskin = Cache.windows ($game_message.face_windowskin)
    if $game_message.face_fadein
      self.back_opacity = 0
      @fade_count = $game_message.face_opacity
    else
      self.back_opacity = $game_message.face_opacity
    end
    create_back_sprite ($game_message.face_dim, $game_message.face_use_dim)
    self.visible = $game_message.face_window 
  end
  
end

class Window_ChoiceBox #< Window_Selectable
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Object Initialization
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def initialize( viewport=nil )
    font = Font.new ($game_message.choice_fontname, $game_message.choice_fontsize)
    @wlh = $game_message.choice_wlh > 0 ? $game_message.choice_wlh : $game_message.wlh
    width, height, line_num = prepare_choices (font.dup)
    @back_sprite = Sprite.new (viewport)
    super (0, 0, width, height)
    if line_num*@wlh > (height - 32)
      self.contents.dispose
      self.contents = Bitmap.new (width - 32, line_num*@wlh)
    end
    self.viewport = viewport
    self.windowskin = Cache.windows ($game_message.choice_windowskin)
    self.opacity = $game_message.choice_opacity
    self.back_opacity = $game_message.choice_backopacity
    self.openness = 0
    self.contents.font = font
    self.contents.font.color = text_color ($game_message.choice_fontcolour)
    create_back_sprite ($game_message.choice_dim, $game_message.choice_use_dim)
    @spacing = $game_message.choice_spacing
    @column_max = $game_message.column_max
    @item_max = $game_message.choices.size
    @underline = false
    @highlight = -1
    @last_index = -1
    refresh
  end #if true == false
  
end

class Window_ChoiceHelp #< Window_Base
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Object Initialization
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def initialize (choice_helps)
    @back_sprite = Sprite.new
    @choice_helps = []
    @underline = false
    @highlight = -1
    font = Font.new ($game_message.choicehelp_fontname, $game_message.choicehelp_fontsize)
    p_formatter = P_Formatter_ATS.new (font)
    longest_line = 1
    x, y = $game_message.choicehelp_x, $game_message.choicehelp_y
    width, height = $game_message.choicehelp_width, $game_message.choicehelp_height
    @wlh = $game_message.choicehelp_wlh < 0 ? $game_message.wlh : $game_message.choicehelp_wlh
    wdth = width > 0 ? width - 32 : 5000
    tallest = 1
    choice_helps.each { |string| 
      s_d = $game_message.convert_special_characters (string.dup)
      s_d.gsub! (/\x16/) { "\x00" }
      lines = []
      line_lengths = []
      while !s_d.empty?
        ls, lc, j = p_formatter.format_by_line (s_d, wdth)
        line_lengths.push (wdth - (ls * (lc - 1)))
        lines.push (s_d.slice! (/.*?\x00/))
      end
      tallest = [tallest, lines.size].max
      @choice_helps.push ([lines, line_lengths])
    }
    p_formatter.dispose
    width = line_lengths.max + 32 if width < 0
    x = x >= 0 ? x : [(Graphics.width - width) / 2, 0].max
    y = $game_message.choicehelp_y < 0 ? 0 : $game_message.choicehelp_y
    width = [33, [width, Graphics.width - x].min].max
    height = height < 0 ? 32 + (tallest*@wlh) : [height, 33].max
    super (x, y, width, height)
    @contents_width = contents.width
    self.windowskin = Cache.windows ($game_message.choicehelp_windowskin)
    self.opacity = $game_message.choicehelp_opacity
    self.back_opacity = $game_message.choicehelp_backopacity
    self.openness = 0
    create_back_sprite ($game_message.choicehelp_dim, $game_message.choicehelp_use_dim)
    self.contents.font = Font.new ($game_message.choicehelp_fontname, $game_message.choicehelp_fontsize)
    self.contents.font.color = text_color ($game_message.choicehelp_fontcolour)
    @index = -1
  end
  
end  

class Window_Message
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Start Message
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def start_message ( *args )
    @starting = true
    @wlh = $game_message.wlh
    @align = 0
    @max_oy = 0
    @line_x = 0
    @underline = $game_message.underline
    @highlight = $game_message.highlight
    malg_atxs3_msgstrt_8ik3 ( *args )
    @text.gsub! (/([^\s])\s*\x00/) { "#{$1} " } if $game_message.paragraph_format
    # Remove x00 from middle of wb and nb boxes
    @text.gsub! (/[\x19\x1a]{.*?}/) { |match| match.gsub (/\x00/) { "" } }
    @text.gsub! (/\x16/) { "\x00" }
    format_line
    self.windowskin = Cache.windows ($game_message.message_windowskin).dup
    self.windowskin.clear_rect (80, 16, 32, 32) unless $game_message.scroll_show_arrows
    self.contents.font.name = $game_message.message_fontname
    self.contents.font.size = $game_message.message_fontsize
    @p_formatter.bitmap.font = self.contents.font.dup
    $game_message.play_se ($game_message.start_se) if $game_message.start_sound
    @starting = false
  end
  
end
#=end

class Window_FaceBox #< Window_Base

  alias :irs_pt_wfb_initialize :initialize unless $@
  def initialize( *args, &block )
    irs_pt_wfb_initialize( *args, &block ) ; self.update_windowskin
  end
  

end

class Window_NameBox #< Window_Base
  
  alias :irs_pt_wnb_initialize :initialize unless $@
  def initialize( *args, &block )
    irs_pt_wnb_initialize( *args, &block ) ; self.update_windowskin
  end

end

class Window_ChoiceBox # Window_Command 
  
  alias :irs_pt_wcb_initialize :initialize unless $@
  def initialize( *args, &block )
    irs_pt_wcb_initialize( *args, &block ) ; self.update_windowskin
  end
  
end

class Window_Message #< Window_Selectable
  
  alias :irs_pt_wm_initialize :initialize unless $@
  def initialize( *args, &block )
    irs_pt_wm_initialize( *args, &block ) ; self.update_windowskin
  end
  
end

class Scene_End
  
  alias :irs_pt_scend_terminate :terminate unless $@
  def terminate( *args, &block )
    irs_pt_scend_terminate( *args, &block )
    $game_message.reset_windowskins()
  end
  
end

# // Script Installation Order
# // ATS
# // YERD Menu System Options
# // This Patch
=begin
module IRS
  
  def self.get_windowskin_name
    unless $game_variables.nil?()
      winvar = YE::SYSTEM::WINDOW_VARIABLE
      if $game_variables[winvar] == 0
        $game_variables[winvar] = YE::SYSTEM::DEFAULT_WINDOW
      elsif !YE::SYSTEM::WINDOW_HASH.include?($game_variables[winvar])
        $game_variables[winvar] = YE::SYSTEM::DEFAULT_WINDOW
      end
      mso_windowskin = YE::SYSTEM::WINDOW_HASH[$game_variables[winvar]]
    else
      mso_windowskin = YE::SYSTEM::WINDOW_HASH[YE::SYSTEM::DEFAULT_WINDOW]
    end
    return mso_windowskin
  end
  
end

class Game_Message
  
  alias :ips_gmms_clear :clear unless $@
  def clear( *args, &block )
    ips_gmms_clear( *args, &block )
    wsn = IRS.get_windowskin_name()
    self.message_windowskin    = wsn
    self.face_windowskin       = wsn
    self.choice_windowskin     = wsn
    self.choicehelp_windowskin = wsn
    self.name_windowskin       = wsn
    self.word_windowskin       = wsn
  end
  
end

class Window_WordBox
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Set Stats
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def set_stats
    self.windowskin = Cache.windows ($game_message.word_windowskin)
    self.opacity = $game_message.word_opacity
    self.back_opacity = $game_message.word_backopacity
    create_back_sprite ($game_message.word_dim, $game_message.word_use_dim)
    self.contents.font.name = $game_message.word_fontname
    self.contents.font.size = $game_message.word_fontsize
    self.contents.font.color = text_color ($game_message.word_fontcolour)
  end
  
end

class Window_NameBox
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Set Stats
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def set_stats
    self.opacity = $game_message.name_opacity
    self.back_opacity = $game_message.name_backopacity
    create_back_sprite ($game_message.name_dim, $game_message.name_use_dim)
    self.windowskin = Cache.windows ($game_message.name_windowskin)
  end
  
end

class Window_FaceBox
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Remake Window
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def remake_window (width = $game_message.face_width, height = $game_message.face_height)
    self.width = [width + 2*$game_message.face_border_size, 33].max
    self.height = [height + 2*$game_message.face_border_size, 33].max
    create_contents
    self.windowskin = Cache.windows ($game_message.face_windowskin)
    if $game_message.face_fadein
      self.back_opacity = 0
      @fade_count = $game_message.face_opacity
    else
      self.back_opacity = $game_message.face_opacity
    end
    create_back_sprite ($game_message.face_dim, $game_message.face_use_dim)
    self.visible = $game_message.face_window 
  end
  
end

class Window_ChoiceBox < Window_Selectable
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Object Initialization
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def initialize (viewport = nil)
    font = Font.new ($game_message.choice_fontname, $game_message.choice_fontsize)
    @wlh = $game_message.choice_wlh > 0 ? $game_message.choice_wlh : $game_message.wlh
    width, height, line_num = prepare_choices (font.dup)
    @back_sprite = Sprite.new (viewport)
    super (0, 0, width, height)
    if line_num*@wlh > (height - 32)
      self.contents.dispose
      self.contents = Bitmap.new (width - 32, line_num*@wlh)
    end
    self.viewport = viewport
    self.windowskin = Cache.windows ($game_message.choice_windowskin)
    self.opacity = $game_message.choice_opacity
    self.back_opacity = $game_message.choice_backopacity
    self.openness = 0
    self.contents.font = font
    self.contents.font.color = text_color ($game_message.choice_fontcolour)
    create_back_sprite ($game_message.choice_dim, $game_message.choice_use_dim)
    @spacing = $game_message.choice_spacing
    @column_max = $game_message.column_max
    @item_max = $game_message.choices.size
    @underline = false
    @highlight = -1
    @last_index = -1
    refresh
  end
  
end

class Window_ChoiceHelp < Window_Base
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Object Initialization
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def initialize (choice_helps)
    @back_sprite = Sprite.new
    @choice_helps = []
    @underline = false
    @highlight = -1
    font = Font.new ($game_message.choicehelp_fontname, $game_message.choicehelp_fontsize)
    p_formatter = P_Formatter_ATS.new (font)
    longest_line = 1
    x, y = $game_message.choicehelp_x, $game_message.choicehelp_y
    width, height = $game_message.choicehelp_width, $game_message.choicehelp_height
    @wlh = $game_message.choicehelp_wlh < 0 ? $game_message.wlh : $game_message.choicehelp_wlh
    wdth = width > 0 ? width - 32 : 5000
    tallest = 1
    choice_helps.each { |string| 
      s_d = $game_message.convert_special_characters (string.dup)
      s_d.gsub! (/\x16/) { "\x00" }
      lines = []
      line_lengths = []
      while !s_d.empty?
        ls, lc, j = p_formatter.format_by_line (s_d, wdth)
        line_lengths.push (wdth - (ls * (lc - 1)))
        lines.push (s_d.slice! (/.*?\x00/))
      end
      tallest = [tallest, lines.size].max
      @choice_helps.push ([lines, line_lengths])
    }
    p_formatter.dispose
    width = line_lengths.max + 32 if width < 0
    x = x >= 0 ? x : [(Graphics.width - width) / 2, 0].max
    y = $game_message.choicehelp_y < 0 ? 0 : $game_message.choicehelp_y
    width = [33, [width, Graphics.width - x].min].max
    height = height < 0 ? 32 + (tallest*@wlh) : [height, 33].max
    super (x, y, width, height)
    @contents_width = contents.width
    self.windowskin = Cache.windows ($game_message.choicehelp_windowskin)
    self.opacity = $game_message.choicehelp_opacity
    self.back_opacity = $game_message.choicehelp_backopacity
    self.openness = 0
    create_back_sprite ($game_message.choicehelp_dim, $game_message.choicehelp_use_dim)
    self.contents.font = Font.new ($game_message.choicehelp_fontname, $game_message.choicehelp_fontsize)
    self.contents.font.color = text_color ($game_message.choicehelp_fontcolour)
    @index = -1
  end
  
end  

class Window_Message
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Start Message
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def start_message (*args)
    @starting = true
    @wlh = $game_message.wlh
    @align = 0
    @max_oy = 0
    @line_x = 0
    @underline = $game_message.underline
    @highlight = $game_message.highlight
    malg_atxs3_msgstrt_8ik3 (*args)
    @text.gsub! (/([^\s])\s*\x00/) { "#{$1} " } if $game_message.paragraph_format
    # Remove x00 from middle of wb and nb boxes
    @text.gsub! (/[\x19\x1a]{.*?}/) { |match| match.gsub (/\x00/) { "" } }
    @text.gsub! (/\x16/) { "\x00" }
    format_line
    self.windowskin = Cache.windows ($game_message.message_windowskin).dup
    self.windowskin.clear_rect (80, 16, 32, 32) unless $game_message.scroll_show_arrows
    self.contents.font.name = $game_message.message_fontname
    self.contents.font.size = $game_message.message_fontsize
    @p_formatter.bitmap.font = self.contents.font.dup
    $game_message.play_se ($game_message.start_se) if $game_message.start_sound
    @starting = false
  end
  
end

class Window_FaceBox < Window_Base

  alias :irs_pt_wfb_initialize :initialize unless $@
  def initialize( *args, &block )
    irs_pt_wfb_initialize( *args, &block ) ; self.update_windowskin
  end
  

end

class Window_NameBox < Window_Base
  
  alias :irs_pt_wnb_initialize :initialize unless $@
  def initialize( *args, &block )
    irs_pt_wnb_initialize( *args, &block ) ; self.update_windowskin
  end

end

class Window_ChoiceBox < Window_Command 
  
  alias :irs_pt_wcb_initialize :initialize unless $@
  def initialize( *args, &block )
    irs_pt_wcb_initialize( *args, &block ) ; self.update_windowskin
  end
  
end

class Window_Message < Window_Selectable
  
  alias :irs_pt_wm_initialize :initialize unless $@
  def initialize( *args, &block )
    irs_pt_wm_initialize( *args, &block ) ; self.update_windowskin
  end
  
end
=end