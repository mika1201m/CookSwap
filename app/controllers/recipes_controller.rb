class RecipesController < ApplicationController
  skip_before_action :require_login, only: %i[index show]

  def index
    @q = Recipe.ransack(params[:q])
    @recipes = @q.result(distinct: true).where(release: Recipe.releases[:in]).includes(:user).order(created_at: :desc)
  end

  def create_index
    @recipes = current_user.recipes
  end

  def show
    @recipe = Recipe.find(params[:id])
  end

  def new
    @recipe = Recipe.new
    @recipe.process = params[:process] if params[:process]
    @materials = params[:materials].to_s.split("\n") if params[:materials]
  end
    
  def create
    Rails.logger.debug "Params creation_steps: #{params[:creation_steps].inspect}"
    @recipe = current_user.recipes.new(recipe_params)
    @recipe.process = params[:process] if params[:process].present?  # @creation_stepsを結合してprocessに保存
    if @recipe.save
      redirect_to recipes_path
      flash[:success] = t('defaults.flash_message.created', item: Recipe.model_name.human)
    else
      Rails.logger.debug "Recipe failed to save due to the following errors:"
    Rails.logger.debug @recipe.errors.full_messages.to_s
    Rails.logger.debug "Recipe params: #{recipe_params.inspect}"
      flash.now[:danger] = t('defaults.flash_message.not_created', item: Recipe.model_name.human)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @recipe = current_user.recipes.find(params[:id])
  end

  def update
    @recipe = current_user.recipes.find(params[:id])
    if @recipe.update(recipe_params)
      redirect_to recipes_path(@recipe), success: t('defaults.flash_message.updated', item: Recipe.model_name.human)
    else
      flash.now[:danger] = t('defaults.flash_message.not_updated', item: Recipe.model_name.human)
      render :edit, status: :unprocessable_entity
    end
  end

  def delete
    recipe = current_user.recipes.find(params[:id])
    recipe.delete!
    redirect_to recipes_path, success: t('defaults.flash_message.deleted', item: Recipe.model_name.human), status: :see_other
  end

  private
  def recipe_params
    params.require(:recipe).permit(:title, :process, :genre, :release, :gender, :created_at)
  end

  def save_materials(recipe)
    materials_list = params[:materials].split("\n").reject(&:empty?)
    materials_list.each do |material|
      material_name = divide_material_names([material]).first
      volume, scale = divide_volume_and_scale(material)
  
      if material_name.present?
        material_record = Material.find_or_create_by(name: material_name)
        RecipeMaterial.create(
          recipe_id: recipe.id,
          material_id: material_record.id,
          volume: volume,
          scale: scale
        )
      end
    end
  end

end
