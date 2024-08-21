class RecipeMaterial < ApplicationRecord
    validates :volume, presence: true
    validates :scale, presence: true, length: { maximum: 10 }, uniqueness: true

    belongs_to :material
    belongs_to :recipe
end
