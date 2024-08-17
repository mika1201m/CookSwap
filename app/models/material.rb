class Material < ApplicationRecord
    validates :name, presence: true, length: { maximum: 50 }
    
    has_many :recipe_materials
end
