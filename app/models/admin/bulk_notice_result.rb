module Admin
  class BulkNoticeResult
    include Mongoid::Document
    include Mongoid::Timestamps

    field :audience_identifier, type: String
    field :result, type: String

    embedded_in :bulk_notice
  end
end
