class Computer < ApplicationRecord
  belongs_to :owner
  belongs_to :computer_model
  belongs_to :condition
  belongs_to :run_status
  has_many :components, dependent: :nullify
end
