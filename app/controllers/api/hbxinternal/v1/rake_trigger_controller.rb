class Api::Hbxinternal::V1::RakeTriggerController < ActionController::Base
  respond_to :json

  def say_hello
    response = {
      namespace: 'hbxinternal',
      desc:  'testing triggering rake execution from endpoint',
      task: 'trigger_from_endpoint'
    }
    system "rake hbxinternal:trigger_from_endpoint &"
    render json: response
  end

  def long_running_task
    response = {
      namespace: 'hbxinternal',
      desc:  'testing triggering long running rake execution from endpoint',
      task: 'process_long_running_task'
    }
    system "rake hbxinternal:process_long_running_task &"
    render json: response
  end

  def perform_task
    available_task = %w[change_person_dob remove_person_ssn exchange_ssn_between_two_accounts move_user_account_between_two_people_accounts change_ce_date_of_termination]
    response = {}

    if available_task.include? params[:data][:task]
      response[:status] = 200
      response[:message] = "Processing request"
      call_rake(params[:data])
    else
      response[:status] = 400
      response[:message] = "Improper request received"
    end
    render json: response
  end

  private

  def call_rake(params)
    HbxitTaskWorker.perform_async params.to_json
  end
end
