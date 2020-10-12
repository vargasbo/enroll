# frozen_string_literal: true

module Exchanges
  class BulkUploadsController < ApplicationController

    def index
    end

    def new
      @bulk_notice = Admin::BulkNotice.new
      render layout: 'bootstrap_4'
    end

    def create
      @bulk_notice = Admin::BulkNotice.new(user_id: current_user)

      if @bulk_notice.update_attributes(bulk_notice_params)
        redirect_to preview_exchanges_bulk_upload_path(@bulk_notice)
      else 
        render "new"
      end
    end

    def enqueue
      # Fake Enqueue
      Organization.all.collect{|e| e.hbx_id}.each do |hbx_id|
        BulkNoticeWorker.perform_async(hbx_id)
      end
      render action: "index"
    end

    private

    def bulk_notice_params
      params[:admin_bulk_notice][:audience_identifiers] = params[:admin_bulk_notice][:audience_identifiers].split(" ")
      params.require(:admin_bulk_notice).permit!
    end
  end
end