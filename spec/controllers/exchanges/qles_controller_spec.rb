# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Exchanges::QlesController, :type => :controller do
  render_views
  let(:qle_creation_params) do
    {
      'data' =>
      {
        "title" => "Got a New Dog",
        "event_kind_label" => "Date of birth",
        "market_kind" => "shop",
        "effective_on_kinds" => ["date_of_event"],
        "tool_tip" => "Household adds a new dog for emotional support",
        "is_self_attested" => true,
        "reason" => "birth",
        "pre_event_sep_in_days" => "1",
        "post_event_sep_in_days" => "1",
        "questions_attributes" => {
          "0" => {
            "content" => "When was Your Dog Born?",
            "answer_attributes" => {
              "responses_attributes" => {
                "0" => {
                  "name" => "true",
                  "result" => "contact_call_center"
                },
                "1" => {
                  "name" => "false",
                  "result" => "contact_call_center"
                },
                "2" => {
                  "operator" => "before",
                  "value" => "",
                  "value_2" => ""
                },
                "3" => {
                  "name" => "",
                  "result" => "proceed"
                }
              }
            },
            "type" => "date"
          }
        },
        "start_on" => "06/01/1990",
        "end_on" => "06/01/2005"
      }
    }
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

  let(:user) { double("user", :has_hbx_staff_role? => true, :has_employer_staff_role? => false)}
  let(:person) { double("person")}
  let(:hbx_staff_role) { double("hbx_staff_role", permission: permission) }
  let(:hbx_profile) { double("HbxProfile")}
  let(:permission) { double(can_add_custom_qle: true) }

  before :each do
    allow(user).to receive(:has_role?).with(:hbx_staff).and_return true
    allow(user).to receive(:person).and_return(person)
    allow(person).to receive(:hbx_staff_role).and_return(hbx_staff_role)
    allow(hbx_staff_role).to receive(:hbx_profile).and_return(hbx_profile)
    sign_in(user)
  end

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

  describe "POST #manage_qle" do
    # NOTE: The market_kind param should be passed
    # via angular when the user selects market kind on the manage page
    context "successfully redirects to" do
      it "new" do
        post(:manage_qle, params: { manage_qle_action: "new_qle", market_kind: 'shop' })
        expect(response.status).to eq(302)
        attrs = { market_kind: 'shop' }
        expect(response).to redirect_to(new_exchanges_qle_path(attrs))
      end

      it "edit" do
        post(
          :manage_qle,
          params: {
            manage_qle_action: "modify_qle",
            market_kind: 'shop',
            id: existing_qle.id.to_s
          }
        )
        expect(response.status).to eq(302)
        attrs = { market_kind: 'shop' }
        expect(response).to redirect_to(edit_exchanges_qle_path(existing_qle, attrs))
      end

      it "deactivation_form" do
        post(
          :manage_qle,
          params: {
            manage_qle_action: "deactivate_qle",
            id: existing_qle.id.to_s,
            market_kind: 'shop'
          }
        )
        expect(response.status).to eq(302)
        attrs = { market_kind: 'shop' }
        expect(response).to redirect_to(deactivation_form_exchanges_qle_path(existing_qle, attrs))
      end
    end
  end
end