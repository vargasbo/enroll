class HbxProfilePolicy < ApplicationPolicy

  def view_admin_tabs?
    role = user_hbx_staff_role
    return false unless role
    role.permission.view_admin_tabs
  end

  def modify_admin_tabs?
    role = user_hbx_staff_role
    return false unless role
    role.permission.modify_admin_tabs
  end

  def view_the_configuration_tab?
    role = user_hbx_staff_role
    return false unless role
    role.permission.view_the_configuration_tab
  end

  def can_submit_time_travel_request?
    role = user_hbx_staff_role
    return false unless role
    role.permission.can_submit_time_travel_request
  end

  def send_broker_agency_message?
    role = user_hbx_staff_role
    return false unless role
    role.permission.send_broker_agency_message
  end

  def approve_broker?
    role = user_hbx_staff_role
    return false unless role
    role.permission.approve_broker
  end

  def approve_ga?
    role = user_hbx_staff_role
    return false unless role
    role.permission.approve_ga
  end

  def can_extend_open_enrollment?
    role = user_hbx_staff_role
    return false unless role
    role.permission.can_extend_open_enrollment
  end

  def can_create_benefit_application?
    role = user_hbx_staff_role
    return false unless role
    role.permission.can_create_benefit_application?
  end

  def can_change_fein?
    role = user_hbx_staff_role
    return false unless role
    role.permission.can_change_fein
  end

  def can_force_publish?
    role = user_hbx_staff_role
    return false unless role
    role.permission.can_force_publish
  end

  def show?
    @user.has_role?(:hbx_staff) ||
      @user.has_role?(:csr) ||
      @user.has_role?(:assister)
  end

  def index?
    @user.has_role? :hbx_staff
  end

  def employer_index?
    index?
  end

  def family_index?
    index?
  end

  def broker_agency_index?
    index?
  end

  def issuer_index?
    index?
  end

  def product_index?
    index?
  end

  def configuration?
    index?
  end

  def new?
    @user.has_role? :hbx_staff
  end

  def edit?
    if @user.has_role?(:hbx_staff)
      @record.id == @user.try(:person).try(:hbx_staff_role).try(:hbx_profile).try(:id)
    else
      false
    end
  end

  def inbox?
    index?
  end

  def create?
    new?
  end

  def update?
    edit?
  end

  def destroy?
    edit?
  end

  def set_date?
    index?
  end

  def can_add_sep?
    role = user_hbx_staff_role
    return false unless role
    role.permission.can_add_sep
  end

  private

  def user_hbx_staff_role
    person = user.person
    return nil unless person
    person.hbx_staff_role
  end
end
