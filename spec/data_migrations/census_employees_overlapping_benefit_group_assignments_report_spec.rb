require"rails_helper"
require File.join(Rails.root, "app", "data_migrations", "census_employees_overlapping_benefit_group_assignments_report")


describe "Census Employees overlapping Benefit Group Assignments report", dbclean: :after_each do
  describe "Generate Employers, Employees, and Dependents for SHOP" do
    let(:given_task_name) { "census_employees_overlapping_benefit_group_assignments" }
    subject { CensusEmployeesOverlappingBenefitGroupAssignmentsReport.new(given_task_name, double(:current_scope => nil)) }

    describe "given a task name" do
      it "has the given task name" do
        expect(subject.name).to eql given_task_name
      end
    end

    describe "requirements" do
      let(:site) { build(:benefit_sponsors_site, :with_benefit_market, :as_hbx_profile, :cca) }
      let(:benefit_sponsor) do
        FactoryBot.create(
          :benefit_sponsors_organizations_general_organization,
          :with_aca_shop_cca_employer_profile_initial_application,
          site: site
        )
      end
      let(:benefit_sponsorship) { benefit_sponsor.active_benefit_sponsorship }
      let(:employer_profile) {  benefit_sponsorship.profile }
      let!(:benefit_package) { benefit_sponsorship.benefit_applications.first.benefit_packages.first}
      let(:employee_role)   { FactoryBot.create(:employee_role, employer_profile: employer_profile )}
      let(:hbx_enrollment)  { HbxEnrollment.new(sponsored_benefit_package: benefit_package, employee_role: census_employee.employee_role ) }
      let(:census_employee) { FactoryBot.create(:census_employee, employer_profile: employer_profile, employee_role_id: employee_role.id) }
      let(:start_on) { benefit_package.start_on }
      let(:end_on) { benefit_package.end_on }
      let(:valid_params_bga) do
        {
          census_employee: census_employee,
          benefit_package: benefit_package,
          start_on: start_on,
          end_on: end_on
        }
      end
      # Overlaps with the first
      let(:bga_1) do
        bga = BenefitGroupAssignment.new(**valid_params_bga)
        bga.hbx_enrollment = hbx_enrollment
        bga.save!
        bga
      end
      let(:bga_2) do
        bga = BenefitGroupAssignment.new(**valid_params_bga)
        bga.hbx_enrollment = hbx_enrollment
        bga.save!
        bga
      end

      before :each do
        bga_1
        bga_2
        subject.migrate
      end
      let(:file_name) { "#{Rails.root}/census_employees_overlapping_bgas_report_#{TimeKeeper.datetime_of_record.strftime("%m_%d_%Y_%H_%M_%S")}.csv" }

      it "should create a report of census employees with overlapping benefit group assignments" do
        expect(File.exist?(file_name)).to eq(true)
      end
    end
  end
end
