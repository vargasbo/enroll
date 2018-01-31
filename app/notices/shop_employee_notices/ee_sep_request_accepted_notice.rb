class ShopEmployeeNotices::EeSepRequestAcceptedNotice < ShopEmployeeNotice

  attr_accessor :census_employee

  def initialize(census_employee, args)
    @qle_on = args[:options][:qle_on]
    @end_on = args[:options][:end_on]
    @title = args[:options][:title]
    super(census_employee, args)
  end

  def deliver
    build
    append_data
    generate_pdf_notice
    non_discrimination_attachment
    attach_envelope
    upload_and_send_secure_message
    send_generic_notice_alert
  end

  def append_data
    sep = census_employee.employee_role.person.primary_family.special_enrollment_periods.order_by(:"created_at".desc)[0]
    notice.sep = PdfTemplates::SpecialEnrollmentPeriod.new({
      :qle_on => @qle_on,
      :end_on => @end_on,
      :title => @title
      })

  end
end
