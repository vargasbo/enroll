module CheckbookServices
  class PlanComparision
    attr_accessor :census_employee
    
    def initialize(census_employee)
      @census_employee= census_employee
      @url = "https://staging.checkbookhealth.org/shop/dc/api/"
    end

    def generate_url
      begin
      # # Checkbook url is still not working so commented below lines
      # @result = HTTParty.post(@url,
      #         :body => construct_body,
      #         :headers => { 'Content-Type' => 'application/json' } )
      # # puts construct_body.to_json
      # puts @result.parsed_response
        return "http://example.com/dummy_url"
      rescue Exception => e
        puts "Exception #{e}"
      end
    end


    private 
    def construct_body
    {
      "effective_date": census_employee.benefit_group_assignments.first.try(:start_on),
      "employer": {
        "state": census_employee.employer_profile.organization.primary_office_location.address.state, #TODO Fix these
        "county": census_employee.employer_profile.organization.primary_office_location.address.state 
      },
      "family": build_family,
      "contribution": {
       "employee":100,
       "spouse":50,
       "domestic_partner":50,
       "child":50
      },
      # "reference_plan": census_employee.employer_profile.plan_years.first.id.to_s,
      "reference_plan":census_employee.employer_profile.plan_years.first.benefit_groups.first.reference_plan.hios_id,
      "plans_available": ["21066DC0010009","21066DC0010010","21066DC0010011"]
    }
    end

    def build_family
      family = [{'dob': census_employee.dob,'relationship': 'self'}]
      census_employee.census_dependents.each do |dependent|
        family << [{'dob': dependent.dob,'relationship': dependent.employee_relationship}]
      end
      family
    end
  end
end