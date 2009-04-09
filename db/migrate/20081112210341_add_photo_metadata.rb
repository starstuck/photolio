require 'mini_magick'


class AddPhotoMetadata < ActiveRecord::Migration
  def self.up
    add_column :photos, :width, :integer
    add_column :photos, :height, :integer
    add_column :photos, :format, :string, :limit => 8

    Photo.reset_column_information
    Photo.find(:all).each do |photo|
      image = MiniMagick::Image.new("#{Photo::PHOTOS_ROOT}/#{photo.file_name}")
      photo.width = image[:width]
      photo.height = image[:height]
      photo.format = image[:format]
      photo.save!
      say "Read metadata for: #{photo.file_name}", true
    end
  end

  def self.down
    remove_column :photos, :width
    remove_column :photos, :height
  end
end
