require 'rails_helper'
require "#{BenefitSponsors::Engine.root}/spec/shared_contexts/benefit_application.rb"
require "#{BenefitSponsors::Engine.root}/spec/shared_contexts/benefit_market.rb"

module BenefitSponsors
  RSpec.describe ::BenefitSponsors::SponsoredBenefits::ContributionLevel, :dbclean => :after_each do
    describe "given nothing" do
      it "requires a display name" do
        subject.valid?
        expect(subject.errors.has_key?(:display_name)).to be_truthy
      end

      it "requires a contribution unit id" do
        subject.valid?
        expect(subject.errors.has_key?(:contribution_unit_id)).to be_truthy
      end
    end

    describe 'set minimum contribution factor' do
      let(:current_effective_date) { TimeKeeper.date_of_record.beginning_of_month.prev_year + 2.months }

      before :each do
        EnrollRegistry["initial_sponsor_default_#{current_effective_date.year}".to_sym].feature.settings[0].stub(:item).and_return(:fifty_percent_sponsor_fixed_percent_contribution_model)
        EnrollRegistry["renewal_sponsor_default_#{current_effective_date.next_year.year}".to_sym].feature.settings[0].stub(:item).and_return(:zero_percent_sponsor_fixed_percent_contribution_model)
      end

      include_context 'setup benefit market with market catalogs and product packages'
      let(:aasm_state) { :active }
      include_context "setup initial benefit application"
      let!(:renewal_application) do
        application = initial_application.renew
        application.save
        application
      end
      let(:initial_contribution_level) { initial_application.benefit_packages[0].health_sponsored_benefit.sponsor_contribution.contribution_levels.where(display_name: 'Employee').first }
      let(:renewal_contribution_level) { renewal_application.benefit_packages[0].health_sponsored_benefit.sponsor_contribution.contribution_levels.where(display_name: 'Employee').first }

      it 'when eligiblity changes for a renewing employer' do
        expect(initial_contribution_level.min_contribution_factor).to eq 0.5
        expect(renewal_contribution_level.min_contribution_factor).to eq 0.0
      end
    end
  end
end
