# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra-websocket'
require './models/init'

require './controllers/before_controller'

require './services/before_service'

# Controller para Login/logout
class LoginController < BeforeController
  post '/user_login' do
    @current_user = User.find(email: params[:email])
    if @current_user
      if @current_user.password == params[:password]
        session[:is_login] = true
        session[:user_id] = @current_user.id
        session[:type] = @current_user.admin
        redirect '/profile'
      # else
      #   @message_screen = 'La contraeña es incorrecta.'
      #   redirect '/'
      end
    # else
    #   @message_screen = 'El Email es incorrecto.'
    #   redirect '/'
    end
  end

  get '/logout' do
    session.clear
    redirect '/'
  end
end
