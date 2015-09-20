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

RSpec::Matchers.define :have_errors do |expected_count|
  match do |obj|
    @class = obj.class

    obj.valid?
    count = obj.errors.count
    error_list = obj.errors.full_messages.map { |err| err.prepend('- ') }.join("\n")

    if expected_count
      @expected_result_in_words = 'have ' << pluralize(expected_count, 'error')
      if count == expected_count
        @result_in_words = 'did'
        (@result_in_words << ":\n" << error_list) unless expected_count == 0
      else
        @result_in_words = "had #{count}" << ":\n" << error_list
      end
      count == expected_count
    else
      @expected_result_in_words = 'have errors'
      @result_in_words = (obj.errors.empty? ? 'had none' : "had #{count}:\n#{error_list}")
      !obj.errors.empty?
    end
  end

  description do
    @expected_result_in_words
  end

  failure_message do
    "expected that #{@class} instance would #{@expected_result_in_words}, but it #{@result_in_words}"
  end

  failure_message_when_negated do
    "expected that #{@class} instance would not #{@expected_result_in_words}, but it #{@result_in_words}"
  end
end