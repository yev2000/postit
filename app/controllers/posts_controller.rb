class PostsController < ApplicationController

  # map of permissions needed for actions
  #          set_post                     require_user                  require creator user or admin
  #          (@post must be existing)      (a user must be logged in)    (current user must be creator of post or admin)
  # index           -                          -                               -
  # show            X                          -                               -
  # new             -                          X                               -
  # create          -                          X                               -
  # edit            X                          *                               X
  # update          X                          *                               X
  # vote            X                          X                               -
  # search          -                          -
  #
  # * - technically we can just ask for creator or admin
  #     but advantage of also calling require_user is that we use
  #     shared code to flash the right message about needing to be
  #     logged in and also being able to redirect to prior view.                               -

  before_action :set_post, only: [:show, :edit, :update, :vote]
  before_action :require_user, only: [:new, :create, :vote, :edit, :update]
  before_action :require_creator_or_admin, only: [:edit, :update]

  def index
    # if there is no query parameter to display all posts,
    # just show the top N of the posts
    if (params[:show_all] == "true")
    	@posts = Post.all
    else
      # query from the database just a subset and the
      # view partial will also need to offer a link
      # to show the remainder
      upvotes_hash = Post.joins(:votes).where("voteable_type = 'Post' AND vote = 't'").group("voteable_id").count
      downvotes_hash = Post.joins(:votes).where("voteable_type = 'Post' AND vote = 'f'").group("voteable_id").count      

      # now that we have the counts, iterate over the keys in each and get the top vote-getters.

      # first get the union of keys
      union_of_keys = (upvotes_hash.keys + downvotes_hash.keys).uniq

      # now iterate and create a new hash of the post ID that maps to score
      score_hash = {}
      union_of_keys.each do |k|
        if upvotes_hash[k]
          score_hash[k] = upvotes_hash[k]
        else
          score_hash[k] = 0
        end

        if downvotes_hash[k]
          score_hash[k] -= downvotes_hash[k]
        end
      end

      posts_indices = []

      # iterate over the score hash and try to insert the posts in order by vote score
      score_hash.each do |key, value|
        if posts_indices.size == 0
          posts_indices[0] = [key, value]
        else
          inserted = false
          posts_indices.each_index do |posts_index|
            if value > posts_indices[posts_index][1]
              posts_indices.insert(posts_index, [key, value])
              inserted = true
              break;
            end
          end

          if inserted == false
            posts_indices << [key, value]
          end
        end # if not first element being iterated on
      end # iteration over all elements of hash

      # now create post instance array with top N

      @posts = []
      posts_indices[0..9].each do |entry|
        @posts << Post.find(entry[0])
      end

      ## problem is that there could be a bunch of posts that
      ## did not receive any votes.  In that case, there are no
      ## entries in the up and down votes hash, yet the
      ## posts are legitimate to be added to the list.  So
      ## what do we do?
      if @posts.size < union_of_keys.size
        @post_list_truncated = true
      end

      ## at this point we still don't know if we are missing some

    end
  end

  def show
    # setting @post this is handled by before_action to set the post instance var

    # we create a new comment instance variable here because it's needed
    # by the show posts page (the new comment form) and the comments controller create logic.
    @comment = Comment.new
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    
    # set the user ID of the post to be the logged in user
    @post.creator = current_user_get

    if @post.save
      flash[:notice] = "Your post was saved."
      redirect_to posts_path
    else
      render :new
    end
  end

  def edit
    # setting @post this is handled by before_action to set the post instance var
  end

  def update
    if @post.update(post_params)
      flash[:notice] = "The post \"#{@post.title}\" was updated."
      redirect_to post_path(@post)
    else
      render :edit
    end
  end

  def vote

    # as part of recording the vote, we will update the
    # DOM in place.  So we need to specify what ID we
    # will be updating.  We can construct it
    record_vote(@post, current_user_get, params[:vote], "post_#{@post.slug}_votes")

  end


  def search
    # used to search for users

    @sort_options_array = [["Title" , 1], ["Number of Comments", 2], ["Post timestamp", 3], ["Vote Score", 4]]

    @search_results = []
    
    if params[:sorting]
      @sorting_val = params[:sorting].to_i
    else
      @sorting_val = (@sort_options_array[0])[1].to_i
    end


    if params[:with_comments]
      @with_comments_val = params[:with_comments]
    else
      @with_comments_val = "0"
    end

  if params[:uname]
      # here we are looking for any users matching the search expression   
      # The original approach used Post.all.each to iterate over all of the posts.
      # But this is very inefficient if the system has millions of posts since all
      # will be read into memory.
      # The more efficient approach pointed out by Brandon C. is to use
      # matching_posts = <class>.where("<field> LIKE #{params[:uname].gsub('*', '%').gsub('?', '_')}")
      # and furthermore, to protect against SQL injection, it would be
      # matching_posts = <class>.where("<field> LIKE ?", params[:uname].gsub('*', '%').gsub('?', '_'))

      comment_text_to_find = params[:with_comment_text]
      if comment_text_to_find && comment_text_to_find.length > 0
        # here we wrap the comment searches with %'s so that it becomes a wildcard search
        # that works with the SQL "LIKE" search.  Note this is different than what we do
        # with the users search because in users field, we expect user has already put in
        # wildcards.
        comment_search_string = "%" + comment_text_to_find + "%"
      else
        # otherwise, we know that we're not searching for any comment search.
        comment_search_string = nil
      end

      if (comment_search_string)
        @search_results = Post.joins(:creator,:comments).where("users.username LIKE ? AND comments.body LIKE ?", 
          params[:uname].gsub('*', '%').gsub('?', '_'), comment_search_string).distinct
      else
        @search_results = Post.joins(:creator).where("users.username LIKE ?", params[:uname].gsub('*', '%').gsub('?', '_'))
        if @with_comments_val == "1"
          @search_results.delete_if do |p|
            if p.comments.length > 0
              false
            else
              true
            end # comments length
          end #delete_if
        end #comments_with_val == 1
      end #else of comment_search_string

      # now have to consider how to sort
      
      case @sort_options_array.rassoc(@sorting_val)[0]
      when "Title"
        @search_results.sort! { |x,y| x.title <=> y.title }
      when "Number of Comments"
        @search_results.sort! { |x,y| y.comments.length <=> x.comments.length }
      when "Post timestamp"
        @search_results.sort! { |x,y| y.created_at <=> x.created_at }
      when "Vote Score"
        @search_results.sort! { |x,y| y.total_vote_score <=> x.total_vote_score }
      end
    end
  end

  private

  def post_params
    params.require(:post).permit(:url, :title, :description, category_ids: [])
  end

  def set_post
    @post = Post.find_by(slug: params[:id])
    if @post.nil? 
      flash[:notice] = "There is no post with ID #{params[:id]}.  Showing post search page instead."
      redirect_to search_posts_path
    end
  end

  def require_creator_or_admin
    access_denied(post_path (@post), "You cannot edit a different user's post") unless allow_object_edit?(@post)
  end
  
end
