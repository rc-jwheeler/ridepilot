class DocumentAssociation < ActiveRecord::Base
  belongs_to :document, inverse_of: :document_associations
  belongs_to :associable, polymorphic: true, inverse_of: :document_associations
  
  validates :document, presence: true, associated: true, uniqueness: {scope: [:associable_type, :associable_id]}
  validates :associable, presence: true
  validate  :ensure_same_owner

  private
  
  def ensure_same_owner
    if document.present? and associable.present?
      owner_class = document.documentable_type.underscore
      errors.add(:base, "Document and associable must belong to the same #{owner_class.humanize.downcase}") unless document.documentable == associable.send(owner_class)
    end
  end
end
