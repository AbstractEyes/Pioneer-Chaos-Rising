module FC 
  module INVL_CUSTOM
    
    VOCAB_USE           = 'Use'
    VOCAB_DROP          = 'Discard'
    USE_DROP_WIDTH      = 100
    # You can change the vocabulary for 'Use' and 'Drop' in the Item menu and
    # alter the window width if needed.
    
    CONFIRM_DROP        = false
    VOCAB_DONT_DROP     = 'Cancel'
    VOCAB_DO_DROP       = 'Discard'
    # Change CONFIRM_DROP to true to enable a window that will ask the player to
    # confirm a drop. Cancel will always be highlighted by default. You can also
    # change the vocabulary.
    
    VOCAB_SPACE         = 'Inventory'
    SPACE_GAUGE_COLOR_1 = 15
    SPACE_GAUGE_COLOR_2 = 31
    # You can change the vocabulary for inventory space, as well as the colors
    # of the space gauge.
    
    DEFAULT_SPACE       = 20
    MAX_SPACE           = 100
    INCLUDE_EQUIP_SIZE  = false
    # How much space would you like the player to have by default, what is the
    # most space you'd like them to be able to have, and should equipment be
    # included when determining your total size?
    
    VOCAB_STORE         = 'Store'
    VOCAB_UNSTORE       = 'Withdraw'
    STORE_UNSTORE_WIDTH = 100
    ACTIVE_OPACITY      = 255
    INACTIVE_OPACITY    = 255
    # You can change the vocabulary for storing and withdrawing items, alter the
    # width of the window, and change the opacity of the item window and storage
    # window when either one is active or inactive.
    
  end
end

#-STOP EDITING! (Unless you know what you're doing)----------------------------#
################################################################################
# Import                                                                       #
#------------------------------------------------------------------------------#

$imported = {} if $imported == nil
$imported["FC_INVL"] = true

################################################################################
# Set Up Global Variables                                                      #
#------------------------------------------------------------------------------#

$current_total_size = 0
$current_space = 0
$need_usedrop = 0
$stack_max = 0
$dropping_item = false
$storing_item = false
$withdrawing_item = false
$box_buy = false
$box_sell = false

################################################################################
# Note Interpreter                                                             #
#------------------------------------------------------------------------------#

module FC
  module INVL

    NO_DROP           = /<(?:NO_DROP|no drop)>/i
    RESOURCE_ITEM     = /<(?:RESOURCE_ITEM|resource item)>/i
    NO_STORE          = /<(?:NO_STORE|no store)>/i
    NO_SELL           = /<(?:NO_SELL|no sell)>/i
    ITEM_SIZE         = /<(?:ITEM_SIZE|item size)[ ]*(\d+)>/i
    ADD_SPACE         = /<(?:ADD_SPACE|add space)[ ]*(\d+)>/i
    EQUIP_FOR_SPACE   = /<(?:EQUIP_FOR_SPACE|equip for space)>/i
    UNEQUIP_FOR_SPACE = /<(?:UNEQUIP_FOR_SPACE|unequip for space)>/i
    STACK_MAX         = /<(?:STACK_MAX|item count)[ ]*(\d+)>/i
    STACK_PLUS        = /<(?:STACK_PLUS|item plus)[ ]*(\d+)>/i
    ITEM_CATEGORY     = /<(?:ITEM_CATEGORY|item type)[ ]*(\d+)>/i
    
  end
end

class RPG::BaseItem
  def fc_note_interpreter_invl
    
    @no_drop=false; 
    @no_store=false; 
    @no_sell=false;
    @item_size=1; 
    @add_space=0; 
    @equip_for_space=false; 
    @unequip_for_space=false;
    @stack_max=99; 
    @stack_plus=0; 
    @resource_item=false; 
    @item_category=9001;
    
#~     self.note.split(/[\r\n]+/).each { |line|
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when FC::INVL::NO_DROP
        @no_drop = true
      when FC::INVL::RESOURCE_ITEM
        @resource_item = true
      when FC::INVL::NO_STORE
        @no_store = true
      when FC::INVL::NO_SELL
        @no_sell = true
      when FC::INVL::ITEM_SIZE
        @item_size = $1.to_i
      when FC::INVL::ADD_SPACE
        @add_space = $1.to_i
      when FC::INVL::EQUIP_FOR_SPACE
        @equip_for_space = true
      when FC::INVL::UNEQUIP_FOR_SPACE
        @unequip_for_space = true
      when FC::INVL::STACK_MAX
        @stack_max = $1.to_i
      when FC::INVL::STACK_PLUS
        @stack_plus = $1.to_i
      when FC::INVL::ITEM_CATEGORY
        @item_category = $1.to_i
      end
    }
  end

#----------------#
# Applying Notes #
#----------------#

  def no_drop
    fc_note_interpreter_invl if @no_drop == nil
    return @no_drop
  end

  def resource_item
    fc_note_interpreter_invl if @resource_item == nil
    return @resource_item
  end

  def no_store
    fc_note_interpreter_invl if @no_store == nil
    return @no_store
  end
  
  def no_sell
    fc_note_interpreter_invl if @no_sell == nil
    return @no_sell
  end
  
  def item_size
    fc_note_interpreter_invl if @size == nil
    return @item_size
  end
  
  def add_space
    fc_note_interpreter_invl if @add_space == nil
    return @add_space
  end
  
  def equip_for_space
    fc_note_interpreter_invl if @equip_for_space == nil
    return @equip_for_space
  end
  
  def unequip_for_space
    fc_note_interpreter_invl if @unequip_for_space == nil
    return @unequip_for_space
  end
  
  def stack_max
    fc_note_interpreter_invl if @stack_max == nil
    return @stack_max
  end
  
  def stack_plus
    fc_note_interpreter_invl if @stack_plus == nil
    return @stack_plus
  end

  def item_type
    fc_note_interpreter_invl if @item_category == nil
    return @item_category
  end

end
