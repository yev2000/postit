class CommentsController < ApplicationController

	def create
				
		begin
			@post = Post.find(params[:post_id])
		rescue ActiveRecord::RecordNotFound
			flash[:notice] = "Could not find post with ID #{:post_id}"
			redirect_to posts_path
		end

		@comment = @post.comments.build(comment_params)
		
		### at some point we have to hook up to the right user
		@comment.creator = User.first

		
		if @comment.save
			flash[:notice] = "Your comment was saved."
			redirect_to post_path(@post)
		else
			# we want to render the same page we came in from
			# and since we only allow creation of comments from the
			# show specific post page, that's posts/show
			render "posts/show"
		end
	end

	private

	def comment_params
		params.require(:comment).permit(:body)
	end

end
