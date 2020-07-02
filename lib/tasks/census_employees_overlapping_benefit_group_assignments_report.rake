require File.join(Rails.root, "app", "data_migrations", "census_employees_overlapping_benefit_group_assignments_report")
# This rake task is provides a CSV of census employees with overlapping benefit group assignments.
namespace :migrations do
  desc "report for census employees with overlapping benefit group assignments"
  CensusEmployeesOverlappingBenefitGroupAssignmentsReport.define_task :census_employees_overlapping_benefit_group_assignments => :environment
end
