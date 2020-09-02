module ApplicationHelper
  def user_avatar(user)
    if user.avatar_url.present?
      user.avatar_url
    else
      asset_path 'avatar.jpg'
    end
  end

  def word_form(number, vopros, voprosa, voprosov)
  remainder = number % 10
  remainder1 = number % 100

  if (11..14).include? remainder1
    return voprosov
  elsif remainder == 1
    return vopros
  elsif (2..4).include? remainder
    return voprosa
  else
    return voprosov
  end
end

end
