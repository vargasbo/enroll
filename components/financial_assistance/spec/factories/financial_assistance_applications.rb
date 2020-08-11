FactoryBot.define do
  factory(:financial_assistance_application, :class => ::FinancialAssistance::Application) do
    family
    assistance_year TimeKeeper.date_of_record.year
    submitted_at {2.months.ago}
    aasm_state "determined"

    trait :with_applicants do
      applicants { family.family_members.map{|family_member| FactoryBot.build(:financial_assistance_applicant, application: self, family_member_id: family_member.id) }}
    end
  end
end