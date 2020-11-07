# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra-websocket'
require './models/init'

# Controller para Suscription
class SuscriptionController < Sinatra::Base
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

  get '/subscriptions' do
    @page_name = 'Subscripciones'
    @subcriptions = Category.where(users: @current_user)
    @all_categories = Category.except(@subcriptions).all
    erb :subscriptions, layout: @current_layout
  end

  post '/delete_subcriptions' do
    @subscription_to_delete = Category.find(id: params[:idSubcriptions])
    @current_user.remove_category(@subscription_to_delete)
  end

  post '/new_suscription' do
    @subscription = Category.find(id: params[:id_cat])
    @current_user.add_category(@subscription)
    redirect '/subscriptions'
  end
end
