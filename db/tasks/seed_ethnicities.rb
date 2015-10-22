ETHNICITIES = ['Caucasian','African American','Asian','Asian Indian','Chinese','Filipino','Hispanic','Japanese','Korean','Vietnamese','Pacific Islander','American Indian/Alaska Native','Native Hawaiian','Guamanian or Chamorrow','Samoan','Russian','Unknown','Refused','Other']

ETHNICITIES.each do |name|
  Ethnicity.find_or_create_by!(:name => name)
end