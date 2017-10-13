class ShopGeneralAgencyNotice < Notice

  Required= Notice::Required + []

  attr_accessor :general_agency_profile

  def initialize(general_agency_profile, args = {})
    self.general_agency_profile = general_agency_profile
    args[:recipient] = general_agency_profile
    args[:market_kind]= 'shop'
    args[:notice] = PdfTemplates::GeneralAgencyNotice.new
    args[:to] = general_agency_profile.general_agency_staff_roles.first.email_address
    args[:name] = general_agency_profile.general_agency_staff_roles.first.person.full_name.titleize
    args[:recipient_document_store]= general_agency_profile
    self.header = "notices/shared/shop_header.html.erb"
    super(args)
  end

  def deliver
    build
    generate_pdf_notice
    attach_envelope
    non_discrimination_attachment
    upload_and_send_secure_message
    send_generic_notice_alert
  end

  def build
    notice.mpi_indicator = self.mpi_indicator
    notice.notification_type = self.event_name
    notice.email = general_agency_profile.general_agency_staff_roles.first.email_address
    notice.primary_identifier = general_agency_profile.hbx_id
    notice.primary_fullname = general_agency_profile.general_agency_staff_roles.first.person.full_name.titleize
    notice.general_agency_name = recipient.organization.legal_name.titleize
    append_address(general_agency_profile.organization.primary_office_location.address)
    append_hbe
  end

  def attach_envelope
    join_pdfs [notice_path, Rails.root.join('lib/pdf_templates', 'envelope_without_address.pdf')]
  end

  def non_discrimination_attachment
    join_pdfs [notice_path, Rails.root.join('lib/pdf_templates', 'shop_non_discrimination_attachment.pdf')]
  end

  def append_address(primary_address)
    notice.primary_address = PdfTemplates::NoticeAddress.new({
                                 street_1: primary_address.address_1.titleize,
                                 street_2: primary_address.address_2.titleize,
                                 city: primary_address.city.titleize,
                                 state: primary_address.state,
                                 zip: primary_address.zip
                             })
  end

  def append_hbe
    notice.hbe = PdfTemplates::Hbe.new({
                   url: "www.dhs.dc.gov",
                   phone: "(855) 532-5465",
                   fax: "(855) 532-5465",
                   email: "#{Settings.contact_center.email_address}"
               })
  end
end
