class PostsController < ApplicationController

  before_action :set_post, only: [:show, :edit, :update]

  def index
  	@posts = Post.all
  end

  def show
    # setting @post this is handled by before_action to set the post instance var

    ### IS THIS CORRECT ???
    ### Do we create a blank comment that will
    ### be picked up for new comment creation?
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
