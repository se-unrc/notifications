# frozen_string_literal: true

@notification # frozen_string_literal: true
require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra-websocket'
require './models/init.rb'

class App < Sinatra::Base
  register Sinatra::ConfigFile

  config_file 'config/config.yml'

  configure :development, :production do
    enable :logging
    enable :session
    set :session_secret, '5fdh4h8f4jghne27w84ew4r882&(asd/&h$gfj&hdkjfjew48y49t4hgrd56g8u84gfmjhdmhh,xg544ncd'
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
      @notification = NotificationUser.where(user_id: @current_user.id, seen: 'f')
      @page = request.path_info
      if session[:type]
        @current_layout = :layout_admin
        @page = request.path_info
      else
        @current_layout = :layout_users
        @page = request.path_info
      end
    end
    @url_admin = ['/all_category', '/all_document', '/modify_document']
    redirect '/profile' if !session[:type] && @url_admin.include?(request.path_info)
    redirect '/all_document' if session[:type] && (request.path_info) == '/documents'
    @url_user = ['/profile', '/subscriptions', '/edit_user', '/documents', '/notification', '/view_document']
    redirect '/' if !session[:is_login] && @url_user.include?(request.path_info)
  end

  get '/miwebsoket' do # para nico
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

  post '/new_user' do # FUNNCIONA
    if user = User.find(dni: params[:dni])
      [400, {}, 'ya existe el usuario'] # Crear UI
    else
      @new_user = User.new(name: params[:name], surname: params[:surname], dni: params[:dni], email: params[:email], password: params[:password], rol: params[:rol])
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

  post '/create_user' do # FUNNCIONA
    if user = User.find(dni: params[:dni])
      [400, {}, 'ya existe el usuario']
    else
      @new_user = User.new(name: params[:name], surname: params[:surname], dni: params[:dni], email: params[:email], password: params[:password], rol: params[:rol])
      @new_user.admin = params['type'] == 'Administrador'
      @new_user.save
    end
  end

  post '/user_login' do # FUNNCIONA
    if @current_user = User.find(email: params[:email])
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

  get '/profile' do # FUNNCIONA
    @page_name = 'Inicio'
    @user = User.find(id: session[:user_id])
    @all_documents = Document.where(users: @user)
    erb :profile, layout: @current_layout
  end

  post '/edit_user' do # FUNCIONA
    @current_user.update(name: params[:name]) if params[:name] != ''
    @current_user.update(surname: params[:surname]) if params[:surname] != ''
    @current_user.update(dni: params[:dni]) if params[:dni] != ''
    @current_user.update(password: params[:password]) if params[:password] != ''
    @current_user.update(rol: params[:rol]) if params[:rol] != ''
    redirect '/profile'
  end

  post '/delete_user' do # FUNCIONA
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

  get '/documents' do # FUNCIONA
    @page_name = 'Documentos'
    @all_documents = Document.order(:name).all
    @all_categories = Category.order(:name).all
    erb :documents, layout: @current_layout
  end

  post '/documents_filter' do
    @page_name = 'Documentos'
    @all_categories = Category.order(:name).all
    if params[:document_id]
      @all_documents = Document.where(id: params[:document_id]).all
    else
      @all_documents = if params[:filter] == 'date0'
                         Document.order(:date).reverse.all
                       else
                         Document.order(:name).all
                       end
      if params[:category_id]
        @documents_category = Document.where(category_id: params[:category_id]).all
        @documents = []
        @all_documents.each do |element|
          @documents << element if @documents_category.include?(element)
        end
        @all_documents = @documents
      end
      # if params[:dateDoc] != ""
      #   newDate = new_date_format (params[:dateDoc])
      #   # newDate = "2020-10-15"
      #   @document2 = Document.where(date: newDate).all
      #   @document = @document2
      # end
    end
    if session[:type]
      @users_name = User.order(:name).all
      erb :all_document, layout: @current_layout
    else
      erb :documents, layout: @current_layout
    end
  end

  get '/all_document' do # FUNCIONA
    @page_name = 'Documentos'
    @all_documents = Document.order(:name).all
    @all_categories = Category.order(:name).all
    @users_name = User.order(:name).all
    erb :all_document, layout: @current_layout
  end

  post '/create_document' do # FUNCIONA
    @filename = params[:PDF][:filename]
    @src = "/public/PDF/#{@filename}"
    file = params[:PDF][:tempfile]
    direction = "PDF/#{@filename}"
    File.open("./public/PDF/#{@filename}", 'wb') do |f|
      f.write(file.read)
    end
    date_document = Time.now.strftime('%Y-%m-%d')
    date_notification = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    @chosen_category = Category.find(id: params[:category])
    if !Document.find(name: params[:name])
      @doc_save = Document.new(name: params['name'], description: params[:description], fileDocument: direction, category_id: @chosen_category.id, date: date_document)
      @doc_save.save

      # @notification = Notification.new(description: params[:description], date: dateNot, document_id: @doc.id)
      # @notification.save
      # @aux = params[:mult]
      # @aux &&  @aux.each do |element|
      #   @doc.add_user(element)
      #   @notification.add_user(element)
      #   message = @notification.description
      #   notifyUser(element,message)
      # end

      @notification = Notification.new(description: 'etiquetaron', date: date_notification, document_id: @doc_save.id)
      @notification.save
      @User_names = params[:users_tagged]
      @User_names&.each do |element|
        @doc_save.add_user(element)
        @notification.add_user(element)
        message = @notification.description
        notify_user(element, message)
      end
      @notif_from_category = Notification.new(description: 'categoria', date: date_notification, document_id: @doc_save.id)
      @notif_from_category.save
      @user_tagged_category = User.where(categories: Category.find(id: params[:category]))
      @user_tagged_category.each do |element|
        @notif_from_category.add_user(element)
      end
      @message_screen = 'El documento fue cargado.'
    else
      @message_screen = 'El Documento/descripción ya existen'
    end
  end

  post '/select_document' do # FUNCIONANDO
    @page_before_name = 'Documentos'
    @page_before = '/all_document'
    @page_intern = 'Editar Documento'
    @document_modify = Document.find(id: params[:the_id])
    @all_categories = Category.order(:name).all
    @categories_modify = Category.find(id: @document_modify.category_id)
    @users_tagged = User.where(documents: @document_modify)
    @users = User.except(@users_tagged).all
    erb :modify_document, layout: @current_layout
  end

  post '/modify_document' do # FUNCIONANDO Verificar lo de etiquetar y sumar notificaciones...
    @document_modify = Document.find(id: params[:the_id])
    @document_modify.update(name: params[:new_name]) if params[:new_name] != ''
    @document_modify.update(description: params[:description]) if params[:description] != ''
    @document_modify.update(category_id: params[:category]) if params[:category]
    @document_modify.remove_all_users
    if params[:users_tagged]
      @User_Ids = params[:users_tagged]
      @User_Ids.each do |element|
        @document_modify.add_user(element)
      end
    end
  end

  post '/delete_document' do # FUNCIONA
    @pdf_delete = Document.find(id: params[:the_id])
    @pdf_delete.remove_all_users
    @notification = Notification.where(document_id: @pdf_delete.id).all
    @notification.each do |element|
      element.remove_all_users
      element.delete
    end
    @pdf_delete.delete
  end

  get '/all_category' do # FUNCIONA
    @page_name = 'Categorias'
    @all_categories = Category.order(:name).all
    erb :all_category, layout: @current_layout
  end

  post '/create_category' do # FUNCIONA
    if category = Category.find(name: params[:name])
      [500, {}, 'ya existe la categoria']
    else
      category = Category.new(name: params[:name], description: params[:description])
      if category.save
      else
        [500, {}, 'Internal Server Error']
      end
    end
  end

  get '/notification' do # FUNCIONA
    @page_name = 'Notificaciones'
    Note = Struct.new(:notification, :document, :info)
    @document_tagged = []
    @notif_subscribed_category = []
    @notif_user = NotificationUser.where(user_id: session[:user_id]).all
    @notif_user&.each do |element|
      @current_notif = Notification.find(id: element.notification_id)
      @notif_save = Note.new
      if @current_notif.description == 'etiquetaron'
        @notif_save.notification = @current_notif
        @notif_save.document = (Document.find(id: @current_notif.document_id))
        @notif_save.info = (element)
        @document_tagged << (@notif_save)
      else
        @notif_save.notification = @current_notif
        @notif_save.document = (Document.find(id: @current_notif.document_id))
        @notif_save.info = (element)
        @notif_subscribed_category << (@notif_save)
      end
    end
    erb :notification, layout: @current_layout
  end

  post '/delete_notification' do # FUNCIONA
    @notificated = Notification.find(id: params[:the_id])
    @Seen = NotificationUser.find(notification_id: @notificated.id, user_id: @current_user.id)
    @Seen.delete
  end

  post '/mark_notification' do # FUNCIONA
    @notificated = Notification.find(id: params[:the_id])
    @seen = NotificationUser.find(notification_id: @notificated.id, user_id: @current_user.id)
    if @seen.seen == false
      @seen.update(seen: true)
    else
      @seen.update(seen: false)
    end
  end

  post '/see_document' do # FUNCIONA
    if params[:name] == 'Perfil'
      @page_name = 'Documento'
    else
      @page_before_name = params[:name]
      @page_before = params[:road]
      @page_intern = 'Documento'
    end
    @document = Document.find(id: params[:the_id])
    erb :view_document, layout: @current_layout
  end

  get '/subcriptions' do # FUNCIONA
    @page_name = 'Suscripciones'
    @subcriptions = Category.where(users: @current_user)
    @allCategory = Category.except(@subcriptions).all
    erb :subcriptions, layout: @current_layout
  end

  post '/delete_subcriptions' do
    @subscription_to_delete = Category.find(id: params[:idSubcriptions])
    @current_user = User.find(id: session[:user_id])
    @current_user.remove_category(@subscription_to_delete)
  end

  post '/new_suscription' do
    @subscription = Category.find(id: params[:id_cat])
    @current_user.add_category(@subscription)
  end

  post '/modify_category' do # FUNCIONA
    if @category_update = Category.find(id: params[:modify_id])
      @category_update.update(name: params[:name], description: params[:description])
      [500, {}, 'Internal Server Error'] unless @category_update.save
    end
  end

  post '/delete_category' do # FUNCIONA
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
  end

  get '/logout' do # FUNNCIONA
    session.clear
    redirect '/'
  end

  def notify_user(user, message) # Funciona
    settings.sockets.each do |s|
      s[:socket].send(message) if s[:id_user] == user
    end
  end

  def new_date_format(date)
    new_date = ''
    case date[0, 3]
    when 'Jan'
      new_date = date[8, 12] + '-' + '01' + '-' + date[4, 6]
    when 'Feb'
      new_date = date[8, 12] + '-' + '02' + '-' + date[4, 6]
    when 'Mar'
      new_date = date[8, 12] + '-' + '03' + '-' + date[4, 6]
    when 'Apr'
      new_date = date[8, 12] + '-' + '04' + '-' + date[4, 6]
    when 'May'
      new_date = date[8, 12] + '-' + '05' + '-' + date[4, 6]
    when 'Jun'
      new_date = date[8, 12] + '-' + '06' + '-' + date[4, 6]
    when 'Jul'
      new_date = date[8, 12] + '-' + '07' + '-' + date[4, 6]
    when 'Aug'
      new_date = date[8, 12] + '-' + '08' + '-' + date[4, 6]
    when 'Sep'
      new_date = date[8, 12] + '-' + '09' + '-' + date[4, 6]
    when 'Oct'
      new_date = date[8, 12] + '-' + '10' + '-' + date[4, 6]
    when 'Nov'
      new_date = date[8, 12] + '-' + '11' + '-' + date[4, 6]
    when 'Dec'
      new_date = date[8, 12] + '-' + '12' + '-' + date[4, 6]
    end
    new_date
  end
end
