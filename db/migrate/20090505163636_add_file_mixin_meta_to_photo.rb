class AddFileMixinMetaToPhoto < ActiveRecord::Migration
  def self.up
    add_column :photos, :mime_major, :string, :limit => 16, :default=> 'image'
    add_column :photos, :size, :integer

    rename_column :photos, :width, :image_width
    rename_column :photos, :height, :image_height
    rename_column :photos, :format, :mime_minor
    change_column :photos, :mime_minor, :string, :limit => 32

    remove_column :photos, :file_exists

    Photo.reset_column_information
    Photo.find(:all).each do |photo|
      path = File.join(RAILS_ROOT, 'public', photo.site.name, 'photos', photo.file_name)
      photo.size = File.size(path)
      photo.mime_minor = photo.mime_minor.downcase
      photo.save!
      say "Updated image information for: #{photo.site.name}/#{photo.file_name}", true
    end
  end

  def self.down
    Photo.find(:all).each do |photo|
      photo.mime_minor = photo.mime_minor.upcase
      photo.save!
      say "Updated format for: #{photo.site.name}/#{photo.file_name}", true
    end

    add_column :photos, :file_exists, :boolean, :default => true

    change_column :photos, :mime_minor, :string, :limit => 8
    rename_column :photos, :mime_minor, :format
    rename_column :photos, :image_height, :height
    rename_column :photos, :image_width, :width

    remove_column :photos, :size
    remove_column :photos, :mime_major
  end
end
