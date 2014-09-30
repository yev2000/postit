class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user_get, :logged_in?, :get_logged_in_user_id

  def current_user_get
  	@current_user ||= User.find(session[:userid]) if session[:userid]
  end

  def logged_in?
  	!!(current_user_get)
  end

  def get_logged_in_user_id
    if (@current_user)
      @current_user.id
    else
      nil
    end
  end

  def current_user_clear
  	@current_user = nil
  end

  def redirect_to_original_action

    if session[:prior_url]
      redirect_to session[:prior_url]
    else
      redirect_to root_path
    end
  end


  def require_user
    if !logged_in?
		  flash[:error] = "must be logged in to do this"

      ## is there a way to know what the current path is, so
      ## that once we've logged in we can redirect to there?
      ## after having been redirecte to the login?
      session[:prior_url] = request.get? ? request.path : nil
      
		  redirect_to login_path
    else
      session[:prior_url] = nil
    end
  end

end
