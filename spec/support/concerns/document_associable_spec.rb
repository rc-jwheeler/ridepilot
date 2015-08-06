require 'spec_helper'

# The concern assumes that the associable will be either a DriverHistory, 
# DriverCompliance, or (soon) some sort of vehicle event model, and thus that 
# the owner will be either a Driver or a Vehicle, so these tests make those 
# same assumptions.
RSpec.shared_examples "an associable for a document" do
  describe "document_associations" do
    before do
      # Set @owner in the described class
      fail "@owner instance variable required" unless defined? @owner
      
      described_class_factory = described_class.name.underscore.to_sym
      owner_factory = @owner.class.name.underscore.to_sym
      @example = create described_class_factory, owner_factory => @owner
    end
    
    it "has many document associations" do
      expect(described_class.reflect_on_association(:document_associations).macro).to  eq :has_many
    end
    
    it "destroys associated document associations when it is destroyed" do
      3.times { create :document_association, document: create(:document, documentable: @owner), associable: @example }
      expect {
        @example.reload.destroy
      }.to change(DocumentAssociation, :count).by(-3)
    end

    it "accepts nested document associations" do
      @example.document_associations_attributes = 3.times.collect { {document_id: create(:document, documentable: @owner).id} }
      expect {
        @example.save
      }.to change(DocumentAssociation, :count).by(3)
    end
    
    it "destroys associated document associations when the destroy attribute is present" do
      3.times { create :document_association, document: create(:document, documentable: @owner), associable: @example }
      expect(@example.document_associations.count).to eql 3
      
      @example.document_associations_attributes = @example.document_associations(true).collect { |association| association.attributes.merge({:_destroy => "1"}) }
      expect {
        @example.save
      }.to change(DocumentAssociation, :count).by(-3)
    end
    
    it "rejects new document associations with a blank document id" do
      @example.document_associations_attributes = [ { document_id: nil } ]
      expect {
        @example.save
      }.not_to change(DocumentAssociation, :count)
    end
    
    # Normally, validates_uniqueness_of with :scope only works on already 
    # persisted records. With accepts_nested_attributes_for, we could be adding
    # many new records at once, so we want to ensure that they are unique even
    # before they are saved
    it "does not allow duplicate nested document associations" do
      document = create :document, documentable: @owner
      @example.document_associations_attributes = 2.times.collect { {document_id: document.id} }
      expect {
        @example.save
      }.not_to change(DocumentAssociation, :count)
    end
  end
end
