class RecipeMaterial < ApplicationRecord
    validates :volume, presence: true
    validates :scale, presence: true, length: { maximum: 10 }

    belongs_to :material
    belongs_to :recipe
end
