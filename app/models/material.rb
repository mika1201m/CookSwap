class Material < ApplicationRecord
    validates :name, presence: true, length: { maximum: 50 }, uniqueness: true
    
    has_many :recipe_materials
    has_many :recipes, through: :recipe_materials

    def self.ransackable_attributes(auth_object = nil)
        ["name"]
      end
end
