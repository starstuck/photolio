# Each site parameters witf default fallbacks

module SiteParams

  module DefaultParams
    # Maximum photo size stored on disk. On upload all larger photos will be
    # resized to this size before storing.
    # Format: <width>x<height>. Only one of width, height must be provided.
    def photo_store_size
      'x400'
    end
  end


  module PolinostudioParams
    include DefaultParams
  end


  module PitchouguinaParams
    include DefaultParams
    
    def photo_store_size 
      'x450'
    end
  end


  class Params
  end


  def self.for_site(site)
    if site.name == 'polinostudio'
      params_module = PolinostudioParams
    elsif site.name == 'pitchouguina'
      params_module = PitchouguinaParams
    else
      params_module = DefaultParams
    end
    p = Params.new
    p.extend(params_module)
    return p
  end

end
