class BulkNoticeWorker
    include Sidekiq::Worker

    def perform(hbx_id)
        sleep(rand(1..20))
        Rails.logger.info("Processed #{hbx_id}")
    end
end