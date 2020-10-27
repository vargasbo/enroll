# frozen_string_literal: true

module Exchanges
  class BulkNoticesController < ApplicationController
    layout 'bootstrap_4'

    before_action :unread_messages
    before_action :set_current_user

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
      session[:bulk_notice] = nil
      @entities = BenefitSponsors::Organizations::Organization.all_profiles.to_json
      @bulk_notice = Admin::BulkNotice.new
    end

    def create
      @bulk_notice = Admin::BulkNotice.new(user_id: current_user)

      if @bulk_notice.update_attributes(bulk_notice_params)
        @bulk_notice.upload_document(params[:document], current_user)
        redirect_to exchanges_bulk_notice_path(@bulk_notice)
      else
        render 'new'
      end
    end

    def update
      @bulk_notice = Admin::BulkNotice.find(params[:id])
      if @bulk_notice.update_attributes(bulk_notice_params)
        @bulk_notice.process!
        redirect_to exchanges_bulk_notice_path(@bulk_notice)
      else
        render 'new'
      end
    end

    private

    def bulk_notice_params
      params[:admin_bulk_notice][:audience_identifiers] = params[:admin_bulk_notice][:audience_identifiers].split(" ")
      params.require(:admin_bulk_notice).permit!
    end

    def unread_messages
      profile = current_user.person.try(:hbx_staff_role).try(:hbx_profile)
      @unread_messages = profile.inbox.unread_messages.try(:count) || 0
    end
  end
end