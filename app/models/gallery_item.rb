class GalleryItem < ActiveRecord::Base
  set_table_name 'galleries_photos'

  belongs_to :gallery

end


class GalleryPhoto < GalleryItem

  belongs_to :photo

end


class GallerySeparator < GalleryItem
end
