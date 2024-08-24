class Openai::ChangeController < ApplicationController
  skip_before_action :require_login

    def ask_question; end
    
    def generate_recipe
        client = OpenAI::Client.new
        @question = params[:question]
        @material = params[:material]

        if @question.blank?
          flash[:danger] = "レシピの分量を入力してください"
          redirect_to openai_ask_question_path and return
        end
      
        if @material.blank?
          flash.now[:danger] = "変換材料を入力してください"
          render :ask_question and return
        end  
        response = client.chat(
          parameters: {
            model: "gpt-3.5-turbo",
            messages: [
                { role: "system", content: "#{@material}を使用しないレシピを教えてください" },
                { role: "user", content: @question }
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
      
      if @recipe_content.present?
        @materials, @creation_steps = parse_recipe(@recipe_content)
        
        if @materials.blank? || @creation_steps.blank?
          flash[:danger] = "生成"
          redirect_to openai_ask_question_path and return
        end

        @materials = (@materials || "").split("\n").reject(&:empty?)
        @creation_steps = (@creation_steps || "").split("\n").reject(&:empty?)

        if current_user
          redirect_to new_recipe_path(
            materials: @materials.join("\n"),
            process: @creation_steps.join("\n")
          )
        else
          redirect_to openai_show_recipe_path(
            materials: @materials.join("\n"),
            process: @creation_steps.join("\n")
          )
        end
      else
        flash[:danger] = t("defaults.flash_message.generation_failed")
        redirect_to openai_ask_question_path
      end
    end
                                  
    private

    def parse_recipe(recipe_content)
      # 正規表現を修正してラベルを適切に処理
      materials_match = recipe_content.match(/材料[:ー\s]*([\s\S]*?)(?=\n{2,}|作り方[:ー\s]*|$)/)
      creation_steps_match = recipe_content.match(/作り方[:ー\s]*([\s\S]*)/)
    
      # ラベルや余分な部分を削除
      materials = materials_match ? materials_match[1].strip.gsub(/^[:ー\s]*\n?/, "") : ""
      creation_steps = creation_steps_match ? creation_steps_match[1].strip.gsub(/^[:ー\s]*\n?/, "") : ""
    
      [materials.split("\n").reject(&:empty?), creation_steps.split("\n").reject(&:empty?)]
    end
  end
