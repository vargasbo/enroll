	FactoryBot.define do
	  factory :deduction do
	  association :applicant
	  title 'Test'
    amount 10
    frequency_kind 'monthly'
    start_on Date.today.beginning_of_month
    end_on Date.today.end_of_month
	  end
	end
