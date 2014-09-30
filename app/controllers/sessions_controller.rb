class SessionsController < ApplicationController

	def new
		@login_username = nil
	end

	def create
		# here is where we authenticate the user
		u = User.find_by(username: params[:username]) if params[:username]

		if (u && u.authenticate(params[:password]))
			# the user was found so set the current user to this and
			# create the session
			session[:userid] = u.id

			flash[:notice] = "User #{u.username} logged in!"

			# try to go where the user was originally going before they
			# hit the authentication challenge
			redirect_to_original_action
		else
			# create errors
			flash[:error] = "Invalid username or password"
			@login_username = params[:username]

			# do we need to redirect or just re-render a new?
			# if we render :new we can preserve the last username typed in
			render :new
		end

	end

	def destroy
		session[:userid] = nil
		current_user_clear
		redirect_to root_path
	end

end
