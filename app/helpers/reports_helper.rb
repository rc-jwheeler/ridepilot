module ReportsHelper
  def reimbursement_rate(reimbursement_rate_attribute)
    if reimbursement_rate_attribute.present?
      number_to_currency(reimbursement_rate_attribute, :precesion => 2)
    else
      "*"
    end
  end

  def reimbursement_due(reimbursement_due, reimbursement_rate_attributes)
    if reimbursement_rate_attributes.nil? || Array(reimbursement_rate_attributes).select(&:nil?).count > 0
      "*"
    else
      number_to_currency(reimbursement_due, :precesion => 2)
    end
  end
end
