module ApplicationHelper

  # returns the full title on a per-page basis
  def fullTitle(pageTitle='')
    if pageTitle.empty?
      I18n.t "baseTitle"
    else
      "#{pageTitle} | #{I18n.t "baseTitle"}"
    end
  end

end
