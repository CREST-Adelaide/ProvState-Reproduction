class ApplicationController < ActionController::Base

	before_action :authorized
	helper_method :current_user
	helper_method :logged_in?
	helper_method :group_access?	#may need to be changed to before action

	def current_user    
    	User.find_by(id: session[:user_id])  
	end

	def logged_in?
    	!current_user.nil?  
	end

	def authorized
		redirect_to '/welcome' unless logged_in?
	end

	def group_access?
		!session[:group].nil?
	end

	

end
