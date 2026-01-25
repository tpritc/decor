class ApplicationMailer < ActionMailer::Base
  default from: email_address_with_name("admin@decorweb.net", "Decor")
  layout "mailer"
  default template_path: -> { "mailers/#{self.class.name.underscore}" }
end
