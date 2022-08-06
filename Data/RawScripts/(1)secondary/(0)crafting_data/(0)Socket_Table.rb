=begin

  (enchantment)=Node.new{
      :level => int,
      :type => stat_sym,
      :math => string('+%'/'+'/'-%','-')},
      :value => (int/float)
  }

  Calculate base formula before value formula.
  Will prevent calculations from exceeding outrageous numbers.

  (:value_formula) = (+/-)(:enchant_level * (%)(:enchant_value))
  (:base_formula) = (:base_stat_value)(+/-)(:enchant_level * (%)(:enchant_value))

  (:gear_stat_value) += ((:base_formula)(+/-)...(:value_formula))


=end


