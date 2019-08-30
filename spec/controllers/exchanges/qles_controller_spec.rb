# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Exchanges::QlesController, :type => :controller do
  render_views
  # Note: Value is '' when choosing 'not_applicable' reason and action kind
  # Always make sure this is up to date by submitting the form once and grabbing the
  # params with binding.pry and params["data"]
  let(:qle_creation_params) do
    {
      "data" => {
        "title" => "Got a New Dog",
        "tool_tip" => "New Pet",
        "action_kind" => "",
        "reason" => "",
        "market_kind" => "shop",
        "is_self_attested" => "Yes",
        "visible_to_customer" => "Yes",
        "effective_on_kinds" => ["date_of_event"],
        "questions" => [
          {
            "content" => "Did you move to DC recently?",
            "responses" => [
              {
                "content" => "I'm not sure",
                "action_to_take" => "declined"
              },
              {
                "content" => "Yes",
                "action_to_take" => "accepted"
              }
            ]
          }
        ],
        "pre_event_sep_in_days" => 10,
        "post_event_sep_in_days" => 10,
        "start_on" => "10/20/2030",
        "end_on" => "10/20/2040"
      }
    }
  end
  let(:qle_edit_params) do

  end
  let(:invalid_qle_creation_params) do
    qle_creation_params["data"].delete('title')
    qle_creation_params
  end
  let(:deactivate_existing_qle_params) do
    {
      "data" =>
      {
        "_id" => existing_qle.id,
        "end_on" => "06/01/2030"
      }
    }
  end
  let(:invalid_deactivate_existing_qle_params) do
    {
      "data" =>
      {
        "_id" => existing_qle.id,
        "end_on"=> nil
      }
    }
  end
  let(:existing_qle) do
    FactoryBot.create(
      :qualifying_life_event_kind,
      end_on: nil,
      title: "Got a New Dog",
      tool_tip: "Household has a dog for no reason"
    )
  end

  let(:user) do
    double(
      "user",
      :has_hbx_staff_role? => true,
      :has_employer_staff_role? => false,
      :needs_to_provide_security_questions? => true
    )
  end
  let(:person) { double("person")}
  let(:hbx_staff_role) { double("hbx_staff_role", permission: permission) }
  let(:hbx_profile) { double("HbxProfile")}
  let(:permission) do
    double(
      can_add_custom_qle: true,
      can_access_outstanding_verification_sub_tab: true,
      access_new_consumer_application_sub_tab: true,
      can_access_new_consumer_application_sub_tab: true,
      can_access_identity_verification_sub_tab: true,
      can_complete_resident_application: true,
      can_access_user_account_tab: true,
      view_admin_tabs: true,
      view_the_configuration_tab: true
    )
  end

  before :each do
    allow(user).to receive(:has_role?).with(:hbx_staff).and_return true
    allow(user).to receive(:person).and_return(person)
    allow(person).to receive(:hbx_staff_role).and_return(hbx_staff_role)
    allow(hbx_staff_role).to receive(:hbx_profile).and_return(hbx_profile)
    sign_in(user)
  end

  # TODO: Test edit and update methods
  describe "GET #new" do
    it "successfully renders the new page" do
      get :new
      expect(response.status).to eq(200)
    end
  end

  describe "POST #create" do
    before do
      QualifyingLifeEventKind.delete_all
    end

    context "valid input" do
      it "successfully creates record" do
        expect(QualifyingLifeEventKind.count).to eq(0)
        post(:create, as: 'json', params: qle_creation_params)
        expect(QualifyingLifeEventKind.count).to eq(1)
        expect(flash['notice']).to eq('Successfully created Qualifying Life Event Kind.')
        # Creates questions and responses
        qle_kind = QualifyingLifeEventKind.where(title: 'Got a New Dog').first
        expect(qle_kind.custom_qle_questions.count).to eq(1)
        expect(qle_kind.custom_qle_questions.first.custom_qle_responses.count).to eq(2)
      end
    end

    context "invalid input" do
      it "fails to create record and throws error" do
        expect(QualifyingLifeEventKind.count).to eq(0)
        post(:create, as: 'json', params: invalid_qle_creation_params)
        expect(flash['error']).to eq('Unable to create Qualifying Life Event Kind.')
      end
    end
  end

  describe "POST #deactivate" do
    context "valid input" do
      it "successfully deactivates record" do
        put(
          :deactivate,
          xhr: true,
          params: {
            id: existing_qle.id,
            data: deactivate_existing_qle_params
          }
        )
        # Flash notices not visible in rspec for some reason
        # expect(flash['notice']).to eq('Successfully deactivated QualifyingLifeEventKind.')
        expect(response.status).to eq(204)
        expect(response.location).to eq(manage_exchanges_qles_path)
      end
    end
    context "invalid input" do
      it "fails to deactivate record and throws error" do
        put(
          :deactivate,
          xhr: true,
          params: {
            id: existing_qle.id,
            data: invalid_deactivate_existing_qle_params
          }
        )
        expect(flash['error']).to eq('Unable to deactivate Qualifying Life Event Kind.')
        expect(response.status).to eq(204)
        expect(response.location).to eq(manage_exchanges_qles_path)
      end
    end
  end

  describe "GET #manage" do
    it "successfully renders manage action" do
      get :manage
      expect(response.status).to eq(200)
    end
  end

  describe "POST #question_flow" do
    it "succesfully redirects to question flow get" do
      post(:question_flow, params: { id: existing_qle, market_kind: 'shop' })
      expect(response.status).to eq(302)
      attrs = { market_kind: 'shop' }
      expect(response).to redirect_to(question_flow_exchanges_qle_path(existing_qle, attrs))
    end
  end

  describe "GET #question_flow" do

  end
end