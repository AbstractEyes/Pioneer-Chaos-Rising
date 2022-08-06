class Enemy_Object
  attr_reader :container

  def initialize(data)
    @container = data
  end

  def skill_id
    return get(:skill_class).tr(':', '').to_sym
  end

  def unlocked_skills
    return get(:UNLOCKED)
  end

  def level
    return get(:level).to_i
  end

  def hp
    return get(:hp).to_i * level
  end

  def mp
    return get(:mp).to_i * level
  end

  def sta
    return get(:sta).to_i
  end

  def atk
    return get(:atk).to_i * level
  end

  def spi
    return get(:spi).to_i * level
  end

  def agi
    return get(:agi).to_i * level
  end

  def def
    return get(:def).to_i * level
  end

  def res
    return get(:res).to_i
  end

  def sta_res
    return get(:sta_res).to_i
  end

  def phy_res
    return get(:phy_res).to_i
  end

  def ele_res_v
    return get(:ele_res_v).to_i
  end

  def ele_dam
    return get(:ele_dam)
  end

  def ele_res
    return get(:ele_res)
  end

  def cri
    return get(:cri).to_i
  end

  def cri_mul
    return get(:cri_mul).to_f
  end

  def items
    return get(:items)
  end

  def exp
    return get(:exp).to_i
  end

  def name
    get(:name)
  end

  def get(key)
    return @container[key]
  end

end