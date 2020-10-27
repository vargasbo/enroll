# frozen_string_literal: true

class BulkNoticeWorker
  include Sidekiq::Worker
  def perform(audience_id, bulk_notice_id)
    bulk_notice = Admin::BulkNotice.find(bulk_notice_id)
    @org = BenefitSponsors::Organizations::Organization.find(audience_id)

    result = Operations::SecureMessageAction.new.call(
      params: { resource_id: @org.profiles.first.id.to_s,
      resource_name: 'BenefitSponsors::Organizations::Profile',
      subject: bulk_notice.subject,
      body: bulk_notice.body,
      actions_id: "Bulk Notice"
      document: bulk_notice.documents.first},
      user: User.first
    )
    if result.success?
      bulk_notice.results.create(
        audience_id: audience_id,
        result: "Success"
      )
    else
      bulk_notice.results.create(
        audience_id: audience_id,
        result: "Error"
      )
    end
    Rails.logger.info("Processing #{id} for Bulk Notice request #{bulk_notice_id}")
  end
end