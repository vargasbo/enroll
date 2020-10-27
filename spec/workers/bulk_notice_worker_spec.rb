require 'rails_helper'

describe BulkNoticeWorker do
  describe "#peform" do

    context "with employees as the audience type" do
        let(:profile) { FactoryBot.create :benefit_sponsors_organizations_aca_shop_dc_employer_profile }
        let(:audience) { profile.organization }
        let(:bulk_notice) { FactoryBot.create :bulk_notice, audience_type: 'employees', audience_identifiers: [ audience.id ]}

        before { subject.peform_async(audience.id, bulk_notice.id) }

        it 'delievered a message for each employee (audience_member)' do
          byebug
          audience.employees.each do |audience_member|
            expect(audience_member.messages.first).to_not be_nil
        end

        it 'generates a result for each employee (audience_member)' do
          bulk_notice.reload
          audience.employees.each do |audience_member|
            expect(bulk_notice.results.find_by(audience_identifier: audience.id,
              audience_member_identifier: audience_member.id)).to_not be_nil
          end
        end
      end

    end
  end
end