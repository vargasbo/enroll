# frozen_string_literal: true

class BulkNoticeWorker
  include Sidekiq::Worker

  def perform(audience_id, bulk_notice_id)
    # Call Operations here!
    bulk_notice = Admin::BulkNotice.find(bulk_notice_id)
    @org = BenefitSponsors::Organizations::Organization.find(audience_id)

    send(bulk_notice.audience_type.to_sym) do |audience_member|
      # Deliver message here
      bulk_notice.results.create(
        audience_member_identifier: audience_member.id,
        audience_id: audience_id,
        result: "OK!"
      )
    end

    Rails.logger.info("Processing #{id} for Bulk Notice request #{bulk_notice_id}")
  end

  def employees
    @org.employees.each do |employee|
      yield employee
    end
  end

  def employers
    @org.staff.each do |staff|
      yield staff
    end
  end

  def broker_agencies
    @org.staff.each do |staff|
      yield staff
    end
  end

  def general_agencies
    @org.staff.each do |staff|
      yield staff
    end
  end

  # def perform(hbx_id)
  #   i = rand(1..20)
  #   raise StandardError if i > 15
  #   sleep(rand(1..30))
  #   Rails.logger.info("Processed #{hbx_id}")
  # end
end