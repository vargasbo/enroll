# frozen_string_literal: true

class BulkNoticeReflex < ApplicationReflex
  # Add Reflex methods in this file.
  #
  # All Reflex instances expose the following properties:
  #
  #   - connection - the ActionCable connection
  #   - channel - the ActionCable channel
  #   - request - an ActionDispatch::Request proxy for the socket connection
  #   - session - the ActionDispatch::Session store for the current visitor
  #   - url - the URL of the page that triggered the reflex
  #   - element - a Hash like object that represents the HTML element that triggered the reflex
  #   - params - parameters from the element's closest form (if any)
  #
  # Example:
  #
  #   def example(argument=true)
  #     # Your logic here...
  #     # Any declared instance variables will be made available to the Rails controller and view.
  #   end
  #
  # Learn more at: https://docs.stimulusreflex.com
  def new_identifier
    session[:bulk_notice] ||= { audience: {} }
    params[:admin_bulk_notice][:audience_ids] ||= []

    identifiers = element[:value]
    org_badges = identifiers.split(/ |, |,/).reduce('') do |badges, identifier|
      organization = BenefitSponsors::Organizations::Organization.where(fein: identifier).first ||
                     BenefitSponsors::Organizations::Organization.where(hbx_id: identifier).first
      if organization
        if session[:bulk_notice][:audience].key?(organization.id.to_s) && params[:admin_bulk_notice][:audience_ids].include?(organization.id.to_s)
          badges
        else
          session[:bulk_notice][:audience][organization.id.to_s] = { id: organization.id,
                                                                     legal_name: organization.legal_name,
                                                                     fein: organization.fein,
                                                                     hbx_id: organization.hbx_id }
                                                                     # types: organization.profile_types }
          badges + ApplicationController.render(partial: "exchanges/bulk_notices/recipient_badge", locals: { id: organization.id, legal_name: organization.legal_name })
        end
      elsif params[:admin_bulk_notice][:audience_ids].include?(identifier)
        badges
      else
        session[:bulk_notice][:audience][identifier] = { id: identifier, error: 'Not found' }
        badges + ApplicationController.render(partial: "exchanges/bulk_notices/recipient_error_badge", locals: { id: identifier, error: 'Not found', legal_name: nil })
      end
    end

    org_badges = params[:admin_bulk_notice][:audience_ids].reduce(org_badges) do |badges, org_id|
      org_attrs = session[:bulk_notice][:audience][org_id]
      if org_attrs.key?(:error)
        badges + ApplicationController.render(partial: "exchanges/bulk_notices/recipient_error_badge", locals: { id: org_id, error: org_attrs[:error], legal_name: org_attrs[:legal_name] })
      else
        badges + ApplicationController.render(partial: "exchanges/bulk_notices/recipient_badge", locals: { id: org_id, legal_name: org_attrs[:legal_name] })
      end
    end

    morph '#recipient-list', org_badges
  end
end
