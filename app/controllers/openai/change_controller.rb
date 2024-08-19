class Openai::ChangeController < ApplicationController
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
    end
end
