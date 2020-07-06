class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "notifications_channel"
    # ActionCable.server.broadcast 'notifications_channel', message: 'Retreiving Household members'
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    stop_all_streams
  end
end
