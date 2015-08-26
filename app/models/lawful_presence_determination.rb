class LawfulPresenceDetermination
  SSA_VERIFICATION_REQUEST_EVENT_NAME = "local.enroll.lawful_presence.ssa_verification_request"
  VLP_VERIFICATION_REQUEST_EVENT_NAME = "local.enroll.lawful_presence.vlp_verification_request"

  include Mongoid::Document
  include Mongoid::Timestamps
  include AASM
  include Acapi::Notifiers

  embedded_in :consumer_role
  field :vlp_verified_at, type: DateTime
  field :vlp_authority, type: String
  field :vlp_document_id, type: String
  field :citizen_status, type: String
  field :aasm_state, type: String
  embeds_many :workflow_state_transitions, as: :transitional

  aasm do
    state :verification_pending, initial: true
    state :verification_outstanding
    state :verification_successful

    event :authorize, :after => :record_transition do
      transitions from: :verification_pending, to: :verification_successful, after: :record_approval_information
      transitions from: :verification_outstanding, to: :verification_successful, after: :record_approval_information
    end

    event :deny, :after => :record_transition do
      transitions from: :verification_pending, to: :verification_outstanding, after: :record_denial_information
      transitions from: :verification_outstanding, to: :verification_outstanding, after: :record_denial_information
    end
  end

  def start_ssa_process
    notify(SSA_VERIFICATION_REQUEST_EVENT_NAME, {:person => self.consumer_role.person})
  end

  def start_vlp_process
    notify(VLP_VERIFICATION_REQUEST_EVENT_NAME, {:person => self.consumer_role.person})
  end

  private
  def record_approval_information(*args)
    approval_information = args.first
    self.vlp_verified_at = approval_information.determined_at
    self.vlp_authority = approval_information.vlp_authority
    self.citizen_status = approval_information.citizen_status
  end

  def record_denial_information(*args)
    denial_information = args.first
    self.vlp_verified_at = denial_information.determined_at
    self.vlp_authority = denial_information.vlp_authority
    self.citizen_status = ::ConsumerRole::NOT_LAWFULLY_PRESENT_STATUS
  end

  def record_transition(*args)
    workflow_state_transitions << WorkflowStateTransition.new(
      from_state: aasm.from_state,
      to_state: aasm.to_state,
      transition_at: Time.now
    )
  end
end
