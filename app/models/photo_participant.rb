class PhotoParticipant < ActiveRecord::Base

  belongs_to :photo

  validates_presence_of :photo
  validates_length_of :role, :maximum => 255, :allow_blank => false 
  validates_length_of :name, :maximum => 255, :allow_blank => false 

end
