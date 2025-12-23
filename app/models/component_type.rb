class ComponentType < ApplicationRecord
  has_many :components, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
end
