require File.join(Rails.root, "lib/mongoid_migration_task")

class CensusEmployeesOverlappingBenefitGroupAssignmentsReport < MongoidMigrationTask
  def all_census_employees
    @census_employees ||= CensusEmployee.all
  end

  def ce_overlapping_benefit_assignments(census_employee)
    overlapping_bgas = []
    census_employee.benefit_group_assignments.each do |target_bga|
      census_employee.benefit_group_assignments.each do |bga|
        next if [target_bga.start_on, target_bga.end_on].any? { |date| date.blank? }
        # TODO: Need to figure out what to do if no end on date
        bga_end_on = bga.end_on || bga.start_on + 1.year
        if (bga&.start_on&.to_datetime..bga_end_on.to_datetime).cover?(target_bga&.start_on&.to_datetime) ||
          (bga&.start_on&.to_datetime..bga_end_on.to_datetime).cover?(target_bga&.end_on&.to_datetime)
          overlapping_bgas << bga
        end
      end
    end
    {
      census_employee: census_employee,
      benefit_group_assignments: overlapping_bgas
    }
  end
  def migrate
    puts("Beginning census employee with overlapping Benefit Group Assignments report generation.")
    Dir.mkdir("census_employees_overlapping_bgas_report") unless File.exists?("census_employees_overlapping_bgas_report")
    file_name = "#{Rails.root}/census_employees_overlapping_bgas_report_#{TimeKeeper.datetime_of_record.strftime("%m_%d_%Y_%H_%M_%S")}.csv"

    logger = Logger.new("#{Rails.root}/log/census_employees_overlapping_bgas_report.log") unless Rails.env.test?
    logger.info "Script Start for census_employees_overlapping_bgas_report_#{TimeKeeper.datetime_of_record}" unless Rails.env.test?

    CSV.open(file_name, 'w') do |csv|
      field_names = %w(first_name last_name employer_fein aasm_state bga_id bga_start bga_end)
      csv << field_names
      all_census_employees.each do |census_employee|
        result = ce_overlapping_benefit_assignments(census_employee)
        result[:benefit_group_assignments].each do |benefit_group_assignment|
          csv << [
            result[:census_employee].first_name,
            result[:census_employee].last_name,
            result[:census_employee].employee_role.employer_profile.fein || result[:census_employee].employee_role.employer_profile.legal_name,
            result[:census_employee].aasm_state,
            benefit_group_assignment.id.to_s,
            benefit_group_assignment.start_on.to_s,
            benefit_group_assignment.end_on.to_s
          ]
        end
      end
    end
  end
end