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
        ActionCable.server.broadcast 'notifications_channel', message: "1/3 Located person record for #{ENV['hbx_id']}"
      rescue => error
        ActionCable.server.broadcast 'notifications_channel', message: error.message
      else
        ActionCable.server.broadcast 'notifications_channel', message: "2/3 Updated DOB for person record"
        new_dob = Date.strptime(ENV['dob'],'%m/%d/%Y')
        person.update_attributes(dob:new_dob)
        ActionCable.server.broadcast 'notifications_channel', message: '3/3 Task complete you may close console.'
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
        ActionCable.server.broadcast 'notifications_channel', message: "1/3 Located person record for #{ENV['hbx_id']}"
      rescue => error
        ActionCable.server.broadcast 'notifications_channel', message: error.message
      else
        ActionCable.server.broadcast 'notifications_channel', message: "2/3 Remove ssn from person with HBX ID #{ENV['hbx_id']}"
        person.unset(:encrypted_ssn)
        ActionCable.server.broadcast 'notifications_channel', message: '3/3 Task complete you may close console.'
      end
    else
      raise StandardError.new "Missing fields to perform remove person ssn task."
    end
  end

  task :exchange_ssn_between_two_accounts => :environment do
    if ENV['hbx_id_1'] && ENV['hbx_id_2']
      begin
        person1 = Person.where(hbx_id: ENV['hbx_id_1']).first
        person2 = Person.where(hbx_id: ENV['hbx_id_2']).first
        raise StandardError.new "Unable to locate a person with HBXID: #{ENV['hbx_id_1']}" if person1.nil?
        raise StandardError.new "Unable to locate a person with HBXID: #{ENV['hbx_id_2']}" if person2.nil?
        ActionCable.server.broadcast 'notifications_channel', message: "1/3 Located persons record for #{ENV['hbx_id_1']} and #{ENV['hbx_id_2']}"
      rescue => error
        ActionCable.server.broadcast 'notifications_channel', message: error.message
      else
        ssn1 = person1.ssn
        ssn2 = person2.ssn
        raise StandardError.new "Person with HBXID: #{ENV['hbx_id_1']} has no ssn" if ssn1.nil?
        raise StandardError.new "Person with HBXID: #{ENV['hbx_id_2']} has no ssn" if ssn2.nil?
        ActionCable.server.broadcast 'notifications_channel', message: "2/3 Moving SSN's between accounts"
        person1.unset(:encrypted_ssn)
        person2.unset(:encrypted_ssn)
        person1.update_attributes(ssn: ssn2)
        person2.update_attributes(ssn: ssn1)
        ActionCable.server.broadcast 'notifications_channel', message: "3/3 Task complete you may close console"
      end
    else
      raise StandardError.new "Missing fields to perform exchange ssn between two accounts task."
    end
  end

  task :move_user_account_between_two_people_accounts => :environment do
    if ENV['hbx_id_1'] && ENV['hbx_id_2']
      begin
        person1 = Person.where(hbx_id: ENV['hbx_id_1']).first
        person2 = Person.where(hbx_id: ENV['hbx_id_2']).first
        raise StandardError.new "Unable to locate a person with HBXID: #{ENV['hbx_id_1']}" if person1.nil?
        raise StandardError.new "Unable to locate a person with HBXID: #{ENV['hbx_id_2']}" if person2.nil?
        ActionCable.server.broadcast 'notifications_channel', message: "1/3 Located persons record for #{ENV['hbx_id_1']} and #{ENV['hbx_id_2']}"
      rescue => error
        ActionCable.server.broadcast 'notifications_channel', message: error.message
      else
        user = person1.user
        raise StandardError.new "Person with HBXID: #{ENV['hbx_id_1']} has no user" if user.nil?
        ActionCable.server.broadcast 'notifications_channel', message: "2/3 Moving user account between person accounts"
        person1.unset(:user.id)
        person2.set(user_id: user.id)
        ActionCable.server.broadcast 'notifications_channel', message: "3/3 Task complete you may close console"
      end
    else
      raise StandardError.new "Missing fields to perform move user account between two people task."
    end
  end

end
