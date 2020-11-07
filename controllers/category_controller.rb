# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra-websocket'
require './models/init'

# Controller para Category
class CategoryController < Sinatra::Base
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

  get '/all_category' do
    @page_name = 'Categorias'
    @all_categories = Category.order(:name).all
    erb :all_category, layout: @current_layout
  end

  post '/create_category' do
    unless Category.find(name: params[:name])
      category = Category.new(
        name: params[:name],
        description: params[:description]
      )
      [500, {}, 'Internal Server Error'] unless category.save
    end
    redirect '/all_category'
  end

  post '/modify_category' do
    @category_update = Category.find(id: params[:modify_id])
    @category_update&.update(
      name: params[:name],
      description: params[:description]
    )
    redirect '/all_category'
  end

  post '/delete_category' do
    @category_delete = Category.find(id: params['id_delete'])
    @category_selected = Category.find(id: params['id_select'])
    @document = Document.where(category_id: @category_delete.id)
    @document.each do |element|
      element.update(category_id: @category_selected.id)
    end
    @all_docs = Document.where(category_id: @category_delete.id)
    if @all_docs.empty?
      @category_delete.remove_all_users
      @category_delete.delete
    end
    redirect '/all_category'
  end
end
