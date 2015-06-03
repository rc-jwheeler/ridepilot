
ActionMailer::Base.smtp_settings = {
  :address              => Rails.application.secrets.smtp_mailer_address,
  :port                 => Rails.application.secrets.smtp_mailer_port,
  :domain               => Rails.application.secrets.smtp_mailer_domain,
  :user_name            => Rails.application.secrets.smtp_mailer_user_name,
  :password             => Rails.application.secrets.smtp_mailer_password,
  :authentication       => 'plain',
  :enable_starttls_auto => 'true'
}
