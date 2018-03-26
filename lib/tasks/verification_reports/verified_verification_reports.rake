require 'csv'
# RAILS_ENV=production bundle exec rake reports:verified_verification_report date="Month,year"  (example: "January, 2018")
namespace :reports do
  desc "Verified verifications created monthly report"
  task :verified_verification_report => :environment do
    field_names = %w( SUBSCRIBER_ID MEMBER_ID FIRST_NAME LAST_NAME CURRENT_STATUS VERIFICATION_TYPE VERIFIED_DATE VERIFICATION_REASON)

    CITIZEN_VALID_EVENTS = ["ssn_valid_citizenship_valid!", "ssn_valid_citizenship_valid", "ssn_valid!", "ssn_valid", "pass_dhs!", "pass_dhs", "pass_residency!", "pass_residency"]

    ALL_VALID_EVENTS = ["ssn_valid_citizenship_valid!", "ssn_valid_citizenship_valid", "ssn_valid_citizenship_invalid", "ssn_valid_citizenship_invalid!",
                                "ssn_valid!", "ssn_valid", "pass_dhs!", "pass_dhs", "pass_residency!", "pass_residency"]

    def date
      begin
        ENV["date"].strip         
      rescue
        puts 'Provide report month.'
      end
    end

    def subscriber_id
      if @person.primary_family
        @person.hbx_id
      else
        @person.families.map(&:primary_family_member).map(&:hbx_id).join(',')
      end

    end

    def start_date
      Date.parse(date)
    end

    def end_date
      Date.parse(date).next_month
    end

    def verified_history_elements_with_date_range
      @person.consumer_role.verification_type_history_elements.
      where(created_at:{
        :"$gte" => start_date,
        :"$lt" => end_date},
        :"$or" => [
          {:"action" => "verify"},
          {:"modifier" => "external Hub"}
        ]
      )
    end
  
    def verified_people
      Person.where(:"consumer_role.verification_type_history_elements" => { :"$elemMatch" => {
        :"created_at" => {
          :"$gte" => start_date,
          :"$lt" => end_date
        },
        :"$or" => [
          {:"action" => "verify"},
          {:"modifier" => "external Hub"}
        ]  
      }})
    end

    def hub_response_wfst
      hub_response_on = @history_element.created_at.to_date
      v_type = @history_element.verification_type
      @person.consumer_role.workflow_state_transitions.where(:"created_at" => {
        :"$gt" => hub_response_on - 1.day,
        :"$lt" => hub_response_on + 1.day
        }, 
        :"event".in => (v_type == "Citizenship" ? CITIZEN_VALID_EVENTS : ALL_VALID_EVENTS)
      ).first
    end

    def is_not_eligible_transaction?
      return false if @history_element.modifier != "external hub"
      hub_response_wfst.blank?
    end


    file_name = "#{Rails.root}/public/verified_verification_report_#{date.gsub(" ", "").split(",").join("_")}.csv"


    CSV.open(file_name, "w", force_quotes: true) do |csv|
      csv << field_names

      verified_people.each do |person|
        begin
          @person = person
          verified_history_elements_with_date_range.each do |history_element|
            @history_element = history_element

            next if is_not_eligible_transaction?
          
            csv << [  subscriber_id,
                      person.hbx_id,
                      person.first_name,
                      person.last_name,  
                      person.consumer_role.verification_type_status(history_element.verification_type,person),
                      history_element.verification_type,
                      history_element.created_at,
                      history_element.update_reason
                    ]
          end
        rescue => e
         puts "Invalid Person with HBX_ID: #{person.hbx_id}"
        end 
      end
      
      puts "*********** DONE ******************"
    end

  end
end

