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
      before :each do
        subject.migrate
      end
      # file_name = "#{Rails.root}/census_employees_overlapping_bgas_report#{TimeKeeper.datetime_of_record.strftime("%m_%d_%Y_%H_%M_%S")}.csv"

      it "should create a report of census employees with overlapping benefit group assignments" do

      end
    end
  end
end
