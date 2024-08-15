class RecipesController < ApplicationController
  skip_before_action :require_login, only: %i[new index show]
  def index
    @recipes = Recipe.includes(:user)
  end

  def show
    @recipe = Recipe.find(params[:id])
  end

  def new
    @recipe = Recipe.new
    @recipe.genre = nil
  end

  def create
    @recipe = current_user.recipes.new(recipe_params)
    if @recipe.save
      redirect_to recipes_path
      flash[:success] = t('defaults.flash_message.created', item: Recipe.model_name.human)
    else
      Rails.logger.info @recipe.errors.full_messages.join(", ")
      flash.now[:danger] = t('defaults.flash_message.not_created', item: Recipe.model_name.human)
      render :new, status: :unprocessable_entity
    end  
  end

  def edit
    @recipe = current_user.recipes.find(params[:id])
  end

  def update
    @recipe = current_user.boards.find(params[:id])
    if @recipe.update(recipe_params)
      redirect_to recipes_path(@recipe), success: t('defaults.flash_message.updated', item: Recipe.model_name.human)
    else
      flash.now[:danger] = t('defaults.flash_message.not_updated', item: Recipe.model_name.human)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    recipe = current_user.recipes.find(params[:id])
    recipe.destroy!
    redirect_to recipes_path, success: t('defaults.flash_message.deleted', item: Recipe.model_name.human), status: :see_other
  end

  private
  def recipe_params
    params.require(:recipe).permit(:title, :process, :genre, :release, :gender, :created_at)
  end

end
