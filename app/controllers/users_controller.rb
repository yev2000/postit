class UsersController < ApplicationController
	before_action :set_user, only: [:posts]

	def search
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
			
			case @sort_options_array.rassoc(@sorting_val)[0]
			when "Name"
				@search_results.sort! { |x,y| x.username <=> y.username }
			when "Number of Posts"
				@search_results.sort! { |x,y| y.posts.length <=> x.posts.length }
			when "Reverse Name"
				@search_results.sort! { |x,y| y.username <=> x.username }
			end
		end
	end

	def posts
		# list the posts which have been posted by a particular user
		@post_list = @user.posts
	end

	private

    def set_user
      begin
        @user = User.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        flash[:notice] = "There is no user with ID #{params[:id]}.  Showing user search instead." 
        redirect_to search_users_path
      end
    end
end

