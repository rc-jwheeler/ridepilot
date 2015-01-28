class User < ActiveRecord::Base
  has_many   :roles
  belongs_to :current_provider, :class_name=>"Provider", :foreign_key => :current_provider_id
  has_one    :driver
  has_one    :device_pool_driver, :through => :driver
  
  validates :password, :confirmation => true
  validates :email, :uniqueness => true
  
  # Let Devise handle the length requirement.
  validates_format_of :password, :if => :password_required?,
            :with => /^(?=.*[0-9])(?=.*[\W])(?=.*[a-zA-Z])(.*)$/,
            :message => "must have at least one number and at least one " +
                        "non-alphanumeric character"
  
  # Include default devise modules. Others available are:
  # :rememberable, :token_authenticatable, :confirmable, :lockable
  devise :database_authenticatable, :recoverable, :trackable, :validatable, 
    :timeoutable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation

  model_stamper
  
  before_create do
    self.email.downcase! if self.email
  end
  
  def self.drivers(provider)
    Driver.where(:provider_id => provider.id).map(&:user)
  end
  
  def self.find_for_authentication(conditions) 
    conditions[:email].downcase! 
    super(conditions) 
  end
  
  # Generate a password that will validate properly for User
  def self.generate_password(length = 8)
    # Filter commonly confused characters
    charset = (('a'..'z').to_a + ('A'..'Z').to_a) - %w(i I l o O)
    result = (1..length).collect{|a| charset[rand(charset.size)]}.join
    # Pick two indices to replace with number and symbol
    indices = (0..length-1).to_a
    n = indices.sample
    m = (indices - [n]).sample
    # At least one number
    result[n] = '23456789'.chars.to_a.sample
    # At least one special character
    result[m] = '@#$%^&*()'.chars.to_a.sample
    return result
  end

  def update_password(params)
    unless params[:password].blank?
      self.update_with_password(params)
    else
      self.errors.add('password', :blank)
      false
    end
  end
  
  def admin?
    roles.where(:provider_id => current_provider).first.admin?
  end
  
  def editor?
    roles.where(:provider_id => current_provider).first.editor?
  end
end
