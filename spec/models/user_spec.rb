require "rails_helper"

RSpec.describe User, type: :model do
  describe "role checks" do
    before(:each) do
      @user = create(:user)
      @editor = create(:editor)
      @admin = create(:admin)
      @super_admin = create(:super_admin)
    end
    
    it "reports editor capabilities" do
      expect(@user.editor?).to_not    be_truthy
      expect(@editor.editor?).to      be_truthy
      expect(@admin.editor?).to       be_truthy
      expect(@super_admin.editor?).to be_truthy
    end
    
    it "reports admin capabilities" do
      expect(@user.admin?).to_not    be_truthy
      expect(@editor.admin?).to_not  be_truthy
      expect(@admin.admin?).to       be_truthy
      expect(@super_admin.admin?).to be_truthy
    end
    
    it "reports super_admin capabilities" do
      expect(@user.super_admin?).to_not    be_truthy
      expect(@editor.super_admin?).to_not  be_truthy
      expect(@admin.super_admin?).to_not   be_truthy
      expect(@super_admin.super_admin?).to be_truthy
    end
  end
end
