class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user_get, :logged_in?, :total_vote_count_string, :total_vote_score, :record_vote

  ########################
  #
  # User Management
  #
  ########################

  def current_user_get
  	@current_user ||= User.find(session[:userid]) if session[:userid]
  end

  def logged_in?
  	!!(current_user_get)
  end

  def current_user_clear
  	@current_user = nil
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
      clear_original_action
    end
  end
  
  ########################
  #
  # Redirection
  #
  ########################

  def clear_original_action
    session[:prior_url] = nil
  end

  def redirect_to_original_action

    if session[:prior_url]
      redirect_to session[:prior_url]
    else
      redirect_to root_path
    end
  end

  ########################
  #
  # Vote management
  #
  ########################

  def record_vote(voteable_obj, creator_obj, up_or_down, dom_id_of_vote_text)
    v = Vote.create(voteable: voteable_obj, creator: creator_obj, vote: up_or_down)
    
    if v && v.valid?
      flash[:notice] = "Your vote was counted"
    else
      if (v && v.errors && v.errors.messages[:creator] &&
        (v.errors.messages[:creator].index { |msg| msg.include? "already been taken" }))
          flash[:error] = "You have already voted for this #{v.voteable_type}"
      else
        flash[:error] = "Your vote was not counted"
      end
    end

    respond_to do |format|
      format.html {    
        redirect_to :back
      }

      format.js { 
          @score_field = dom_id_of_vote_text
          @voteable_obj = voteable_obj 
      }
    end
  end

  def total_vote_count_string(obj)
    t = total_vote_count(obj) 
    "#{t}" + " vote".pluralize(t)
  end

  def total_vote_count(obj)
    up_vote_count(obj) + down_vote_count(obj)
  end

  def total_vote_score(obj)
    up_vote_count(obj) - down_vote_count(obj)
  end

  def up_vote_count(obj)
    obj.votes.where(vote: true).size
  end

  def down_vote_count(obj)
    obj.votes.where(vote: false).size
  end

end
