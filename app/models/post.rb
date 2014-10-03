class Post < ActiveRecord::Base
  belongs_to :creator, foreign_key: 'user_id', class_name: 'User'
  has_many :comments
  has_many :post_categories
  has_many :categories, through: :post_categories
  has_many :votes, as: :voteable
  
  validates :title, presence: true, length: {minimum: 5}
  validates :url, presence: true, uniqueness: true
  validates :description, presence: true
  validates :creator, presence: true
  after_validation :generate_slug

  def compute_slug
    retval = ""
        
    if title
      retval = self.title.gsub(/[^a-zA-Z0-9]/, "-")

      # we have to find if there already exists a slug with this name
      another_post = Post.find_by(slug: retval)
      if (another_post)
        search_str = retval + "(%)"
        max_suffix_found = 0
        search_results = Post.where("slug LIKE ?", search_str)
        search_results.each do |p|
          if p.slug
            last_parens_num = p.slug.match(/\([0-9]*\)$/).to_s.gsub('(', '').gsub(')','').to_i
          else
            last_parens_num = 0
          end

          if (last_parens_num && (max_suffix_found < last_parens_num))
            max_suffix_found = last_parens_num
          end
        end

        retval += "(#{max_suffix_found + 1})"
        return retval
      else
        return retval
      end
    else
      nil
    end
  end

  def generate_slug
    if self.slug == nil
      self.slug = self.compute_slug()
      
    end
  end

  def to_param
    # we override default behavior to allow for string-based slugs
    # rather than the primary key (ID) of the post
    if self.slug != nil
      self.slug
    else
      # we have not yet had a chance to construct the slug string, so
      # construct it now and save the post
      self.slug = self.compute_slug()
      
      self.save
    end

    self.slug

  end

  def printme
  	puts "Post " + '#' + "#{self.id}: #{self.title} @ #{self.url}"
  end
end
