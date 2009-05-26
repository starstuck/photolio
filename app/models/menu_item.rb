class MenuItem < ActiveRecord::Base

  belongs_to :menu
  belongs_to :target, :polymorphic => true

  validates_presence_of :menu
  validates_presence_of :target
  validates_length_of :label, :maximum => 255, :allow_nil => true
  validates_numericality_of :position

  def label_or_target_title
    @label_or_target_title ||= (label || target.title)
  end

end
