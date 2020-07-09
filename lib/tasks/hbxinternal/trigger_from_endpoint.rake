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
end
