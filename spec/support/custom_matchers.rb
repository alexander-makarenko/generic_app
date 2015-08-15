include ActionView::Helpers::TextHelper

module Capybara
  class Session
    def has_flash?(type, contents = nil)
      case contents
      when Array
        contents.each do |element|
          return false unless has_selector?("div.alert-#{type.to_s}", text: element)
        end
      else
        has_selector?("div.alert-#{type.to_s}", contents ? { text: contents } : {})
      end
    end
  end
end

# Pundit
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

RSpec::Matchers.define :be_permitted do
  match do |request|
    begin
      request.call
      true
    rescue Pundit::NotAuthorizedError
      false
    end
  end

  supports_block_expectations
  failure_message { "expected that request would be permitted" }
  failure_message_when_negated { "expected that request would not be permitted" }
end

RSpec::Matchers.define :have_errors do |count|
  match do |object|
    return false if object.valid?
    count ? object.errors.count == count : true
  end

  failure_message do |object|
    "expected that #{object.class} instance would have #{count ? pluralize(count, 'error') + ' ' : 'errors'}"
  end

  failure_message_when_negated do |object|
    "expected that #{object.class} instance would not have errors"
  end
end