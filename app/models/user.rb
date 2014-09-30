class User < ActiveRecord::Base
  has_many :posts
  has_many :comments
  has_one :email_addr

  has_secure_password validations: false

  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, on: :create, length: {minimum: 6}

  def putsposts
  	posts.each do |p|
  		p.printme
  	end
  end
end
