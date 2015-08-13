require 'spec_helper'

RSpec.shared_examples "a controller that accepts nested attributes for a document association" do
  describe "with nested document association attributes" do
    before do
      # Set @owner in the described class
      fail "@owner instance variable required" unless defined? @owner
      
      @described_class_factory = described_class.name.gsub(/Controller\z/, '').singularize.underscore.to_sym
      @owner_factory = @owner.class.name.underscore.to_sym
      @example = create @described_class_factory, @owner_factory => @owner
    end
    
    describe "PUT #update" do
      context "with valid params" do
        before do
          @document_association = create :document_association, document: create(:document, documentable: @owner), associable: @example
        end
        
        it "updates document associations" do
          new_document = create :document, documentable: @owner
          expect {
            put :update, {:id => @example.to_param, @described_class_factory => valid_attributes.merge({
              document_associations_attributes: [
                @document_association.attributes.merge({document_id: new_document.id})
              ]
            }), "#{@owner_factory}_id" => @owner.to_param}
          }.to change{ @document_association.reload.document_id }.to(new_document.id)
        end
      
        it "allows new document associations to be added" do
          expect {
            put :update, {:id => @example.to_param, @described_class_factory => valid_attributes.merge({
              document_associations_attributes: [
                { document_id: create(:document, documentable: @owner) }
              ]
            }), "#{@owner_factory}_id" => @owner.to_param}
          }.to change(DocumentAssociation, :count).by(1)
        end
      
        it "allows document associations to be destroyed" do
          expect {
            put :update, {:id => @example.to_param, @described_class_factory => valid_attributes.merge({
              document_associations_attributes: [
                @document_association.attributes.merge({:_destroy => "1"})
              ]
            }), "#{@owner_factory}_id" => @owner.to_param}
          }.to change(DocumentAssociation, :count).by(-1)
        end
      end
    end

    describe "POST #create" do
      context "with valid params" do
        it "creates new document associations" do
          expect {
            post :create, {@described_class_factory => valid_attributes.merge({
              document_associations_attributes: [
                { document_id: create(:document, documentable: @owner) }
              ]
            }), "#{@owner_factory}_id" => @owner.to_param}
          }.to change(DocumentAssociation, :count).by(1)
        end
      
        it "rejects document associations with blank document ids" do
          expect {
            post :create, {@described_class_factory => valid_attributes.merge({
              document_associations_attributes: [
                { document_id: create(:document, documentable: @owner) },
                { document_id: nil }
              ]
            }), "#{@owner_factory}_id" => @owner.to_param}
          }.to change(DocumentAssociation, :count).by(1)
        end
      end
    end
  end
end
