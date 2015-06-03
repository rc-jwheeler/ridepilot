
ActionMailer::Base.smtp_settings = {
  :address              => Rails.application.secrets.stmp_mailer_address,
  :port                 => Rails.application.secrets.stmp_mailer_port,
  :domain               => Rails.application.secrets.stmp_mailer_domain,
  :user_name            => Rails.application.secrets.stmp_mailer_user_name,
  :password             => Rails.application.secrets.stmp_mailer_password,
  :authentication       => 'plain',
  :enable_starttls_auto => 'true'
}
