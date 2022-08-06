class Harmony

  def initialize(wrapper)
    @wrapper = wrapper
  end

  #only to be called when the positive array is done
  def harmony?
    return missing_elements.empty? #returns the value determining if negative wrapper should be removed
  end

  # returns array of elements, using the current element fragment as a catalyst
  def check_element(frag)
    return missing_elements(frag)
  end

  # returns an array of missing element keys
  def missing_elements(frag=nil,hash=false)
    used = used_elements
    ([frag] + @wrapper.negative_fragments).each { |fragment|
      next if fragment.nil?
      if used.keys.include?(fragment.book_key)
        used[fragment.book_key] -= 1
      end
    }
    mark = []
    used.each { |ele_id, value|
      next if ele_id == nil
      mark.push ele_id if value <= 0
    }
    if hash
      return used
    else
      return (used.keys - mark)
    end
  end

  # returns an array of negated element keys with values
  def used_elements
    out = {}
    @wrapper.positive_fragments.each { |fragment|
      #check which element
      neg = negate(fragment.book_key)
      out[neg] = 0 unless out.keys.include?(neg)
      out[neg] += 1
      #include chaos clauses
    }
    return out
  end

  def reduced?(frag)
    old = missing_elements(nil, true)
    check = missing_elements(frag, true)
    old.each { |ele_sym, value|
      if check[ele_sym] < value
        return true
      end
    }
    return false
  end

  # returns negated element using the element tree
  def negate(book)
    return PHI::ENCHANTMENT.negate(book)
  end

end