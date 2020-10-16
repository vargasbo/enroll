module Notifier
  module VerificationHelper
    def aqhp_citizen_status(status)
      case status
      when "US"
        "US Citizen"
      when "LP"
        "Lawfully Present"
      when "NC"
        "US Citizen"
      else
        ""
      end
    end

    def uqhp_citizen_status(status)
      case status
      when "us_citizen"
        "US Citizen"
      when "alien_lawfully_present"
        "Lawfully Present"
      when "indian_tribe_member"
        "US Citizen"
      when "lawful_permanent_resident"
        "Lawfully Present"
      when "naturalized_citizen"
        "US Citizen"
      else
        "Ineligible Immigration Status"
      end
    end

    def ivl_citizen_status(uqhp_notice, status)
      uqhp_notice ? uqhp_citizen_status(status) : aqhp_citizen_status(status)
    end
  end
end