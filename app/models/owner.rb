class Owner < ApplicationRecord
  has_secure_password

  has_many :computers, dependent: :destroy
  has_many :components, dependent: :destroy

  PASSWORD_RESET_EXPIRY = 2.hours

  enum :real_name_visibility, { public: "public", members_only: "members_only", private: "private" }, prefix: true
  enum :country_visibility, { public: "public", members_only: "members_only", private: "private" }, prefix: true
  enum :email_visibility, { public: "public", members_only: "members_only", private: "private" }, prefix: true

  validates :user_name, presence: true, uniqueness: { case_sensitive: false }
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :country, inclusion: { in: ISO3166::Country.codes }, allow_blank: true
  validates :website, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }, allow_blank: true

  def country_name
    ISO3166::Country[country]&.common_name || ISO3166::Country[country]&.name
  end

  def self.countries_for_select
    ISO3166::Country.all.map { |c| [ c.common_name || c.name, c.alpha2 ] }.sort_by(&:first)
  end

  def generate_password_reset_token!
    update!(
      reset_password_token: SecureRandom.urlsafe_base64,
      reset_password_sent_at: Time.current
    )
  end

  def password_reset_expired?
    reset_password_sent_at.nil? || reset_password_sent_at < PASSWORD_RESET_EXPIRY.ago
  end

  def clear_password_reset_token!
    update!(reset_password_token: nil, reset_password_sent_at: nil)
  end
end
