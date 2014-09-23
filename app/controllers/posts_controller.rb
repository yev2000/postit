class PostsController < ApplicationController

  before_action :set_post, only: [:show, :edit, :update]

  def index
  	@posts = Post.all
  end

  def show
  	# this is handled by before_action to set post instance var
    if @post.nil?
      redirect_to posts_path
    end
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    
    # set the user ID of the post to be the poster...
    # who is the user?
    # TBD : there is no user specified right now so we just use the first user
    @post.creator = User.first

    if @post.save
      flash[:notice] = "Your post was saved."
      redirect_to posts_path
    else
      render :new
    end
  end

  def edit
    # setting @post this is handled by before_action to set post instance var

    # however we can check to see if the post is valid or not in case someone
    # manually entered a URL with an invalid post ID.
    if @post.nil?
      redirect_to posts_path
    end
  end

  def update
    if @post.update(post_params)
      flash[:notice] = "The post \"#{@post.title}\" was updated."
      redirect_to post_path(@post)
    else
      render :edit
    end
  end
  
  private

    def post_params
      params.require(:post).permit(:url, :title, :description)
    end

    def set_post
      begin
        @post = Post.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        @post = nil
        flash[:notice] = "There is no post with ID #{params[:id]}.  Showing all posts instead."
      end
    end

end
