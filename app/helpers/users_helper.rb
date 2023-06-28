module UsersHelper

  def gravatar_for(user, options = { size: 96 })
    size = options[:size]
    gravatarId = Digest::MD5::hexdigest(user.email.downcase)
    gravatarUrl = "https://secure.gravatar.com/avatar/#{gravatarId}\
    ?s=#{size}"
    image_tag(gravatarUrl, alt: user.name, class: "gravatar")
  end

end
