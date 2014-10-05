class Category < ActiveRecord::Base
	include Sluggable

  has_many :post_categories
	has_many :posts, through: :post_categories

	validates :name, presence: true, uniqueness: true

  def get_field_for_slugging
    self.name
  end

	def putsposts
		posts.each do |p|
			puts "post " + '#' + "#{p.id}: #{p.title}"
		end
	end
end
