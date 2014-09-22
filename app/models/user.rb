class User < ActiveRecord::Base
  has_many :posts
  has_many :comments
  has_one :email_addr

  def putsposts
  	posts.each do |p|
  		p.printme
  	end
  end
end
