require 'spec_helper'

# For model specs
RSpec.shared_examples "a recurring compliance event" do
  describe "occurrence" do
    before do
      # Set @owner_class_factory in the described class
      fail "@owner_class instance variable required" unless defined? @owner_class

      # Set @unchangeable_attributes in the described class
      fail "@unchangeable_attributes instance variable required" unless defined? @unchangeable_attributes
    
      @owner_class_factory = @owner_class.name.underscore.to_sym
      @described_class_factory = described_class.name.underscore.to_sym
    end

    # The described class should verify the implementation
    it "defines a #editable_occurrence_attributes method that returns an array" do
      compliance = create @described_class_factory
      expect {
        compliance.editable_occurrence_attributes
      }.not_to raise_error
      expect(compliance.editable_occurrence_attributes).to be_an Array
    end
  
    # The described class should verify the implementation
    it "defines a #is_recurring? method that returns true when the instance is recurring" do
      compliance = create @described_class_factory
      expect {
        compliance.is_recurring?
      }.not_to raise_error
      expect(compliance.is_recurring?).to be_falsey
      
      compliance = create @described_class_factory, :recurring
      expect(compliance.is_recurring?).to be_truthy
    end

    # The described class should verify the implementation
    it "does not allow modifying anything other than attributes returned by editable_occurrence_attributes" do
      compliance = create @described_class_factory, :recurring
      
      @unchangeable_attributes.each do |unchangeable_attribute|
        compliance[unchangeable_attribute] = "My New Value"
      end
      
      expect(compliance).to receive(:editable_occurrence_attributes)
      
      # Could be false for other reasons, but this is enough for this test
      expect(compliance.valid?).to be_falsey
    end

    it "does not allow destruction of the record" do
      compliance = create @described_class_factory, :recurring
      expect {
        compliance.destroy
      }.not_to change(described_class, :count)
      expect(compliance.errors).not_to be_empty

      compliance.valid? # Clear errors array, reload alone is not sufficient
      compliance.update_attribute @owner_class_factory, nil
      expect {
        compliance.destroy
      }.to change(described_class, :count).by(-1)
    end
  end
end
