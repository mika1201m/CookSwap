class Material < ApplicationRecord
    validates :name, presence: true, length: { maximum: 50 }, uniqueness: true
    
    has_many :recipe_materials
    has_many :recipes, through: :recipe_materials
end
