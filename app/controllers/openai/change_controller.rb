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
    
      # 材料と作り方を分割して配列に変換
      @materials = @materials.split("\n").reject(&:empty?)
      @creation_steps = @creation_steps.split("\n").reject(&:empty?)
    end
    
    private

    def parse_recipe(recipe_content)
        # 材料と作り方のセクションを分けるための正規表現
        materials_section = recipe_content[/【材料】(.+?)【作り方】/m, 1]
        creation_steps_section = recipe_content[/【作り方】(.+)/m, 1]

        materials_section ||= ""
        creation_steps_section ||= ""

        # 材料と作り方のセクションを返す
        [materials_section.strip, creation_steps_section.strip]
    end
end
