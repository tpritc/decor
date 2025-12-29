class RunStatus < ApplicationRecord
  has_many :computers, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
end
