# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FinancialAssistance::Validators::ApplicantContract,  dbclean: :after_each do

  let(:required_params) do
    {
      first_name: "James", last_name: "Bond", ssn: "101010101", gender: "male", dob: Date.new(1993, 3, 8),
      is_incarcerated: false, indian_tribe_member: false, citizen_status: "US citizen",
      is_consumer_role: true, same_with_primary:  true, is_applying_coverage: true
    }
  end
  let(:optional_params) do
    {
      name_pfx: nil, middle_name: nil, name_sfx: nil, is_primary_applicant: nil, person_hbx_id: nil,
      family_member_id: nil, is_disabled: false, ethnicity: nil, race: nil, tribal_id: nil, language_code: nil,
      no_dc_address: false, is_homeless: nil, is_temporarily_out_of_state: nil, vlp_subject: nil,
      alien_number: nil, i94_number: nil, visa_number: nil, passport_number: nil, sevis_id: nil, 
      naturalization_number: nil, receipt_number: nil, citizenship_number: nil, card_number: nil,
      country_of_citizenship: nil, expiration_date: nil, issuing_country: nil, no_ssn: nil,
      addresses: [], phones: [], emails: []
    }
  end
  let(:all_params) { required_params.merge(optional_params)}

  context "Given invalid parameter scenarios" do
    context "with empty parameters" do
      it 'should list error for every required parameter' do
        result = subject.call({})

        expect(result.success?).to be_falsey
        expect(result.errors.to_h.keys).to match_array required_params.keys
      end
    end

    context "with optional parameters only" do
      it { expect(subject.call(optional_params).success?).to be_falsey }
      it { expect(subject.call(optional_params).error?(required_params.first[0])).to be_truthy }
    end
  end

  context "Given valid parameters" do
    context "and required parameters only" do
      it { expect(subject.call(required_params).success?).to be_truthy }
      it { expect(subject.call(required_params).to_h).to eq required_params }
    end

    context "and all required and optional parameters" do
      it "should pass validation" do
        result = subject.call(all_params)
        expect(result.success?).to be_truthy
        expect(result.to_h).to eq all_params
      end
    end
  end
end