class User < ActiveRecord::Base
  include Sluggable
  
  has_many :posts
  has_many :comments
  has_many :votes
  has_one :email_addr

  has_secure_password validations: false

  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, on: :create, length: {minimum: 6}

  def get_field_for_slugging
    self.username
  end

  def putsposts
  	posts.each do |p|
  		p.printme
  	end
  end
end
