class AttachmentSlot < ActiveRecord::Base

  class Definition
    attr_reader :name, :valid_types
    def initialize(name, options={})
      @name = name
      @valid_types ||= options[:valid_types]
    end

    # Test if attachment validates to definition
    def valid_attachment?(attachment_object)

      if @valid_types
        for type in @valid_types
          if type.is_a? Class 
            type_class = type
          elsif type.is_a? String
            type_name = type.gsub(/[^a-zA-Z0-9_\/]+/, '')
            begin
              type_class = eval(type_name)
            rescue
              raise ValueError.new("Unable to parse definition: #{type}")
            end
          else
            raise ValueError.new("Invalid attachment type definition: #{type}")
          end
          if attachment_object.is_a? type_class
            return true
          end
        end
        return false
      end

      return true
    end
  end

  belongs_to :having_attachment, :polymorphic => true
  belongs_to :attachment, :polymorphic => true

  validates_presence_of :having_attachment
  validates_presence_of :attachment
  validates_presence_of :name
  validates_length_of :name, :maximum => 32

  def definition
    @definition ||= having_attachment.site.site_params.attachment_slots(
      having_attachment)[name]
  end

  protected

  def validate
    unless definition and definition.valid_attachment? attachment
      errors.add("name", "Attachment slot is not defined")
    end
  end

end
