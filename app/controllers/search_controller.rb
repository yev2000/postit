class SearchController < ApplicationController
	def user
		# used to search for users

		@sort_options_array = [["Name" , 1], ["Number of Posts", 2], ["Reverse Name", 3]]

		@search_results = []
		
		if params[:sorting]
			@sorting_val = params[:sorting].to_i
		else
			@sorting_val = (@sort_options_array[0])[1].to_i
		end


		if params[:with_posts]
			@with_posts_val = params[:with_posts]
		else
			@with_posts_val = "0"
		end

		if params[:uname]
			## here we are looking for any users matching the search expression		
			User.all.each do |u|
				if u.username.match(params[:uname])
					if @with_posts_val == "1"
						if u.posts.length > 0
							@search_results << u
						end
					else
						@search_results << u
					end
				end
			end

			# now have to consider how to sort
			
			case @sorting_val
			when 1
				@search_results.sort! { |x,y| x.username <=> y.username }
			when 2
				@search_results.sort! { |x,y| x.posts.length <=> y.posts.length }
			when 3
				@search_results.sort! { |x,y| y.username <=> x.username }
			end
		end

	end

	def post
		# used to search for posts
	end	
end

