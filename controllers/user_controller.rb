# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra-websocket'
require './models/init'
require './services/user_service'

# Controller para User
class UserController < Sinatra::Base
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

  post '/new_user' do
    unless User.find(dni: params[:dni])
      @new_user = User.new(
        name: params[:name],
        surname: params[:surname],
        dni: params[:dni],
        email: params[:email],
        password: params[:password],
        rol: params[:rol]
      )
      @new_user.admin = false
      if @new_user.save
        @message_screen = 'La cuenta fue creada.'
        redirect '/profile'
      else
        @message_screen = 'La cuenta no fue creada.'
        redirect '/'
      end
    end
  end

  post '/create_user' do
    unless User.find(dni: params[:dni])
      @new_user = User.new(
        name: params[:name],
        surname: params[:surname],
        dni: params[:dni],
        email: params[:email],
        password: params[:password],
        rol: params[:rol]
      )
      @new_user.admin = params['type'] == 'Administrador'
      @new_user.save
    end
    redirect '/profile'
  end

  get '/profile' do
    @page_name = 'Inicio'
    @all_documents = Document.where(users: @current_user).all
    @all_subcriptions = Category.where(users: @current_user).all
    @all_subcriptions&.each do |element|
      @documents_category = Document.where(category_id: element.id).all
      @documents_category&.each do |element2|
        @all_documents << (element2) unless @all_documents.include?(element2)
      end
    end
    erb :profile, layout: @current_layout
  end

  post '/edit_user' do
    @current_user.update(name: params[:name]) if params[:name] != ''
    @current_user.update(surname: params[:surname]) if params[:surname] != ''
    @current_user.update(dni: params[:dni]) if params[:dni] != ''
    @current_user.update(password: params[:password]) if params[:password] != ''
    @current_user.update(rol: params[:rol]) if params[:rol] != ''
    redirect '/profile'
  end

  post '/delete_user' do
    @user_delete = User.find(id: session[:user_id])
    @user_delete.remove_all_categories
    @user_delete.remove_all_documents
    @notification = Notification.where(users: @user_delete).all
    unless @notification.empty?
      @notification.each do |element|
        element.remove_all_notifications
        element.delete
      end
    end
    if @user_delete.delete
      session.clear
      redirect '/'
    end
  end
end
