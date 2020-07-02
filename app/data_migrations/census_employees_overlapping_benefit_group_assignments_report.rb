require File.join(Rails.root, "lib/mongoid_migration_task")

class CensusEmployeesOverlappingBenefitGroupAssignmentsReport < MongoidMigrationTask
  def all_census_employees
    @census_employees ||= CensusEmployee.all
  end

  def ce_overlapping_benefit_assignments(census_employee)
    overlapping_bgas = []
    census_employee.benefit_group_assignments.each do |target_bga|
      census_employee.benefit_group_assignments.each do |bga|
        if (bga.start_on..bga.end_on).cover?(target_bga.start_on) || (bga.start_on..bga.end_on).cover?(target_bga.start_on)
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
    Dir.mkdir("census_employees_overlapping_bgas_report") unless File.exists?("census_employees_overlapping_bgas_report")
    file_name = "#{Rails.root}/census_employees_overlapping_bgas_report#{TimeKeeper.datetime_of_record.strftime("%m_%d_%Y_%H_%M_%S")}.csv"

    logger = Logger.new("#{Rails.root}/log/census_employees_overlapping_bgas_report.log") unless Rails.env.test?
    logger.info "Script Start for census_employees_overlapping_bgas_report_#{TimeKeeper.datetime_of_record}" unless Rails.env.test?

    CSV.open(file_name, 'w') do |csv|
      field_names = %w(first_name last_name employer_fein aasm_state bga_id bga_start bga_end)
      csv << field_names
      all_census_employees.each do |census_employee|
        result = ce_overlapping_benefit_assignments(census_employee)
        result[:benefit_group_assignments].each do |benefit_group_assignment|
          csv << [
            result[:census_employee][:first_name],
            result[:census_employee][:last_name],
            result[:census_employee][:benefit_sponsorship][:organization][:fein],
            result[:census_employee][:assm_state],
            benefit_group_assignment[:id].to_s,
            benefit_group_assignment[:start_on].to_s,
            benefit_group_assignment[:end_on].to_s
          ]
        end
      end
    end
  end
end