class GalleryImage < ActiveRecord::Base
  attr_accessible :description, :image

  image_accessor :image
  has_resizable_image_on :image
  belongs_to :development

  before_create :preposition
  after_destroy :compact_others_to_current_position
  before_validation :set_default_description

  def position_to(new_position)
    set = development.gallery_images
    set.update_all 'position = position-1', ['position > ?', position]
    set.update_all 'position = position+1', ['position >= ? AND id<>?', new_position, id]
    update_attribute :position, new_position
  end


  def preposition # head
    development.gallery_images.update_all 'position = position+1'
  end


  def compact_others_to_current_position
    development.gallery_images.update_all 'position = position-1', ['position > ?', position]
  end

  def set_default_description
    self.description = self.image.try(:name) if description.blank?
  end

end
