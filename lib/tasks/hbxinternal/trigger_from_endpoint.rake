# This rake task used to update phone records on person. check ticket #19754
# RAILS_ENV=production bundle exec rake hbxit:trigger_from_endpoint

# /api/hbxinternal/v1/long_running_task

namespace :hbxinternal do
  desc "testing triggering rake execution from endpoint"
  task :trigger_from_endpoint => :environment do
    puts "running hbxinternal rake task"
  end

  task :process_long_running_task => :environment do
    # rake hbxinternal:process_long_running_task
    ActionCable.server.broadcast 'notifications_channel', message: '1/5 Retreiving Household members ...'
    puts "1/5 Retreiving Household members ..."
    sleep 2
    ActionCable.server.broadcast 'notifications_channel', message: '2/5 Updating enrollments for members ...'
    puts "2/5 Updating enrollments for members ..."
    sleep 4
    ActionCable.server.broadcast 'notifications_channel', message: '3/5 Finished updating enrollments for members'
    puts "3/5 Finished updating enrollments for members"
    sleep 4
    ActionCable.server.broadcast 'notifications_channel', message: '4/5 Notifing GLUE of enrollment changes ...'
    puts "4/5 Notifing GLUE of enrollment changes ..."
    sleep 6
    ActionCable.server.broadcast 'notifications_channel', message: '5/5 Task complete you may close console.'
    puts "5/5 Task complete you may close console."
  end

  task :change_person_dob => :environment do
    if ENV['hbx_id'] && ENV['dob']
      begin
        person = Person.where(hbx_id:ENV['hbx_id']).first
        raise StandardError.new "Unable to locate a person with HBXID: #{ENV['hbx_id']}" if person.nil?
        ActionCable.server.broadcast 'notifications_channel', message: "1/2 Located person record for #{ENV['hbx_id']}"
      rescue => error
        ActionCable.server.broadcast 'notifications_channel', message: error.message
      else
        new_dob = Date.strptime(ENV['dob'],'%m/%d/%Y')
        person.update_attributes(dob:new_dob)
        ActionCable.server.broadcast 'notifications_channel', message: "2/2 Updated DOB for person record"
      end
    else
      raise StandardError.new "Missing fields to perform change person dob task."
    end
  end

  task :remove_person_ssn => :environment do
    if ENV['hbx_id']
      begin
        person = Person.where(hbx_id:ENV['hbx_id']).first
        raise StandardError.new "Unable to locate a person with HBXID: #{ENV['hbx_id']}" if person.nil?
        ActionCable.server.broadcast 'notifications_channel', message: "1/2 Located person record for #{ENV['hbx_id']}"
      rescue => error
        ActionCable.server.broadcast 'notifications_channel', message: error.message
      else
        person.unset(:encrypted_ssn)
        ActionCable.server.broadcast 'notifications_channel', message: "2/2 Remove ssn from person with HBX ID #{ENV['hbx_id']}"
      end
    else
      raise StandardError.new "Missing fields to perform remove person ssn task."
    end
  end

end
