require 'rails_helper'

RSpec.describe EmployerRenewal, type: :model, dbclean: :after_each do
  let(:renewal_start_date)        { TimeKeeper.date_of_record.end_of_month + 1.day }
  let(:active_plan_year_start_on) { renewal_start_date + 3.months - 1.year }
  let(:active_benefit_group_one)  { FactoryGirl.build(:benefit_group) }
  let(:active_benefit_group_two)  { FactoryGirl.build(:benefit_group) }
  let(:active_plan_year)          { FactoryGirl.build(:plan_year, 
                                      start_on: active_plan_year_start_on,
                                      benefit_groups: [active_benefit_group_one, active_benefit_group_two]) 
                                    }
  let(:employer_profile)          { FactoryGirl.create(:employer_profile, plan_years: [active_plan_year]) }

  let(:employee_set_one_count)    { 2 }
  let(:employee_set_two_count)    { 1 }
  let(:employee_total_count)      { employee_set_one_count + employee_set_two_count}
  let(:active_employees_one)      { FactoryGirl.create_list(:census_employees, employee_set_one_count) }
  let(:active_employees_two)      { FactoryGirl.create_list(:census_employees, employee_set_two_count) }

  context "An Employer is registered on the Exchange" do
    context "and renewal application is invalid" do
 
      context "when existing employer profile is invalid" do
        context "because there's not an active plan year in published state" do
          before do
            employer_profile.plan_years = []
          end
                  
          it "should raise alien address validation error"
            expect{Factories::EmployerRenewal(employer_profile)}.to raise_error(EmployerRenewalError, /Renewals require an existing, published Plan Year/)
          end
        end
      end

      context "when primary address isn't in-state" do
        let(:alien_address) { OfficeLocation.new(is_primary = true,
                                Address.new(
                                  kind: "work",
                                  address_1: "101 Main St, NW",
                                  city: "Anchorage",
                                  state: "AK",
                                  zip: "99502"
                                  )
                                )
                              }
        before do
          employer_profile.office_locations = [alien_address]
        end

        it "should raise alien address validation error"
          expect{Factories::EmployerRenewal(employer_profile)}.to raise_error(EmployerRenewalError, /Employer primary address must be located in/)
        end
      end

      context "when non-owner threshhold isn't met" do
        it "should raise non-owner validation error"
      end

      context "when renewal time period has lapsed" do
        let(:invalid_renewal_start_date)    { active_plan_year_start_on + 1.year + 1.day }
        before do
          TimeKeeper.set_date_of_record_unprotected!(invalid_renewal_start_date)
        end

        it "should raise renewal time period expired error" do
          expect{Factories::EmployerRenewal(employer_profile)}.to raise_error(EmployerRenewalError, /Renewal time period has expired/)
        end
      end
    end

    context "and its three months before the active plan year expires" do
      before do
        TimeKeeper.set_date_of_record_unprotected!(renewal_start_date - 1.day)
      end

      context "and no renewal plan year exists" do
        it "should create a new renewal plan year" do
        end
      end

      context "and a renewal plan year already exists" do
        let(:renewal_plan_year)   { FactoryGirl.create(:plan_year, start_on: active_plan_year_start_on) }

        context "and the renewal plan year is not in published state" do

          it "should be in renewing state" do
            expect(renewal_plan_year.renewing?).to be_truthy
          end

          it "should create a new renewal plan year" do
          end
        end

        context "and the renewal plan year is published" do
          before do
            renewal_plan_year.renew_publish!
          end

          it "should be in renewing published state" do
            expect(renewal_plan_year.renewing_published?).to be_truthy
          end

          it "should not create a new renewal plan year and return and error" do
          end
        end
      end

      context "and the employer's premium billing account is in current status" do
      end

      context "and the employer's premium billing account is behind" do
      end
    end

    context "and its 60 days before the active plan year expires" do
      context "and the employer's premium billing account is in current status" do
      end

      context "and the employer's premium billing account is behind" do
      end
    end

    contect "and its the first day of open enrollment period" do
      context "and the employer's premium billing account is in current status" do
      end

      context "and the employer's premium billing account is behind" do
      end
    end
    
  end
end
