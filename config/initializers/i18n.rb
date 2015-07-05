# add interpolation support for arrays, see:
# http://stackoverflow.com/questions/21574900/interpolation-in-i18n-array

I18n.backend.instance_eval do
  def interpolate(locale, string, values = {})
    if string.is_a?(::String) && !values.empty?
      I18n.interpolate(string, values)
    elsif string.is_a?(::Array) && !values.empty?
      string.map { |el| interpolate(locale, el, values) }
    else
      string
    end
  end
end