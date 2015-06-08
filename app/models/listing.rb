class Listing < ActiveRecord::Base
  has_attached_file :image, :styles => { :medium => "250x", :thumb => "75x75>", :show => "x350" }, :default_url => "default.jpg"
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/


  validates :name, :description,:category_id, :price, presence: true
  validates :price, numericality: { greater_than: 0 }
  validates_attachment_presence :image

  belongs_to :user
  has_many :orders
  belongs_to :category
  has_many :reviews


  def average_rating
    if reviews.blank?
      0
    else
      reviews.average(:rating).round(2)
    end
  end

end
