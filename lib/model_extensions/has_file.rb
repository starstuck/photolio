require 'find'
require 'ftools'
require 'fileutils'
require 'mini_magick_utils'

module ModelExtensions::HasFile

  BASE_FOLDER_NAME = 'files' # Folder relative to public

  def self.resized_file_mode
    0644
  end

  def has_file 
    class_eval do
      include InstanceMethods
      extend ClassMethods
      
      before_validation_on_create :update_file_meta
      after_save :write_file
      after_destroy :delete_file
      
      attr_readonly :file_name
      
      validates_length_of :file_name, :maximum => 255, :allow_blank => false
      validates_uniqueness_of :file_name, :scope => :site_id
      
      validates_length_of :mime_major, :maximum => 16
      validates_length_of :mime_minor, :maximum => 32
      
      validates_numericality_of :size, :only_integer => true
      
      validates_numericality_of :image_width, :only_integer => true
      validates_numericality_of :image_height, :only_integer => true
      end
  end
  
  class MimeFinder
    include Singleton
    
    # Read cached mime types hash
    def mime_types
      @mime_types ||= read_mime_types
    end
    
    def mime_type(filename)
      suffix1 = (/\.(\w+)$/ =~ filename && $1.downcase)
      suffix2 = (/\.(\w+)\.[\w\-]+$/ =~ filename && $1.downcase)
      mime_types[suffix1] || mime_types[suffix2] || "application/octet-stream"
    end
    
    private
    def read_mime_types
      for file in ['/etc/mime.types', '/etc/httpd/mime.types', '/etc/apache2/mime.types']
        if File.exists? file
          break
        end
      end
      File.open(file) do |io|
        hash = Hash.new
        io.each{ |line|
          next if /^#/ =~ line
          line.chomp!
          mimetype, ext0 = line.split(/\s+/, 2)
          next unless ext0   
          next if ext0.empty?
          ext0.split(/\s+/).each{ |ext| hash[ext] = mimetype }
        }
        hash
      end
    end
  end 
  
  module ClassMethods
    
    attr_reader :files_folder
    
    # Set file foler name.
    # Files will be stored in folder with this name in site public folder
    def set_files_folder(name)
      @files_folder = name
    end
    
    def public_path
      @public_path ||= defined?(Rails.public_path) ? Rails.public_path : File.join(RAILS_ROOT, "public")
    end

  end

  module InstanceMethods
    
    def file
      File.new(file_disk_path)
    end
    
    def file=(file)
      @uploaded_file=file
    end

    def file_name_extension
      ext = file_name.split('.')[-1]
      if ext == file_name or ext.include? '/' or ext.include? '\\'
        ''
      else
        ext
      end
    end
    
    def file_name_without_extension
      file_name[0..-(2 + file_name_extension.length)]
    end

    # Check if file is browser supported image
    def is_image?
      (mime_major == 'image') and %w(png gif jpeg).include? mime_minor
    end

    def mime_type
      "#{mime_major}/#{mime_minor}"
    end
    
    # Get file name (with path prefix) for resized version of image. 
    # It can be used only on image files
    # If resized thumbnail is not generated yet, it will be created.
    # Size is supposed to be in format <width>x<height>. If one is missing,
    # image will be resized to preserve aspect ratio.
    def resized_file_name(size)
      if self.mime_major != 'image'
        raise RuntimeError.new("Only image attachments can be resized. This is #{mime_type}")
      end
      r_width, r_height = size.split('x')
      
      if r_width.to_s.empty? and not r_height.to_s.empty?
        r_width = (r_height.to_f * self.image_width / self.image_height).to_i
      elsif r_height.to_s.empty? and not r_width.to_s.empty?
        r_height = (r_width.to_f * self.image_height / self.image_width).to_i
      elsif r_height.to_s.empty? and r_width.to_s.empty?
        return file_name
      end
      
      resized_file_name = "#{resized_path_prefix}/#{file_name_without_extension}/#{r_width}x#{r_height}"
      if not file_name_extension.empty?
        resized_file_name += ".#{file_name_extension}"
      end
      resized_file_path = "#{file_folder_disk_path}/#{resized_file_name}"

      if ( not File.exists? resized_file_path ) and File.exists? file_disk_path
        FileUtils.mkdir_p(File.dirname(resized_file_path))
        mm = MiniMagick::Image.from_file(file_disk_path)
        mm.resize(size)
        mm.quality('85%')
        mm.write(resized_file_path)
        FileUtils.chmod ModelExtensions::HasFile.resized_file_mode, resized_file_path
      end
      
      resized_file_name
    end
    

    protected

    def file_folder_relative_to_public
      File.join(ModelExtensions::HasFile::BASE_FOLDER_NAME, site.name, self.class.files_folder)
    end

    def file_folder_disk_path
      File.join(self.class.public_path, file_folder_relative_to_public)
    end
    
    def file_disk_path
      File.join(file_folder_disk_path, self.file_name)
    end
    
    # Resized images path prefix relative to master files folder
    def resized_path_prefix
      "_resized"
    end
    
    def resized_folder_disk_path
      "#{file_folder_disk_path}/#{resized_path_prefix}"
    end
    
    def update_file_meta
      if @uploaded_file
        if not self.file_name
          if @uploaded_file.respond_to? :original_filename
            self.file_name = @uploaded_file.original_filename
          else
            self.file_name = File.basename(@uploaded_file.path)
          end
        end
        @uploaded_data = @uploaded_file.read
        self.size = @uploaded_data.size
        mtype = MimeFinder.instance.mime_type(file_name)
        mmajor, mminor = mtype.split('/')
        self.mime_major ||= mmajor
        self.mime_minor ||= mminor
        if mime_major == 'image'
          update_image_meta           
        end
      end
    end
    
    # Update image only meta data
    def update_image_meta
      if @uploaded_data
        image = MiniMagick::Image.from_blob(@uploaded_data)
        self.image_width = image[:width]
        self.image_height = image[:height]
      end
    end
    
    def write_file
      if @uploaded_data
        FileUtils.mkdir_p(File.dirname(file_disk_path))
        File.open(file_disk_path, "wb") do |f|
          f.write(@uploaded_data)
        end
      end
    end
    
    def delete_file
      if self.class.count(:conditions => {'file_name' => file_name}) <= 1
        FileUtils.rm_f(file_disk_path)
        FileUtils.rm_rf("#{resized_folder_disk_path}/#{file_name_without_extension}")
      end
    end
    
  end
  
end
