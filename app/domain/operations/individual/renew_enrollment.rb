# frozen_string_literal: true

module Operations
  module Individual
    # This class is invoked when an enrollment is purchased by reporting a SEP
    # and we want to renew this enrollment for next year.
    # Constaint for assisted renewals:
    # Cancel passive renewals before calling this class to be able to passive renew enrollment.

    class RenewEnrollment
      include Dry::Monads[:result, :do]

      def call(hbx_enrollment:, effective_on:, aptc_values: {})
        validated_enrollment = yield validate(hbx_enrollment, effective_on)
        aptc_values          = yield fetch_aptc_values(validated_enrollment, effective_on, aptc_values)
        renewal_enrollment   = yield renew_enrollment(validated_enrollment, aptc_values, effective_on)

        Success(renewal_enrollment)
      end

      private

      def validate(enrollment, effective_on)
        return Failure('Given object is not a valid enrollment object') unless enrollment.is_a?(HbxEnrollment)
        return Failure('Given enrollment is not IVL by kind') unless enrollment.is_ivl_by_kind?
        return Failure('There exists active enrollments for given family in the year with renewal_benefit_coverage_period') unless enrollment.can_renew_coverage?(effective_on)

        Success(enrollment)
      end

      def fetch_aptc_values(enrollment, effective_on, aptc_values)
        return Success(aptc_values) if aptc_values.present?

        family = enrollment.family
        tax_household = family.active_household.latest_active_thh_with_year(effective_on.year)
        if tax_household
          data = { applied_percentage: 1,
                   applied_aptc: tax_household.current_max_aptc.to_f,
                   max_aptc: tax_household.current_max_aptc.to_f,
                   csr_amt: tax_household.current_csr_percent_as_integer }
        end

        Success(data || {})
      end

      def renew_enrollment(enrollment, aptc_values, effective_on)
        enrollment_renewal = Enrollments::IndividualMarket::FamilyEnrollmentRenewal.new
        enrollment_renewal.enrollment = enrollment
        enrollment_renewal.assisted = aptc_values.present? ? true : false
        enrollment_renewal.aptc_values = aptc_values
        enrollment_renewal.renewal_coverage_start = effective_on
        renewed_enrollment = enrollment_renewal.renew
        if renewed_enrollment.is_a?(HbxEnrollment)
          Success(renewed_enrollment)
        else
          Failure('Unable to renew the enrollment')
        end
      end
    end
  end
end
