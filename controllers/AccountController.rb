require 'sinatra/base'
require './services/AccountService'

class AccountController < Sinatra::Base

	get '/signup' do
	    erb :signup, layout: :layout
	end

	post '/signup' do 
	    username = params[:username]
	    password1 = params[:password]
	    password2 = params[:confPassword]
	    email = params[:email]
	    fullName = params[:fullname]

	    begin 
	    	AccountService.register_new_user(username,password1,password2,email,fullName)
	    	redirect '/documents'
	    rescue ArgumentError => e 
	    	if e.message == 'The username is already in use or its invalid'
	    		@errorUsername = 'The username is already in use or its invalid'
	    	elsif e.message == 'Passwords are not equal'
	    		@errorPassword = 'Passwords are not equal'
	    	elsif  e.message = 'Password must be between 5 and 20 characters long'
	    		@errorPassword = 'Password must be between 5 and 20 characters long'
	    	elsif e.message = 'The email is invalid'
	    		@errorEmail = 'The email is invalid'
	    	end

	    	# Preguntar como obtener el mensaje correctamente
	    	# Arreglar el before
	    		return erb :signup
	    end
  	end

end