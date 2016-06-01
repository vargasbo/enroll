class HbxAdminController < ApplicationController
  $months_array = Date::ABBR_MONTHNAMES.compact

  def edit_aptc_csr
    raise NotAuthorizedError if !current_user.has_hbx_staff_role?
    @current_year = params[:year_selected]  || TimeKeeper.date_of_record.year
    @person = Person.find(params[:person_id])
    @family = Family.find(params[:family_id])
    @hbx = HbxEnrollment.find(params[:hbx_enrollment_id]) if params[:hbx_enrollment_id].present?
    @hbxs = @family.active_household.hbx_enrollments_with_aptc_by_year(@current_year)
    @no_enrollment = @family.active_household.hbx_enrollments_with_aptc_by_year(@current_year).blank?

    @slcsp_value = HbxAdmin.calculate_slcsp_value(@family)
    @household_members = HbxAdmin.build_household_members(@family)
    @household_info = HbxAdmin.build_household_level_aptc_csr_data(@family, @hbxs)
    #build_household_level_aptc_csr_data(family, hbxs=nil, max_aptc=nil, csr_percentage=nil, applied_aptcs_array=nil,  member_ids=nil)
    @enrollments_info = HbxAdmin.build_enrollments_data(@family, @hbxs) if @hbxs.present?
    
    @current_aptc_applied_hash =  HbxAdmin.build_current_aptc_applied_hash(@hbxs)
    @aptc_applied_for_all_hbxs = @family.active_household.hbx_enrollments_with_aptc_by_year(@current_year).map{|h| h.applied_aptc_amount.to_f}.sum || 0
    @plan_premium_for_enrollments = HbxAdmin.build_plan_premium_hash_for_enrollments(@hbxs)
    
    @active_tax_household_for_current_year = @family.active_household.latest_active_tax_household_with_year(@current_year)
    #@max_aptc = @family.active_household.latest_active_tax_household.latest_eligibility_determination.max_aptc
    @max_aptc = @family.active_household.latest_active_tax_household_with_year(@current_year).try(:latest_eligibility_determination).try(:max_aptc)

    #@csr_percent_as_integer = @family.active_household.latest_active_tax_household.latest_eligibility_determination.csr_percent_as_integer
    @csr_percent_as_integer = @family.active_household.latest_active_tax_household_with_year(@current_year).try(:latest_eligibility_determination).try(:csr_percent_as_integer)
    respond_to do |format|
      format.js { render (@no_enrollment ? "edit_aptc_csr_no_enrollment" : "edit_aptc_csr_active_enrollment")}
      #format.js { render "edit_aptc_csr", person: @person, person_has_active_enrollment: @person_has_active_enrollment}
    end
  end

  def calculate_aptc_csr
    raise NotAuthorizedError if !current_user.has_hbx_staff_role?
    @current_year = params[:year_selected]  || TimeKeeper.date_of_record.year
    @person = Person.find(params[:person_id])
    @family = Family.find(params[:family_id])
    @hbx = HbxEnrollment.find(params[:hbx_enrollment_id]) if params[:hbx_enrollment_id].present?
    @hbxs = @family.active_household.hbx_enrollments_with_aptc_by_year(@current_year)
    @no_enrollment = @family.active_household.hbx_enrollments_with_aptc_by_year(@current_year).blank?
    @household_info = HbxAdmin.build_household_level_aptc_csr_data(@family, @hbxs, params[:max_aptc].to_f, params[:csr_percentage].to_i, params[:applied_aptcs_array])

    @enrollments_info = HbxAdmin.build_enrollments_data(@family, @hbxs, params[:applied_aptcs_array], params[:max_aptc].to_f, params[:csr_percentage].to_i, params[:memeber_ids])
    @slcsp_value = HbxAdmin.calculate_slcsp_value(@family)
    @household_members = HbxAdmin.build_household_members(@family)
    
    @current_aptc_applied_hash =  HbxAdmin.build_current_aptc_applied_hash(@hbxs, params[:applied_aptcs_array])
    @aptc_applied_for_all_hbxs = @family.active_household.hbx_enrollments_with_aptc_by_year(@current_year).map{|h| h.applied_aptc_amount.to_f}.sum || 0
    @plan_premium_for_enrollments = HbxAdmin.build_plan_premium_hash_for_enrollments(@hbxs)
    @active_tax_household_for_current_year = @family.active_household.latest_active_tax_household_with_year(@current_year)
    
    @max_aptc = ('%.2f' % params[:max_aptc]) || @family.active_household.latest_active_tax_household.latest_eligibility_determination.max_aptc    
    @csr_percent_as_integer = params[:csr_percentage] || @family.active_household.latest_active_tax_household.latest_eligibility_determination.csr_percent_as_integer

    respond_to do |format|
      #format.js { render "edit_aptc_csr", person: @person, person_has_active_enrollment: @person_has_active_enrollment}
      format.js { render (@no_enrollment ? "edit_aptc_csr_no_enrollment" : "edit_aptc_csr_active_enrollment")}
    end
  end

  def update_aptc_csr
    raise NotAuthorizedError if !current_user.has_hbx_staff_role?
    @person = Person.find(params[:person][:person_id]) if params[:person].present? && params[:person][:person_id].present?
    @family = Family.find(params[:person][:family_id]) if params[:person].present? && params[:person][:family_id].present?
    
    # Change this value so it is read from the dropdown params of years when implementing the retro functionality
    year = TimeKeeper.datetime_of_record.year
    if @family.present?
      # Update Max APTC and CSR Percentage
      max_aptc = @family.active_household.latest_active_tax_household.latest_eligibility_determination.max_aptc
      csr_percent_as_integer = @family.active_household.latest_active_tax_household.latest_eligibility_determination.csr_percent_as_integer
      
      existing_latest_eligibility_determination = @family.active_household.latest_active_tax_household.latest_eligibility_determination
      latest_active_tax_household = @family.active_household.latest_active_tax_household

      if !(params[:max_aptc].to_f == max_aptc && params[:csr_percentage].to_i == csr_percent_as_integer)
        # If max_aptc / csr percent is updated, create a new eligibility_determination with a new "determined_on" timestamp and the corresponsing csr/aptc update.
        latest_active_tax_household.eligibility_determinations.build({"determined_at"                 => TimeKeeper.datetime_of_record, 
                                                                      "determined_on"                 => TimeKeeper.datetime_of_record, 
                                                                      "csr_eligibility_kind"          => existing_latest_eligibility_determination.csr_eligibility_kind, 
                                                                      "premium_credit_strategy_kind"  => existing_latest_eligibility_determination.premium_credit_strategy_kind, 
                                                                      "csr_percent_as_integer"        => params[:csr_percentage].to_i, 
                                                                      "max_aptc"                      => params[:max_aptc].to_f, 
                                                                      "benchmark_plan_id"             => existing_latest_eligibility_determination.benchmark_plan_id,
                                                                      "e_pdc_id"                      => existing_latest_eligibility_determination.e_pdc_id  
                                                                      }).save!
      end

      result = HbxAdmin.update_aptc_applied_for_enrollments(params)

    end

    respond_to do |format|
      format.js { render "update_aptc_csr", person: @person}
    end
  end

end
