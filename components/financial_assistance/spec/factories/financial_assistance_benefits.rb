FactoryBot.define do
  factory :benefit do

    association :applicant

    title 'DUMMY_TITLE	'
    insurance_kind "medicare_part_b"
    kind "is_eligible"
  end
end
