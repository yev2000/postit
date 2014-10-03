class User < ActiveRecord::Base
  include Slugger
  
  has_many :posts
  has_many :comments
  has_many :votes
  has_one :email_addr

  has_secure_password validations: false

  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, on: :create, length: {minimum: 6}

  after_validation :generate_slug

  def generate_slug
    # if we want to have slugs that never change
    # we would do ||= so that once the slug is non-nil, it will never get updated.
    # In our case here, we always recompute.
    # there is a problem with this approach is that we may end up
    # changing the slug suffix number unnecessarily.
    # this is because the title may have changed by a special character
    # which would map to the original slug text.  So we need to figure that out.
    self.slug = compute_slug(self, self.username)
  end

  def to_param
    # we override default behavior to allow for string-based slugs
    # rather than the primary key (ID) of the post
    if self.slug == nil
      # we have not yet had a chance to construct the slug string, so
      # construct it now and save the post
      self.slug = compute_slug(self, self.username)
      self.save
    end

    # now return the slug, because ultimately to_param is looking to get back
    # the URL component for this instance, which will be the slug
    self.slug
  end

  def putsposts
  	posts.each do |p|
  		p.printme
  	end
  end
end
