class Category < ActiveRecord::Base
	has_many :post_categories
	has_many :posts, through: :post_categories

	def putsposts
		posts.each do |p|
			puts "post " + '#' + "#{p.id}: #{p.title}"
		end
	end
end
