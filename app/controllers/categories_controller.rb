class CategoriesController < ApplicationController

	before_action :set_category, only: [:show, :edit, :update]
	before_action :require_user, except: [:index, :show]
	before_action :require_admin, only: [:new, :edit, :create]

	def show
    respond_to do |format|
	    format.html { }   

	    format.json { 
	        render :json => @category.to_json(:except => [:id, :created_at, :updated_at])
      }
    end

	end

	def index
    respond_to do |format|
	    format.html { }   

	    format.json { 
	        render :json => Category.all.to_json(:except => [:id, :created_at, :updated_at])
      }
    end
	end

	def new
		@category = Category.new
	end

	def create
		@category = Category.new(category_params)

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
		@category = Category.find_by(slug: params[:id])
		if @category.nil? 
			flash[:notice] = "There is no category with ID #{params[:id]}.  Showing all posts instead."
			redirect_to posts_path
		end
	end
end
