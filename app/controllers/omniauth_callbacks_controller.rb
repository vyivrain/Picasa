class OmniauthCallbacksController < ApplicationController
  
  require 'net/http'

  def google_oauth2
      @user = User.find_for_google_oauth2(env["omniauth.auth"], current_user)

      if @user.persisted?
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
        sign_in @user
        redirect_to show_user_path
      else
        session["devise.google_data"] = env["omniauth.auth"]
        redirect_to root_path
      end
  end
end
