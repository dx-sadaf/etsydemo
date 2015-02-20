class Listing < ActiveRecord::Base
  has_attached_file :image, :styles => { :medium => "250x", :thumb => "175x175>" }, :default_url => "default.jpg"
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/
end
