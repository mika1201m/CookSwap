class Recipe < ApplicationRecord
  validates :title, presence: true, length: { maximum: 50 }
  validates :process, presence: true
  enum genre: { japanese: 0, chinese: 1, western: 2, sweets: 3, other: 4}
  enum release: { in: 0, out: 1}

  has_many :recipe_materials, dependent: :destroy
  has_many :materials, through: :recipe_materials
  belongs_to :user

  def self.ransackable_associations(auth_object = nil)
    ["materials", "recipe_materials", "user"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["title", "materials.name"]
  end
end
