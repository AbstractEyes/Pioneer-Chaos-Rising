class Game_Temp

  def pb_page=(new_index)
    @pioneer_book_page = new_index
  end

  def pb_page
    return 0 if @pioneer_book_page == nil
    return @pioneer_book_page
  end

  def pb_contents_index=(new_index)
    @pioneer_book_primary_index = new_index
  end

  def pb_contents_index
    return 0 if @pioneer_book_primary_index == nil
    return @pioneer_book_primary_index
  end

  def pb_secondary_index=(new_index)
    @pioneer_book_secondary_index = new_index
  end

  def pb_secondary_index
    return 0 if @pioneer_book_secondary_index == nil
    return @pioneer_book_secondary_index
  end

  def pb_zoom=(new_bool)
    @pioneer_book_zoom = new_bool
  end

  def pb_zoom
    return false if @pioneer_book_zoom == nil
    return @pioneer_book_zoom
  end

end

class Scene_Pioneer_Book < Scene_Base

  def initialize
    super
  end

  def start
    @pioneer_window = Window_Pioneer_Book.new(0,0,640,480)
    super
  end

  def zoom_in
    $game_temp.pb_zoom = true
  end
  def zoom_out
    $game_temp.pb_zoom = false
  end

  def set_page_index
    return if @pioneer_window.nil?
    @pioneer_window.page = $game_temp.pb_page
    @pioneer_window.contents_index = $game_temp.pb_contents_index
    @pioneer_window.secondary_index = $game_temp.pb_secondary_index
    @pioneer_window.refresh
  end

  def perform_transition
    Graphics.transition(0)
  end

  def post_start
    super
    if $game_temp.pb_zoom
      $game_temp.pb_zoom = false
      @pioneer_window.animate_book_zoom_out
    else
      @pioneer_window.animate_book_open
    end
    set_page_index
  end

  def pre_terminate
    super
    if $game_temp.pb_zoom
      @pioneer_window.animate_book_zoom_in
    else
      @pioneer_window.animate_book_close
    end
  end

  def terminate
    super
    $game_temp.pb_page = @pioneer_window.page
    $game_temp.pb_contents_index = @pioneer_window.contents_index
    $game_temp.pb_secondary_index = @pioneer_window.secondary_index
    @pioneer_window.dispose
  end

  def update
    super
    @pioneer_window.update
    case @pioneer_window.page
      when 0
        update_contents_inputs
      else
        update_page_inputs
    end
  end

  def update_page_inputs
    if Input.trigger?(PadConfig.cancel) || Input.trigger?(PadConfig.left)
      Sound.flip_pages
      @pioneer_window.set_category
      if @pioneer_window.page == 0
        @pioneer_window.secondary_index = 0
      end
    elsif Input.trigger?(PadConfig.decision) || Input.trigger?(PadConfig.right)
      Sound.flip_pages
      case @pioneer_window.page
        when 1
          case @pioneer_window.index
            when 0
              $scene = Scene_Rehauled_Status.new
              zoom_in
            when 1
              $scene = Scene_Skill.new(0)
              zoom_in
            when 2
              $scene = Scene_Party.new
              zoom_in
            when 3
              $scene = Scene_Formation.new
              zoom_in
          end
        when 2
          case @pioneer_window.index
            when 0
              # Storage
              $scene = Scene_ItemStorage.new
              zoom_in
              #$scene = Scene_Item.new
              #zoom_in
            when 1
              # Equip
              $scene = Equipment_Management_Scene.new
              zoom_in
            when 2
              # Craft

            when 3
              # Upgrade

            when 4
              # Enchant
              $scene = Enchant_Scene.new
              zoom_in
            when 5
              # Grinder

          end
        when 3
          case @pioneer_window.index
            when 0
              #requests
            when 1
              #tasks
            when 2
              #completed
          end
        when 4
          # Flight
        when 5
          # Options
      end
    elsif Input.trigger?(PadConfig.down)
      Sound.flip_page
      @pioneer_window.next_item
    elsif Input.trigger?(PadConfig.up)
      Sound.flip_page
      @pioneer_window.last_item
    end
  end

  def update_contents_inputs
    if Input.trigger?(PadConfig.cancel) || Input.trigger?(PadConfig.left)
      Sound.close_book
      $game_temp.pb_page = @pioneer_window.page + 1
      $game_temp.pb_contents_index = @pioneer_window.contents_index
      $game_temp.pb_secondary_index = @pioneer_window.secondary_index
      $scene = Scene_Map.new
      zoom_out
    elsif Input.trigger?(PadConfig.decision) || Input.trigger?(PadConfig.right)
      Sound.flip_pages
      @pioneer_window.set_category(@pioneer_window.index + 1)
    elsif Input.trigger?(PadConfig.down)
      Sound.flip_page
      @pioneer_window.next_item
    elsif Input.trigger?(PadConfig.up)
      Sound.flip_page
      @pioneer_window.last_item
    end
  end

end