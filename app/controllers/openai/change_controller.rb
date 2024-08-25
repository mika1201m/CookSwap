class Openai::ChangeController < ApplicationController
  skip_before_action :require_login

    def ask_question; end
    
    def generate_recipe
        client = OpenAI::Client.new
        @question = params[:question]
        @material = params[:material]
        @target = params[:target]

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
            model: "gpt-4o-mini",
            messages: [
                { role: "system", content: "#{@material}を使用しない#{@target}のレシピを教えてください。
                                          以下の形式で回答してください。
                                              【材料】
                                              ・材料名: 分量 単位
                                                例: 豆乳 300cc

                                              【作り方】
                                              1. 手順1
                                              2. 手順2
                                                例: 1. 鍋に豆乳を入れ、中火にかける。 2. 砂糖と片栗粉を加える。"},
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
      
      Rails.logger.debug "Received parameters: #{params.inspect}"# 入力される内容を確認
    
      if @recipe_content.present?
        @materials, @creation_steps = parse_recipe(@recipe_content)
    
        Rails.logger.info("Parsed Materials: #{@materials}")
        Rails.logger.info("Parsed Creation Steps: #{@creation_steps}")
        
        if @materials.blank? || @creation_steps.blank?
          flash[:danger] = "生成"
          redirect_to openai_ask_question_path and return
        end
    
        materials_text = @materials.join("\n")
        steps_text = @creation_steps.join("\n")
    
        Rails.logger.info("Materials Text for Redirect: #{materials_text}")
        Rails.logger.info("Process Text for Redirect: #{steps_text}")
    
        if current_user
          redirect_to new_recipe_path(materials: materials_text, process: steps_text)
        else
          render :show_recipe
        end
      else
        flash[:danger] = t("defaults.flash_message.generation_failed")
        redirect_to openai_ask_question_path
      end
    end
                                      
    private

    def parse_recipe(recipe_content)
      # 正規表現パターンを定義
      materials_pattern = /【材料】\s*((?:・.*(?:\n|$))*)\n*\s*(?=【作り方】|$)/
      creation_steps_pattern = /【作り方】\s*([\s\S]*)/
      
      # 材料の部分を抽出
      materials_match = recipe_content.match(materials_pattern)
      materials = materials_match ? materials_match[1].strip : ""
      Rails.logger.info("Extracted Materials: #{materials.inspect}")
      
      # 作り方の部分を抽出
      creation_steps_match = recipe_content.match(creation_steps_pattern)
      creation_steps = creation_steps_match ? creation_steps_match[1].strip : ""
      Rails.logger.info("Extracted Creation Steps: #{creation_steps.inspect}")
      
      # 分割し、空行を削除
      parsed_materials = materials.split(/\n+/).map(&:strip).reject(&:empty?)
      parsed_creation_steps = creation_steps.split(/\n+/).map(&:strip).reject(&:empty?)
      
      [parsed_materials, parsed_creation_steps]
    end
                                      end
