module UsersHelper

  def gravatar_for(user, options = { size: Settings.user_model.max_avatar_size })
    size = options[:size]
    avatarUrl = get_avatar_href(user, size)
    image_tag(avatarUrl, alt: user.name, class: "gravatar", height: size)
  end

  private

  def get_avatar_href(user, size)
    if user.avatar.attached?
      href = user.avatar.variant(:display)
    else
      gravatarId = Digest::MD5::hexdigest(user.email.downcase)
      href = "https://secure.gravatar.com/avatar/#{gravatarId}?s=#{size}"
    end
  end

end
