# frozen_string_literal: true

module Operations
  module Individual
    class CancelRenewalEnrollment
      include Dry::Monads[:result, :do]
      include FloatHelper

      def call(hbx_enrollment:)
        validated_enrollment = yield validate(hbx_enrollment)
        filter_enrollment = yield filter_enrollment(validated_enrollment)
        cancel_renewals = cancel_renewals(filter_enrollment)
        Success(cancel_renewals)
      end

      private

      def validate(enrollment)
        return Failure('Given object is not a valid enrollment object') unless enrollment.is_a?(HbxEnrollment)
        Success(enrollment)
      end

      def filter_enrollment(enrollment)
        return Failure('Given enrollment is not IVL by kind') unless enrollment.is_ivl_by_kind?
        return Failure('Given enrollment is a shopping enrollment by aasm_state') if enrollment.shopping?
        return Failure('System is not under open enrollment') unless enrollment.family.is_under_ivl_open_enrollment?
        Success(enrollment)
      end

      def cancel_renewals(enrollment)
        year = TimeKeeper.date_of_record.year + 1
        renewal_enrollments = enrollment.family.hbx_enrollments.by_coverage_kind(enrollment.coverage_kind).by_year(year).show_enrollments_sans_canceled.by_kind(enrollment.kind)
        renewal_enrollments.each do |enr|
          enr.cancel_ivl_enrollment if enr&.subscriber&.applicant_id == enrollment&.subscriber&.applicant_id && enr.effective_on == enrollment.effective_on.next_year
        end
      end
    end
  end
end
