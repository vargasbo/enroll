require "json"
include FactoryBot::Syntax::Methods

namespace :hbxinternal do
  desc "build hbx internals team db"
  task :generate_employers => :environment do
    file = Rails.root.join('db', 'seedfiles', 'hbxit', 'seed_data', 'companies.json')
    surnames = Rails.root.join('db', 'seedfiles', 'hbxit', 'seed_data', 'surnames.json')
    givennames = Rails.root.join('db', 'seedfiles', 'hbxit', 'seed_data', 'firstnames.json')
    companies = data_hash = JSON.parse(File.read(file))
    last_names = data_hash = JSON.parse(File.read(surnames))
    first_names = data_hash = JSON.parse(File.read(givennames))
    aca_state = Settings.aca.state_abbreviation
    street_type = %w[Way Drive Lane Court Avenue]
    gender = %w['Male' 'Female']
    benefit_market = BenefitSponsors::Site.first.benefit_markets.first
    site = BenefitSponsors::Site.first

    puts "::: Generating Employers :::"
    BenefitSponsors::Organizations::GeneralOrganization.all.destroy_all
    companies.each do |company|
      fein = 9.times.map{rand(10)}.join
      hbx_id = 9.times.map{rand(10)}.join
      address = BenefitSponsors::Locations::Address.new(kind: "primary", address_1: "#{rand(5..200)} #{company['city']} #{street_type.sample}", city: "Washington", state: aca_state, zip: "20001", county: "County")
      phone = BenefitSponsors::Locations::Phone.new(kind: "main", area_code: "202", number: "#{3.times.map{rand(10)}.join}-#{4.times.map{rand(10)}.join}")
      office_location = BenefitSponsors::Locations::OfficeLocation.new(is_primary: true, address: address, phone: phone)
      office_locations = [office_location]
      gender = %w['male' 'female']
      email = Email.new(kind: "work", address: "hr@#{company['company'].strip}.com")
      organization = BenefitSponsors::Organizations::GeneralOrganization.new(
        site: site,
        hbx_id: hbx_id,
        legal_name: company['company'],
        dba: company['company'],
        fein: fein,
        entity_kind: :s_corporation,
      )
      organization.profiles << BenefitSponsors::Organizations::AcaShopDcEmployerProfile.new(organization: organization, office_locations: office_locations)
      if organization.save!
        puts "::: Created Employer #{company['company']} :::"
        benefit_sponsorship = organization.profiles.first.add_benefit_sponsorship
        benefit_sponsorship.aasm_state = :active
        benefit_sponsorship.save
      end
    end

    puts "::: Done Generating Employers :::"

  end
end
