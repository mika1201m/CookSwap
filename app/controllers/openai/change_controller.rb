class Openai::ChangeController < ApplicationController
  skip_before_action :require_login

    def ask_question; end
    
    def generate_recipe
        client = OpenAI::Client.new
        material = params[:material]
        question = params[:question]
        response = client.chat(
          parameters: {
            model: "gpt-3.5-turbo",
            messages: [
                { role: "system", content: "#{material}を使用しないレシピを教えてください" },
                { role: "user", content: question }
            ],
          }
        )
        if response["choices"].present?
          @recipe_content = response.dig("choices", 0, "message", "content")
          redirect_to openai_show_recipe_path(recipe_content: @recipe_content)
        else
          flash[:error] = "Error: Unable to generate recipe."
          render :ask_question
        end
    end

    def show_recipe
      @recipe_content = params[:recipe_content]
      @materials, @creation_steps = parse_recipe(@recipe_content)
    
      @materials = @materials.split("\n").reject(&:empty?)
      @creation_steps = @creation_steps.split("\n").reject(&:empty?)
      # 材料の名前、分量、単位の処理
      @materials.each do |material|
        material_name = divide_material_names([material]).first
        volume, scale = divide_volume_and_scale(material)
    
        if material_name.present?
          material_record = Material.find_or_create_by(name: material_name)
          RecipeMaterial.create(
            material_id: material_record.id,
            volume: volume,
            scale: scale
          )
        end
      end
      # データをnew_recipe_pathに送るだけ
      redirect_to new_recipe_path(
        materials: @materials.join("\n"),
        process: @creation_steps.join("\n")
      )
    end
                              
    private

    def parse_recipe(recipe_content)
      materials_section = recipe_content[/材料:\s*([\s\S]*?)(?:\n\n|作り方:)/m, 1] || ""
      creation_steps_section = recipe_content[/作り方:\s*(.*)/m, 1] || ""
      Rails.logger.debug "Materials Section: #{materials_section}"
      Rails.logger.debug "Creation Steps Section: #{creation_steps_section}"
      
      [materials_section.strip, creation_steps_section.strip]
    end

    def divide_material_names(materials)
      materials.map do |material|
        # 数字と記号を取り除いて、材料名だけを抽出
        material.gsub(/\d+/, '').strip
      end
    end

    def divide_volume_and_scale(materials)
      if materials =~ /(\d+)\s*(\D+)/
        volume = $1
        scale = $2.strip
      else
        volume = nil
        scale = nil
      end
      [volume, scale]
    end

end
