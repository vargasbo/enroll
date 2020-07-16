class HbxitTaskWorker
  include Sidekiq::Worker

  def perform(*args)
    # Do something
    data = JSON.parse(args[0])
    task = data['task'].to_sym
    options_str = options_to_string(data)
    perform_rake_task task, options_str
  end

  def options_to_string(options)
    str = ""
    options.each do |option|
      str += "#{option[0]}=#{option[1]} "
    end
    str
  end

  def perform_rake_task(task, options)
    system "rake hbxinternal:#{task} #{options}"
  end

end
