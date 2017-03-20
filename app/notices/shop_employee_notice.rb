class ShopEmployeeNotice < Notice

  Required= Notice::Required + []

  attr_accessor :census_employee

  def initialize(census_employee, args = {})
    self.census_employee = census_employee
    args[:recipient] = census_employee.employee_role.person
    args[:market_kind]= 'shop'
    args[:notice] = PdfTemplates::EmployeeNotice.new
    args[:to] = census_employee.employee_role.person.work_email_or_best
    args[:name] = "Employee Notice"
    args[:recipient_document_store]= census_employee.employee_role.person
    self.header = "notices/shared/header_with_page_numbers.html.erb"
    super(args)
  end

  def deliver
    build
    generate_pdf_notice
    attach_envelope
    upload_and_send_secure_message
    send_generic_notice_alert
  end

  def build
    notice.primary_fullname = census_employee.full_name
    notice.employer_name = census_employee.employer_profile.legal_name
    append_broker(census_employee.employer_profile.broker_agency_profile)
  end

  def attach_envelope
    join_pdfs [notice_path, Rails.root.join('lib/pdf_templates', 'envelope_without_address.pdf')]
  end

  def append_broker(broker)
    return if broker.blank?
    location = broker.organization.primary_office_location
    broker_role = broker.primary_broker_role
    person = broker_role.person if broker_role
    return if person.blank? || location.blank?

    notice.broker = PdfTemplates::Broker.new({
      primary_fullname: person.full_name,
      organization: broker.legal_name,
      phone: location.phone.try(:to_s),
      email: (person.home_email || person.work_email).try(:address),
      web_address: broker.home_page,
      address: PdfTemplates::NoticeAddress.new({
        street_1: location.address.address_1,
        street_2: location.address.address_2,
        city: location.address.city,
        state: location.address.state,
        zip: location.address.zip
      })
    })
  end

end
