class CommentsController < ApplicationController

	def create
				
		begin
			@post = Post.find(params[:post_id])
		rescue ActiveRecord::RecordNotFound
			redirect_to posts_path
		end

		@comment = @post.comments.build(comment_params)

		## at some point we have to hook up to the right user
		
		if @comment.save
			flash[:notice] = "Your comment was saved."
			## tricky to render the post form because it has to be for the specific post
			redirect_to post_path(@post)
		else
			## want to render the same page we were on...
			## render posts_path
			render "posts/show"
		end
	end

	private

	def comment_params
		params.require(:comment).permit(:body)
	end

end
