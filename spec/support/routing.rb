def locale_param(locale)
  locale.nil? ? {} : { locale: locale.gsub('/', '') }
end