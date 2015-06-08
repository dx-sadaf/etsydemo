class Category < ActiveRecord::Base

  has_attached_file :image, :default_url => "default.jpg"
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/
  validates_attachment_presence :image

  has_many :listings
end
