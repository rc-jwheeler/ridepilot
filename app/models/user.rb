class User < ActiveRecord::Base
  
  has_many   :roles
  belongs_to :current_provider, :class_name=>"Provider", :foreign_key => :current_provider_id
  has_one    :driver
  has_one    :device_pool_driver, :through => :driver
  
  validates :password, :confirmation => true
  validates :email, :uniqueness => true
  
  # Let Devise handle the length requirement. Regexp tested at
  # http://www.rubular.com/r/ns7ftUQhFb
  validates_format_of :password, :if => :password_required?,
            :with => /^(?=.*[0-9])(?=.*[\W])(?=.*[a-zA-Z])(.*)$/,
            :message => "must have at least one number and at least one " +
                        "non-alphanumeric character"
  
  # Include default devise modules. Others available are:
  # :rememberable, :token_authenticatable, :confirmable, :lockable and
  # :timeoutable
  devise :database_authenticatable, 
         :recoverable, :trackable, :validatable

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
