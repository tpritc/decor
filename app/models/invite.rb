class Invite < ApplicationRecord
  EXPIRY = 30.days

  validates :email, presence: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP },
                    uniqueness: { conditions: -> { where(accepted_at: nil) } }
  validates :token, presence: true, uniqueness: true

  before_validation :generate_token, on: :create
  before_validation :set_sent_at, on: :create

  scope :pending, -> { where(accepted_at: nil) }
  scope :accepted, -> { where.not(accepted_at: nil) }
  scope :expired, -> { pending.where("sent_at < ?", EXPIRY.ago) }
  scope :valid_invites, -> { pending.where("sent_at >= ?", EXPIRY.ago) }

  def expired?
    accepted_at.nil? && sent_at < EXPIRY.ago
  end

  def accepted?
    accepted_at.present?
  end

  def accept!
    update!(accepted_at: Time.current)
  end

  private

  def generate_token
    self.token ||= SecureRandom.urlsafe_base64(32)
  end

  def set_sent_at
    self.sent_at ||= Time.current
  end
end
