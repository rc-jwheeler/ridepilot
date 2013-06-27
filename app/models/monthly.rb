class Monthly < ActiveRecord::Base
  belongs_to :provider

  validates_presence_of :provider
  validates_datetime :start_date
  validates_numericality_of :volunteer_escort_hours, :greater_than_or_equal_to => 0, :allow_blank => true
  validates_numericality_of :volunteer_admin_hours, :greater_than_or_equal_to => 0, :allow_blank => true
  validates_uniqueness_of :start_date, :scope => :provider_id

  stampable :creator_attribute => :created_by_id, :updater_attribute => :updated_by_id
end
