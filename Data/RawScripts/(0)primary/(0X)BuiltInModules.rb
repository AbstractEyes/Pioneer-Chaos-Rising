class Audio
  def self.bgm_play(filename,volume=1,pitch=1)
  end
  def self.bgm_fade(time)
  end
  def self.bgm_stop
  end
  def self.bgs_play(filename,volume=1,pitch=1)
  end
  def self.bgs_stop
  end
  def self.bgs_fade(time)
  end
  def self.me_play(filename,volume=1,pitch=1)
  end
  def self.me_stop
  end
  def self.me_fade(time)
  end
  def self.se_play(filename,volume=1,pitch=1)
  end
  def self.se_stop
  end
end
class Graphics
  def self.update
  end
  def self.wait(duration)
  end
  def self.fadeout(duration)
  end
  def self.fadein(duration)
  end
  def self.freeze
  end
  def self.transition(duration=1,filename="",vague=40)
  end
  def self.snap_to_bitmap
  end
  def self.frame_reset
  end
  def self.width
  end
  def self.height
  end
  def self.resize_screen(width,height)
  end
  attr_accessor :frame_rate
  attr_accessor :frame_count
  attr_accessor :brightness
end
class Input
  def self.update
  end
  def self.press?(num)
  end
  def self.trigger?(num)
  end
  def self.repeat?(num)
  end
  def self.dir4
  end
  def self.dir8
  end
end