module Admin
  class BulkNotice
    include Mongoid::Document
    include Mongoid::Timestamps

    field :user_id, type: String
    field :audience_type, type: String
    field :audience_identifiers, type: Array
    field :subject, type: String
    field :body, type: String

    embeds_many :results, class_name: "Admin::BulkNoticeResult"
  end
end