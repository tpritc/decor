class ApplicationMailer < ActionMailer::Base
  default from: email_address_with_name("decor@tpritc.com", "Decor")
  layout "mailer"
  default template_path: -> { "mailers/#{self.class.name.underscore}" }
end
