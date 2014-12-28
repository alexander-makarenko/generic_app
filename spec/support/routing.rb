def param_from_url(locale)
  locale.nil? ? {} : { locale: locale.gsub(/\//, '') }
end