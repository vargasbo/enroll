class PlanYear
  include Mongoid::Document
  include Mongoid::Timestamps
  include AASM

  embedded_in :employer_profile


  # Plan Year time period
  field :start_on, type: Date
  field :end_on, type: Date

  field :open_enrollment_start_on, type: Date
  field :open_enrollment_end_on, type: Date
  field :published, type: Boolean

  # Number of full-time employees
  field :fte_count, type: Integer, default: 0

  # Number of part-time employess
  field :pte_count, type: Integer, default: 0

  # Number of Medicare Second Payers
  field :msp_count, type: Integer, default: 0

  field :aasm_state, type: String

  embeds_many :benefit_groups, cascade_callbacks: true
  accepts_nested_attributes_for :benefit_groups, reject_if: :all_blank, allow_destroy: true

  validates_presence_of :start_on, :end_on, :open_enrollment_start_on, :open_enrollment_end_on, :message => "is invalid"

  validate :open_enrollment_date_checks

  def parent
    raise "undefined parent employer_profile" unless employer_profile?
    self.employer_profile
  end

  alias_method :effective_date=, :start_on=
  alias_method :effective_date, :start_on

  def employee_participation_percent
  end

  def editable?
    !benefit_groups.any?(&:assigned?)
  end

  def open_enrollment_contains?(date)
    (open_enrollment_start_on <= date) && (date <= open_enrollment_end_on)
  end

  def coverage_period_contains?(date)
    return (start_on <= date) if (end_on.blank?)
    (start_on <= date) && (date <= end_on)
  end

  def register_employer
    employer_profile.publish_plan_year
  end

  def minimum_employer_contribution
    benefit_groups.min_by(&:premium_pct_as_int).premium_pct_as_int unless benefit_groups.size == 0
  end

  def is_application_valid?
    application_warnings.blank? ? true : false
  end

  # Check plan year application for regulatory compliance
  def application_warnings
    warnings = {}

    if benefit_groups.size == 0
      warnings.merge!({benefit_groups: "at least one benefit group must be defined for plan year"})
    end

    unless employer_profile.organization.primary_office_location.address.state.to_s.downcase == HbxProfile::StateAbbreviation.to_s.downcase
      warnings.merge!({primary_office_location: "primary office must be located in #{HbxProfile::StateName}"})
    end

    # Maximum company size at time of initial registration on the HBX
    if fte_count > HbxProfile::ShopSmallMarketFteCountMaximum
      warnings.merge!({fte_count: "number of full time equivalents (FTEs) exceeds maximum allowed (#{HbxProfile::ShopSmallMarketFteCountMaximum})"})
    end

    # Exclude Jan 1 effective date from certain checks
    unless effective_date.yday == 1
      # Employer contribution toward employee premium must meet minimum
      if benefit_groups.size > 0 && (minimum_employer_contribution < HbxProfile::ShopEmployerContributionPercentMinimum)
        warnings.merge!({minimum_employer_contribution: "employer contribution percent toward employee premium (#{minimum_employer_contribution}) is less than minimum allowed (#{HbxProfile::ShopEmployerContributionPercentMinimum})"})
      end
    end

    warnings
  end

  class << self
    def find(id)
      organizations = Organization.where("employer_profile.plan_years._id" => BSON::ObjectId.from_string(id))
      organizations.size > 0 ? organizations.first.employer_profile.plan_years.unscoped.detect { |py| py._id.to_s == id.to_s} : nil
    end

    def shop_enrollment_timetable(new_effective_date)
      effective_date = new_effective_date.to_date.beginning_of_month
      prior_month = effective_date - 1.month
      plan_year_start_on = effective_date
      plan_year_end_on = effective_date + 1.year - 1.day
      employer_initial_application_earliest_start_on = (effective_date - HbxProfile::ShopPlanYearPublishBeforeEffectiveDateMaximum)
      employer_initial_application_earliest_submit_on = employer_initial_application_earliest_start_on
      employer_initial_application_latest_submit_on   = ("#{prior_month.year}-#{prior_month.month}-#{HbxProfile::ShopPlanYearPublishedDueDayOfMonth}").to_date
      open_enrollment_earliest_start_on     = effective_date - HbxProfile::ShopOpenEnrollmentPeriodMaximum.months
      open_enrollment_latest_start_on       = ("#{prior_month.year}-#{prior_month.month}-#{HbxProfile::ShopOpenEnrollmentBeginDueDayOfMonth}").to_date
      open_enrollment_latest_end_on         = ("#{prior_month.year}-#{prior_month.month}-#{HbxProfile::ShopOpenEnrollmentEndDueDayOfMonth}").to_date
      binder_payment_due_date               = first_banking_date_prior ("#{prior_month.year}-#{prior_month.month}-#{HbxProfile::ShopBinderPaymentDueDayOfMonth}")


      timetable = {
        effective_date: effective_date,
        plan_year_start_on: plan_year_start_on,
        plan_year_end_on: plan_year_end_on,
        employer_initial_application_earliest_start_on: employer_initial_application_earliest_start_on,
        employer_initial_application_earliest_submit_on: employer_initial_application_earliest_submit_on,
        employer_initial_application_latest_submit_on: employer_initial_application_latest_submit_on,
        open_enrollment_earliest_start_on: open_enrollment_earliest_start_on,
        open_enrollment_latest_start_on: open_enrollment_latest_start_on,
        open_enrollment_latest_end_on: open_enrollment_latest_end_on,
        binder_payment_due_date: binder_payment_due_date
      }

      timetable
    end

    def check_start_on(start_on)
      start_on = start_on.to_date
      shop_enrollemnt_times = shop_enrollment_timetable(start_on)

      if start_on.day != 1
        result = "failure"
        msg = "start on must be first day of the month"
      elsif Date.current > shop_enrollemnt_times[:open_enrollment_latest_start_on]
        result = "failure"
        msg = "start on must choose a start on date #{(Date.current - HbxProfile::ShopOpenEnrollmentBeginDueDayOfMonth + 2.months).beginning_of_month} or later"
      end
      {result: (result || "ok"), msg: (msg || "")}
    end

    def calculate_open_enrollment_date(start_on)
      start_on = start_on.to_date
      open_enrollment_start_on = [(start_on - 2.months), Date.current].min
      open_enrollment_end_on = open_enrollment_start_on + 10.days

      {open_enrollment_start_on: open_enrollment_start_on, 
       open_enrollment_end_on: open_enrollment_end_on}
    end

    ## TODO - add holidays
    def first_banking_date_prior(date_value)
      date = date_value.to_date
      date = date - 1 if date.saturday?
      date = date - 2 if date.sunday?
      date
    end
  end

  aasm do
    state :draft, initial: true

    # Plan application as submitted has warnings
    state :publish_pending

    state :published,   :after_enter => :register_employer

    # Published plan year is in force
    state :active

    # Published plans are retired following their end on date
    state :retired

    # Non-published plans are expired following their end on date
    state :expired

    event :advance_application_date, :guard => :is_new_plan_year? do
      transitions from: :draft, to: :expired
      transitions from: :active, to: :retired
      transitions from: :published, to: :active
    end

    # Submit application
    event :publish do
      transitions from: :draft, to: :published, :guard => :is_application_valid?
      transitions from: :draft, to: :publish_pending
    end

    # Returns plan to draft state for edit
    event :withdraw_pending do
      transitions from: :publish_pending, to: :draft
    end

    # Plan with application warnings submitted to HBX
    event :force_publish do
      transitions from: :publish_pending, to: :published
    end

    # Permanently disable this plan year
    event :deactivate do
      transitions from: :draft, to: :expired
      transitions from: :active, to: :retired
    end

    #
    event :revert do
      transitions from: :published, to: :draft
    end
  end


private
  def is_new_plan_year?
  end

  def duration_in_days(duration)
    (duration / 1.day).to_i
  end

  def open_enrollment_date_checks
    return if start_on.blank? || end_on.blank? || open_enrollment_start_on.blank? || open_enrollment_end_on.blank?
    if start_on.day != 1
      errors.add(:start_on, "must be first day of the month")
    end

    if end_on != Date.civil(end_on.year, end_on.month, -1)
      errors.add(:end_on, "must be last day of the month")
    end

    # TODO: Create HBX object with configuration settings including shop_plan_year_maximum_in_days
    shop_plan_year_maximum_in_days = 365
    if (end_on.yday - start_on.yday) > shop_plan_year_maximum_in_days
      errors.add(:end_on, "must be less than #{shop_plan_year_maximum_in_days} days from start date")
    end

    if open_enrollment_end_on > start_on
      errors.add(:start_on, "can't occur before open enrollment end date")
    end

    # if Date.current > ("#{prior_month.year}-#{prior_month.month}-#{HbxProfile::ShopOpenEnrollmentBeginDueDayOfMonth}").to_date
    #  errors.add(:start_on, "must choose a start on date #{effect_date + 1.month} or later")
    # end

    if open_enrollment_end_on < open_enrollment_start_on
      errors.add(:open_enrollment_end_on, "can't occur before open enrollment start date")
    end

    if (open_enrollment_end_on.yday - open_enrollment_start_on.yday) < HbxProfile::ShopOpenEnrollmentPeriodMinimum
     errors.add(:open_enrollment_end_on, "open enrollment period is less than minumum: #{HbxProfile::ShopOpenEnrollmentPeriodMinimum} days")
    end

    if (open_enrollment_end_on - open_enrollment_start_on) > HbxProfile::ShopOpenEnrollmentPeriodMaximum.months
     errors.add(:open_enrollment_end_on, "open enrollment period is greater than maximum: #{HbxProfile::ShopOpenEnrollmentPeriodMaximum} months")
    end

    if start_on + HbxProfile::ShopPlanYearPeriodMinimum < end_on
      errors.add(:end_on, "plan year period is less than minumum: #{duration_in_days(HbxProfile::ShopPlanYearPeriodMinimum)} days")
     end

    if start_on + HbxProfile::ShopPlanYearPeriodMaximum > end_on
      errors.add(:end_on, "plan year period is greater than maximum: #{duration_in_days(HbxProfile::ShopPlanYearPeriodMaximum)} days")
    end

    if (start_on - Date.current) > HbxProfile::ShopPlanYearPublishBeforeEffectiveDateMaximum
     errors.add(:start_on, "applications may not be started more than #{HbxProfile::ShopPlanYearPublishBeforeEffectiveDateMaximum} months before effective date")
    end

    if open_enrollment_end_on - (start_on - 1.month) >= HbxProfile::ShopOpenEnrollmentEndDueDayOfMonth
     errors.add(:open_enrollment_end_on, "open enrollment must end on or before the #{HbxProfile::ShopOpenEnrollmentEndDueDayOfMonth.ordinalize} day of the month prior to effective date")
    end

  end
end
