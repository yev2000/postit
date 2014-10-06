class User < ActiveRecord::Base
  include Sluggable
  
  has_many :posts
  has_many :comments
  has_many :votes
  has_one :email_addr

  has_secure_password validations: false

  validates :username, presence: true, uniqueness: true, length: {minimum: 3}
  validates :password, presence: true, on: :create, length: {minimum: 6}

  def admin?
    self.role == "admin" || self.role == "superadmin"
  end

  def superadmin?
    self.role == "superadmin"
  end

  def moderator?
    self.role == "moderator"
  end

  def get_field_for_slugging
    self.username
  end

  def putsposts
  	posts.each do |p|
  		p.printme
  	end
  end
end
