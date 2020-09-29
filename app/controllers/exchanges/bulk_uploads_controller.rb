# frozen_string_literal: true

module Exchanges
  class BulkUploadsController < ApplicationController

    def index
    end


    def enqueue
      # Fake Enqueue
      Organization.all.collect{|e| e.hbx_id}.each do |hbx_id|
        BulkNoticeWorker.perform_async(hbx_id)
      end
      render action: "index"
    end

    private
  end
end