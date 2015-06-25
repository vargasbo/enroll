require 'rails_helper'

RSpec.describe Insured::InboxesController, :type => :controller do
  let(:hbx_profile) { double(id: double("hbx_profile_id"))}
  let(:user) { double("user") }
  let(:person) { double(:employer_staff_roles => [double("person", :employer_profile_id => double)])}

  describe "Get new" do
    let(:inbox_provider){double(id: double("id"),full_name: double("inbox_provider"), inbox: double(messages: double(build: double("inbox"))))}
    before do
      sign_in
      allow(Person).to receive(:find).and_return(inbox_provider)
      allow(HbxProfile).to receive(:find).and_return(hbx_profile)
    end

    it "render new template" do
      xhr :get, :new, :id => inbox_provider.id, profile_id: hbx_profile.id, to: "test", format: :js
      expect(response).to render_template("new")
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST create" do
    let(:inbox){Inbox.new}
    let(:inbox_provider){double(id: double("id"),full_name: double("inbox_provider"))}
    let(:valid_params){{"message"=>{"subject"=>"test", "body"=>"test", "sender_id"=>"558b63ef4741542b64290000", "from"=>"HBXAdmin", "to"=>"Acme Inc."}}}
    before do
      allow(user).to receive(:person).and_return(person)
      sign_in(user)
      allow(Person).to receive(:find).and_return(inbox_provider)
      allow(HbxProfile).to receive(:find).and_return(hbx_profile)
      allow(inbox_provider).to receive(:inbox).and_return(inbox)
      allow(inbox_provider.inbox).to receive(:post_message).and_return(inbox)
      allow(inbox_provider.inbox).to receive(:save).and_return(true)
      allow(hbx_profile).to receive(:inbox).and_return(inbox)
    end

    it "creates new message" do
      post :create, valid_params, id: inbox_provider.id, profile_id: hbx_profile.id
      expect(response).to have_http_status(:redirect)
    end
  end
end