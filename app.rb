# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra-websocket'
require './models/init'
require './controllers/DocumentController'

# Clase principal
class App < Sinatra::Base
  register Sinatra::ConfigFile

  use DocumentController

  config_file 'config/config.yml'

  configure :development, :production do
    enable :logging
    enable :session
    set :session_secret, '5fdh4h8f4jghne27w84ew4r882&(asd/&h$gfj&hdkjfjew48y' \
    't4hgrd56g8u84gfmjhdmhh,xg544ncd'
    set :sessions, true
    set :server, 'thin'
    set :sockets, []
  end

  get '/' do
    logger.info 'params'
    logger.info params
    logger.info '--------------'
    logger.info session['session_id']
    logger.info session.inspect
    logger.info 'Configurations'
    logger.info settings.db_adapter
    logger.info '--------------'
    @document = Document.order(:date).reverse.all
    erb :index
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

  get '/miwebsoket' do
    if !request.websocket?
      redirect '/'
    else
      request.websocket do |ws|
        @connect = { id_user: session[:user_id], socket: ws }
        ws.onopen do
          settings.sockets << @connect
        end
        ws.onmessage do |msg|
          EM.next_tick { settings.sockets.each { |s| s[:socket].send(msg) } }
        end
        ws.onclose do
          settings.sockets.delete(@connect)
        end
      end
    end
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
      if category.save
      else
        [500, {}, 'Internal Server Error']
      end
    end
    redirect '/all_category'
  end

  get '/notification' do
    @page_name = 'Notificaciones'
    Note = Struct.new(:notification, :document, :info)
    @document_tagged = []
    @notif_subscribed_category = []
    @notif_user = NotificationUser.where(user: @current_user).all
    @notif_user&.each do |element|
      @current_notif = Notification.find(id: element.notification_id)
      @notif_save = Note.new
      @notif_save.notification = @current_notif
      @notif_save.document = (Document.find(id: @current_notif.document_id))
      @notif_save.info = (element.seen)
      if @current_notif.description == 'etiquetaron'
        @document_tagged << (@notif_save)
      else
        @notif_subscribed_category << (@notif_save)
      end
    end
    @document_tagged.reverse!
    @notif_subscribed_category.reverse!
    erb :notification, layout: @current_layout
  end

  post '/delete_notification' do
    @notificated = Notification.find(id: params[:delete_notification_id])
    @seen = NotificationUser.find(
      notification_id: @notificated.id,
      user_id: @current_user.id
    )
    @seen.delete
    redirect '/notification'
  end

  post '/mark_notification' do
    @notificated = Notification.find(id: params[:seen_id])
    @seen = NotificationUser.find(
      notification_id: @notificated.id,
      user_id: @current_user.id
    )
    if @seen.seen == false
      @seen.update(seen: true)
    else
      @seen.update(seen: false)
    end
    redirect '/notification'
  end

  post '/see_document' do
    if params[:name] == 'Perfil'
      @page_name = 'Documento'
    else
      @page_before_name = params[:name]
      @page_before = params[:road]
      @page_intern = 'Documento'
    end
    @document = Document.find(id: params[:seen_document_id])
    erb :view_document, layout: @current_layout
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

  get '/logout' do
    session.clear
    redirect '/'
  end
end
