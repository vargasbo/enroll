require 'new_relic/agent/method_tracer'
class Foo
  include ::NewRelic::Agent::MethodTracer

  def generate_image
    puts "hello"
  end

  add_method_tracer :generate_image, 'Custom/generate_image'
end
