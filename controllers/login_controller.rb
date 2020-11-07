# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra-websocket'
require './models/init'

# Controller para Login/logout
class LoginController < Sinatra::Base
  configure :development, :production do
    set :views, "#{settings.root}/../views"
  end

  before do
    if session[:is_login]
      @current_user = User.find(id: session[:user_id])
      @notification = NotificationUser.where(
        user_id: @current_user.id,
        seen: 'f'
      )
      @count_notifications = 0
      @notification&.each { |_element| @count_notifications += 1 }
      @page = request.path_info
      @current_layout = session[:type] ? :layout_admin : :layout_users
    end
    @url_admin = ['/all_category', '/all_document', '/modify_document']
    redirect '/profile' if !session[:type] && @url_admin.include?(
      request.path_info
    )
    redirect '/all_document' if session[:type] && (request.path_info) == '/documents'
    @url_user =
      ['/profile', '/subscriptions', '/edit_user', '/documents',
       '/notification', '/view_document']
    redirect '/' if !session[:is_login] && @url_user.include?(request.path_info)
  end

  post '/user_login' do
    @current_user = User.find(email: params[:email])
    if @current_user
      if @current_user.password == params[:password]
        session[:is_login] = true
        session[:user_id] = @current_user.id
        session[:type] = @current_user.admin
        redirect '/profile'
      else
        @message_screen = 'La contraeña es incorrecta.'
        redirect '/'
      end
    else
      @message_screen = 'El Email es incorrecto.'
      redirect '/'
    end
  end

  get '/logout' do
    session.clear
    redirect '/'
  end
end
