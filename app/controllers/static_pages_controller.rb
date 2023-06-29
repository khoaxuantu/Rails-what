class StaticPagesController < ApplicationController
  def home
    if (logged_in?)
      @user = User.find_by(id: session[:user_id])
    end
  end

  def help
  end

  def about
  end

  def contact
  end
end
