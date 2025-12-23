class Computer < ApplicationRecord
  CONDITIONS = {
    original: "Completely original",
    original_repaired: "Completely original with small repairs",
    modified: "Original with options replaced or removed",
    built: "Built from parts"
  }.freeze

  RUN_STATUSES = {
    unknown: "Unknown",
    working: "Working",
    working_problems: "Working with a few problems",
    repair: "Under repair",
    defective: "Defective"
  }.freeze

  belongs_to :owner
  belongs_to :computer_model
  has_many :components, dependent: :nullify

  enum :condition, CONDITIONS.keys.index_by(&:itself).transform_values(&:to_s)
  enum :run_status, RUN_STATUSES.keys.index_by(&:itself).transform_values(&:to_s)

  validates :condition, presence: true

  def condition_label
    CONDITIONS[condition.to_sym]
  end

  def run_status_label
    RUN_STATUSES[run_status.to_sym]
  end
end
