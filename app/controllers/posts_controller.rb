class PostsController < ApplicationController

  before_action :set_post, only: [:show, :edit, :update]

  def index
  	@posts = Post.all
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
    
    ### set the user ID of the post to be the poster...
    ### who is the user?
    ### TBD : there is no user specified right now so we just use the first user
    @post.creator = User.first

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


  def search
    # used to search for users

    @sort_options_array = [["Title" , 1], ["Number of Comments", 2]]

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
      ## here we are looking for any users matching the search expression   
      Post.all.each do |p|
        if p.creator && p.creator.username.match(params[:uname])
          if @with_comments_val == "1"
            if p.comments.length > 0
              @search_results << p
            end
          else
            @search_results << p
          end
        end
      end

      # now if there are "with comments text" search specified, we
      # iterate over the search results and REMOVE any posts where
      # no comments matching are found
      comment_text_to_find = params[:with_comment_text]
      if comment_text_to_find && comment_text_to_find.length > 0
        @search_results.delete_if do |p|
          mark_for_delete = true
          
          p.comments.each do |c|
            if c.body.include? comment_text_to_find
              mark_for_delete = false
              break
            end
          end

          mark_for_delete
        end
      end

      # now have to consider how to sort
      
      case @sort_options_array.rassoc(@sorting_val)[0]
      when "Title"
        @search_results.sort! { |x,y| x.title <=> y.title }
      when "Number of Comments"
        @search_results.sort! { |x,y| y.comments.length <=> x.comments.length }
      end
    end
  end
  
  private

    def post_params
      params.require(:post).permit(:url, :title, :description, category_ids: [])
    end

    def set_post
      begin
        @post = Post.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        flash[:notice] = "There is no post with ID #{params[:id]}.  Showing all posts instead."
        redirect_to posts_path
      end
    end

end
