module UsersHelper

  def humanize_locale(locale)
    t("v.shared._locale_selector.#{locale}")
  end

  def humanize_boolean(value)
    value ? t('h.users_helper.yes') : t('h.users_helper.no')
  end

  def last_seen_time_ago_in_words(user)
    if user.last_seen_at
      time_ago_in_words(user.last_seen_at) + ' ' + t('h.users_helper.ago')
    else
      '—'
    end
  end
end