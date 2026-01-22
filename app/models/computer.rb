class Computer < ApplicationRecord
  belongs_to :owner
  belongs_to :computer_model
  belongs_to :condition, optional: true
  belongs_to :run_status, optional: true
  has_many :components, dependent: :nullify
end
