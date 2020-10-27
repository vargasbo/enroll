FactoryBot.define do
  factory :bulk_notice, class: ::Admin::BulkNotice do
    user_id { "john@doe" }
    audience_type { "Employer" }
  end
end
