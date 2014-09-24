class Category < ActiveRecord::Base
	has_many :post_categories
	has_many :posts, through: :post_categories

	validates :name, presence: true, uniqueness: true
	
	def putsposts
		posts.each do |p|
			puts "post " + '#' + "#{p.id}: #{p.title}"
		end
	end
end
