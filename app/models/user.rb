class User < ApplicationRecord
  authenticates_with_sorcery!
  enum gender: { male: 0, female: 1}
  validates :password, length: { minimum: 3 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }
  validates :name, presence: true, length: { maximum: 30 }
  validates :email, presence: true, uniqueness: true

  has_many :recipes, dependent: :destroy

  def own?(object)
    id == object&.user_id
  end

end
