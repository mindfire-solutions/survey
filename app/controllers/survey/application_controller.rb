module Survey
  class ApplicationController < ::ApplicationController
    protect_from_forgery

    protected

      def redirect_unless_logged_in
        if defined?(super)
          super
        else
          unless user_signed_in?
            redirect_to main_app.new_user_session_path, :notice => 'Please log in.'
          end
        end
      end

      def redirect_unless_admin
        if defined?(super)
          super
        else
          if !user_signed_in?
            redirect_to main_app.new_user_session_path, :notice => 'Please log in.'
          elsif !current_user.admin?
            redirect_to main_app.root_path, :notice => 'You do not have permission to view this page.'
          end
        end
      end
  end
end