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
    
      @materials = (@materials || "").split("\n").reject(&:empty?)
      @creation_steps = (@creation_steps || "").split("\n").reject(&:empty?)

      Rails.logger.debug "Materials: #{@materials.inspect}"
      Rails.logger.debug "Creation Steps: #{@creation_steps.inspect}"

      redirect_to new_recipe_path(
        materials: @materials.join("\n"),
        process: @creation_steps.join("\n")
      )
    end
                              
    private

    def parse_recipe(recipe_content)
      # 材料セクションと作り方セクションを抽出
      materials_match = recipe_content.match(/材料[:ー\s]*([\s\S]*?)(?=\n{2,}|作り方[:ー\s]*)/m)
      creation_steps_match = recipe_content.match(/作り方[:ー\s]*([\s\S]*)/m)
      
      # 各セクションのテキストを抽出
      materials = materials_match ? materials_match[1] : ""
      creation_steps = creation_steps_match ? creation_steps_match[1] : ""
    
      # 改行コードを統一し、空行を削除
      materials = materials.gsub(/\R/, "\n").split("\n").reject(&:empty?)
      creation_steps = creation_steps.gsub(/\R/, "\n").split("\n").reject(&:empty?)
    
      # デバッグ用ログ出力
      Rails.logger.debug "Extracted materials: #{materials.inspect}"
      Rails.logger.debug "Extracted creation steps: #{creation_steps.inspect}"
    
      return materials, creation_steps
    end
end
