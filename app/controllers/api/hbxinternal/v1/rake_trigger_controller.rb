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

  private

  def call_rake(task, options = {})
    options[:rails_env] = Rails.env
    args = options.map { |n, v| "#{n.to_s.upcase}='#{v}"}
    system "rake #{task} #{args.join(' ')} &"
  end
end
