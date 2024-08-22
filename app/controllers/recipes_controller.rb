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
      save_materials(@recipe)
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

  def destroy
    recipe = current_user.recipes.find(params[:id])
    recipe.destroy!
    redirect_to recipes_path, success: t('defaults.flash_message.deleted', item: Recipe.model_name.human), status: :see_other
  end

  private
  def recipe_params
    params.require(:recipe).permit(:title, :process, :genre, :release, :gender, :created_at)
  end

  def save_materials(recipe)
    materials_list = parse_materials(params[:materials])
    existing_materials, new_materials = categorize_materials(materials_list)
    
    Rails.logger.debug "Parsed materials: #{materials_list.inspect}"
    Rails.logger.debug "Existing materials: #{existing_materials.inspect}"
    Rails.logger.debug "New materials: #{new_materials.inspect}"
    
    new_material_ids = save_new_materials(new_materials)
    create_recipe_materials(recipe, existing_materials.merge(new_material_ids.index_by { |m| m[:id] }))
  end
  
  def parse_materials(materials_text)
    materials_text.split("\n").map do |line|
      line.gsub(/[-：]/, '').strip
    end.reject(&:empty?)
  end

  def categorize_materials(materials_list)
    existing_materials = {}
    new_materials = []
  
    materials_list.each do |material|
      material_name = divide_material_names([material]).first
      volume, scale = divide_volume_and_scale(material)
  
      next unless material_name.present?
  
      if (existing_material = Material.find_by(name: material_name.strip))
        existing_materials[existing_material.id] = { volume: volume, scale: scale }
      else
        new_materials << { name: material_name, volume: volume, scale: scale }
      end
    end
  
    [existing_materials, new_materials]
  end
  
  def save_new_materials(new_materials)
    new_material_ids = []
  
    new_materials.each do |material_data|
      new_material = Material.create(name: material_data[:name])
      new_material_ids << { id: new_material.id, volume: material_data[:volume], scale: material_data[:scale] }
    end
  
    new_material_ids
  end

  def create_recipe_materials(recipe, materials)
    materials.each do |material_id, attributes|
      Rails.logger.debug "Creating RecipeMaterial: recipe_id=#{recipe.id}, material_id=#{material_id}, volume=#{attributes[:volume]}, scale=#{attributes[:scale]}"
      RecipeMaterial.create(
        recipe_id: recipe.id,
        material_id: material_id,
        volume: attributes[:volume],
        scale: attributes[:scale]
      )
    end
  end
  
  def divide_material_names(materials)
    materials.map do |material|
      match = material.match(/^(?<name>[^0-9]+)\s*(?<volume>\d+)?\s*(?<unit>\w+)?$/)
      match ? match[:name].strip : material
    end
  end
  
  def divide_volume_and_scale(material)
    if material =~ /(\d+)\s*(\D+)$/
      volume = $1
      scale = $2.strip
    else
      volume = nil
      scale = nil
    end
    [volume, scale]
  end
  
end
