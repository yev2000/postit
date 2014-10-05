class Post < ActiveRecord::Base
  include Sluggable
  include Voteable

  belongs_to :creator, foreign_key: 'user_id', class_name: 'User'
  has_many :comments
  has_many :post_categories
  has_many :categories, through: :post_categories
  
  validates :title, presence: true, length: {minimum: 5}
  validates :url, presence: true, uniqueness: true
  validates :description, presence: true
  validates :creator, presence: true

  def get_field_for_slugging
    self.title
  end

  def printme
  	puts "Post " + '#' + "#{self.id}: #{self.title} @ #{self.url}"
  end
end
