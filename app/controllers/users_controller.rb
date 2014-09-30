class UsersController < ApplicationController
	before_action :set_user, only: [:edit, :posts, :show, :update]
	before_action :require_logged_in_user, only: [:edit, :update]

	def new
		@user = User.new
	end

	def create
	    @user = User.new(user_params)
    
	    if @user.save
	      flash[:notice] = "Your user #{@user.username} was created."

	      # this is a bit of a hack, but we redirect to the posts index rather than a (nonexistent)
	      # users index.


	      # if we want to log the user in, we simply create
	      # a session for the user implicitly.
	      session[:userid] = @user.id

	      redirect_to posts_path
	    else
	      render :new
	    end
	end

	def edit
	end

	def update
		# if password was supplied, then set it
		form_values = params.require(:user)
		if form_values
			if form_values[:password] && form_values[:password].length > 0
				@user.password = form_values[:password]
			end

			# if username was changed, try to set it
			if form_values[:username] && form_values[:username].length > 0
				@user.username = form_values[:username]
			end
		end

		# (will validations make sure duplicate username is not set?)
		if @user.save
      		flash[:notice] = "The user \"#{@user.username}\" was updated."
      		redirect_to root_path
    	else
      		render :edit
      	end
    	
	end

	def show
	end

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
			# here we are looking for any users matching the search expression		

			# The original approach used User.all.each to iterate over all of the users.
      		# But this is very inefficient if the system has thousands of users since all
      		# will be read into memory.
      		# The more efficient approach pointed out by Brandon C. is to use
      		# matching_users = <class>.where("<field> LIKE #{params[:uname].gsub('*', '%').gsub('?', '_')}")
      		# and furthermore, to protect against SQL injection, it would be
      		# matching_posts = <class>.where("<field> LIKE ?", params[:uname].gsub('*', '%').gsub('?', '_'))
      		@search_results = User.where("username LIKE ?", params[:uname].gsub('*', '%').gsub('?', '_'))
      		
      		# If we are also looking for users with at least one post, we need to iterate over the search
      		# results and cull the resulting set by removing ones without any posts.
	      	if @with_posts_val == "1"
          		@search_results.delete_if do |u|
            		if u.posts.length > 0
              			false
              		else
            			true
              	    end # comments length
          		end #delete_if
        	end #comments_with_val == 1

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

    def user_params
      params.require(:user).permit(:username, :password)
    end

    def set_current_user
    	@user = current_user_get
    end

    def set_user
      begin
        @user = User.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        flash[:notice] = "There is no user with ID #{params[:id]}.  Showing user search instead." 
        redirect_to search_users_path
      end
    end

    def require_logged_in_user
		if @user != current_user_get
			flash[:error] = "You cannot edit a different user's profile"
			redirect_to root_path
		end
    end

end

