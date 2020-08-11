# frozen_string_literal: true

require File.join(Rails.root, "lib/mongoid_migration_task")

class ChangeIncorrectBookmarkUrlInConsumerRole < MongoidMigrationTask
  # rubocop:disable Metrics/BlockNesting, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def migrate
    Person.all.each do |person|
      if person.is_consumer_role_active? && person.user.present?
        if person.primary_family.present? && person.primary_family.active_household.present? && person.primary_family.active_household.hbx_enrollments.where(kind: "individual", is_active: true).present?
          if person.user.identity_verified? && person.user.idp_verified && (person.addresses.present? || person.no_dc_address.present? || (person.is_homeless || person.is_temporarily_out_of_state))
            puts " HBX_ID: #{person.hbx_id}, OLD_URL: #{person.consumer_role.bookmark_url}, NEW_URL: '/families/home' " if  person.consumer_role.bookmark_url.present? && person.consumer_role.bookmark_url != "/families/home" && !Rails.env.test?
            person.consumer_role.update_attribute(:bookmark_url, "/families/home")
          end
        end
      end
    rescue StandardError # rubocop:disable Lint/EmptyRescueClause, Lint/SuppressedException

    end
  end
  # rubocop:enable Metrics/BlockNesting, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
end
