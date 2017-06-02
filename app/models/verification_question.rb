class VerificationQuestion < ActiveRecord::Base
  
  belongs_to :user
  
  # Returns true/false if the answer given matches the stored answer
  def correct?(guess)
    prep_for_comparison(guess) == prep_for_comparison(answer)
  end
  
  protected

  # Converts to lower case and removes whitespace for comparison  
  def prep_for_comparison(string)
    string.downcase.gsub(/\s+/, '')
  end
  
end
