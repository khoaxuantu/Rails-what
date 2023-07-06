class ApplicationController < ActionController::Base
    include SessionsHelper
    include Pagy::Backend

    private
        def login_required
            unless logged_in?
                flash[:danger] = t 'login_required'
                redirect_to login_url, status: :unauthorized
            end
        end
end
