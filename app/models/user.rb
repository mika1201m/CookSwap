class User < ApplicationRecord
  authenticates_with_sorcery!
  enum gender: { male: 0, female: 1}
end
