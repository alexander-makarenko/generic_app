class LocaleChangesController < ApplicationController
  before_action { authorize :locale_change }

  def create
    t('v.shared._locale_selector').each do |locale, translation|
      if params[:commit] == translation
        cookies[:locale] = I18n.locale = locale
        current_user.try(:locale=, locale) && current_user.save(validate: false)
        break
      end      
    end    
    redirect_to(request.referrer || root_path)
  end
end