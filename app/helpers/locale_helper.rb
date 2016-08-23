module LocaleHelper

  def set_locale(user)
    I18n.locale = user.locale unless user.locale.nil?
  end

end