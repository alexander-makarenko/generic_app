if @user.errors.any?
  json.description t('v.shared._validation_errors.message',
    count: @user.errors.full_messages.uniq.count)

  json.errors do
    @user.errors.keys.each do |attr|
      json.set! attr do
        errors = @user.errors.full_messages_for(attr).uniq
        errors.each do |error|
          json.set! errors.index(error), error
        end
      end
    end
  end
end