RSpec::Matchers.define :permit do |action|
  match do |policy|
    begin
      policy.public_send("#{action}?")
    rescue
      false
    end
  end

  failure_message do |policy|
    "#{policy.class} does not permit #{action} on #{policy.record} for #{policy.user.inspect}."
  end

  failure_message_when_negated do |policy|
    "#{policy.class} does not forbid #{action} on #{policy.record} for #{policy.user.inspect}."
  end
end