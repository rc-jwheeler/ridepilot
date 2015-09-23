[
  {
    code: 'veteran',
    description: 'Are you a military veteran?'
  },
  {
    code: 'disabled',
    description: 'Do you have a permanent or temporary disability?'
  }, 
  {
    code: 'low_income',
    description: 'Are you low income?'
  }, 
  {
    code: 'ada_eligible',
    description: 'Are you eligible for ADA paratransit?'
  }, 
  {
    code: 'nemt_eligible',
    description: 'Are you eligible for medicaid?'
  },
].each do |eligible_data|
  item = Eligibility.where(code: eligible_data[:code]).first_or_create
  item.update_attributes description: eligible_data[:description]
end