class CategoriesController < ApplicationController

	before_action :set_category, only: [:show, :edit, :update]

	def show
		if @category.nil?
			## explicitly redirecting to posts path because we don't have a categories index yet
			redirect_to posts_path
    	end
	end

	def index
	end

	def new
		@category = Category.new
	end

	def create
		@category = Category.create(category_params)

		if @category.save
			flash[:notice] = "Your category (#{@category.name}) was saved."

			# we are explicitly redirecting to the posts listing rather than a category listing
			# can we be more sophisticated and know how we "got here" in order to determine
			# where we should redirect to?
			redirect_to posts_path
		else
			render :new
		end
	end

	def update
	end

	private

	def category_params
		params.require(:category).permit(:name)
	end

	def set_category
		begin
			@category = Category.find(params[:id])
		rescue ActiveRecord::RecordNotFound
			@post = nil
			flash[:notice] = "There is no category with ID #{params[:id]}.  Showing all categories instead."
		end
	end
end
