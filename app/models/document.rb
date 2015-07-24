class Document < ActiveRecord::Base
  belongs_to :documentable, polymorphic: true
  
  has_attached_file :document, :default_url => "/images/:style/missing.png"
  
  validates :documentable, presence: true, associated: true
  
  validates_attachment :document, presence: true,
    content_type: { :content_type => [
      "image/jpeg", "image/gif", "image/png", # image files (.png, .gif, .jpg)
      "text/plain",                           # plain text files (.txt)
      "application/pdf",                      # PDF (.pdf)
      
      # MS Excel (.xls, .xlsx)
      "application/vnd.ms-excel", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
      
      # MS Word (.doc, .docx)
      "application/msword", "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    ]},
    :size => { :in => 0..2.gigabytes }
end
