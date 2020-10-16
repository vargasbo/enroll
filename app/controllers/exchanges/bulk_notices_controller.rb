# frozen_string_literal: true

module Exchanges
  class BulkNoticesController < ApplicationController
    layout 'bootstrap_4'

    def index
      @bulk_notices = Admin::BulkNotice.all
    end

    def show
      @bulk_notice = Admin::BulkNotice.find(params[:id])

      if @bulk_notice.aasm_state == 'draft'
        render 'preview'
      else
        render 'summary'
      end
    end

    def new
      @bulk_notice = Admin::BulkNotice.new
    end

    def create
      @bulk_notice = Admin::BulkNotice.new(user_id: current_user)

      if @bulk_notice.update_attributes(bulk_notice_params)
        redirect_to exchanges_bulk_notice_path(@bulk_notice)
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