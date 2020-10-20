# frozen_string_literal: true

class BulkNoticeWorker
  include Sidekiq::Worker

  def perform(hbx_id)
    i = rand(1..20)
    raise StandardError if i > 15
    sleep(rand(1..30))
    Rails.logger.info("Processed #{hbx_id}")
  end
end