module RunsHelper
  def reimbursement_cost(run)
    number_to_currency ReimbursementRateCalculator.new(run.provider).reimbursement_due_for_run(run)
  end
end