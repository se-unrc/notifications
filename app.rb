# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra-websocket'
require './models/init.rb'

# Clase principal
class App < Sinatra::Base
  register Sinatra::ConfigFile

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
      @notification&. each { |_element| @count_notifications += 1 }
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

  get '/documents' do
    @page_name = 'Documentos'
    @all_documents = Document.order(:name).all
    @all_categories = Category.order(:name).all
    erb :documents, layout: @current_layout
  end

  post '/documents_filter' do
    @page_name = 'Documentos'
    filter(params[:document_id], params[:filter], params[:category_id], params[:dateDoc])
  end

  get '/all_document' do
    @page_name = 'Documentos'
    @all_documents = Document.order(:name).all
    @all_categories = Category.order(:name).all
    @users_name = User.order(:name).all
    erb :all_document, layout: @current_layout
  end

  post '/create_document' do
    @filename = params[:PDF][:filename]
    @src = "/public/PDF/#{@filename}"
    file = params[:PDF][:tempfile]
    direction = "PDF/#{@filename}"
    File.open("./public/PDF/#{@filename}", 'wb') do |f|
      f.write(file.read)
    end
    unless Document.find(name: params[:name])
      save_document(
        params['name'],
        params[:description],
        direction,
        params[:category]
      )
      select_user_tag(params[:users_tagged], params[:category], @doc_save.id)
    end
    redirect '/all_document'
  end

  post '/select_document' do
    @page_before_name = 'Documentos'
    @page_before = '/all_document'
    @page_intern = 'Editar Documento'
    @document_modify = Document.find(id: params[:select_id])
    @categories_modify = Category.where(id: @document_modify.category_id)
    @all_categories = Category.except(@categories_modify).all
    @users_tagged = User.where(documents: @document_modify)
    @users = User.except(@users_tagged).all
    erb :modify_document, layout: @current_layout
  end

  post '/modify_document' do
    @document_modify = Document.find(id: params[:the_id])
    @document_modify.update(name: params[:new_name]) if params[:new_name] != ''
    @document_modify.update(description: params[:description]) if params[:description] != ''
    @document_modify.update(category_id: params[:category]) if params[:category]
    @document_modify.remove_all_users
    @notification_delete = Notification.where(document_id: @document_modify.id).all
    @notification_delete&.each do |element|
      element.remove_all_users
      element.delete
    end
    select_user_tag(params[:users_tagged], @document_modify.category_id, @document_modify.id)
    redirect '/all_document'
  end

  post '/delete_document' do
    @pdf_delete = Document.find(id: params[:delete_document_id])
    @pdf_delete.remove_all_users
    @notification = Notification.where(document_id: @pdf_delete.id).all
    @notification.each do |element|
      element.remove_all_users
      element.delete
    end
    @pdf_delete.delete
    redirect '/all_document'
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

  def select_user_tag(users_tagged, category_id, document_id)
    @user_tagged_category = User.where(
      categories: Category.find(id: category_id)
    )
    @user_tagged_name = tag_users(users_tagged, @user_tagged_category)
    @doc_save = Document.find(id: document_id)
    @user_tagged_cate = []
    @user_tagged_category&.each do |element|
      @user_tagged_cate << element unless @user_tagged_name.include?(element)
    end
    notify(@user_tagged_name, @user_tagged_cate, @doc_save)
  end

  def save_document(
    name_document,
    description_document,
    direction_document,
    category_id
  )
    @chosen_category = Category.find(id: category_id)
    @doc_save = Document.new(name: name_document,
                             description: description_document,
                             fileDocument: direction_document,
                             category_id: @chosen_category.id,
                             date: Time.now.strftime('%Y-%m-%d'))
    @doc_save.save
  end

  def notify(user_tagged, user_category, document)
    date_notification = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    notify_tagged(user_tagged, document, date_notification)
    notify_subcription(user_category, document, date_notification)
  end

  def notify_user(user, message)
    settings.sockets.each do |s|
      s[:socket].send(message) if s[:id_user] == user
    end
  end

  def notify_tagged(user_tagged, document, date_notification)
    @user_taggeds = user_tagged
    return unless @user_taggeds

    @notification_tagged = create_notify(
      document,
      'etiquetaron',
      date_notification
    )
    create_tagged(@user_taggeds, @notification_tagged, document)
  end

  def create_tagged(user_taggeds, _notification_tagged, document)
    user_taggeds&.each do |element|
      document.add_user(element)
      @notification_tagged.add_user(element)
    end
  end

  def notify_subcription(user_category, document, date_notification)
    @notif_from_category = create_notify(
      document,
      'categoria',
      date_notification
    )
    user_category&.each { |element| @notif_from_category.add_user(element) }
  end

  def create_notify(document, descriptions, date_notification)
    @notification = Notification.new(
      description: descriptions,
      date: date_notification,
      document_id: document.id
    )
    @notification.save
    @notification
  end

  def tag_users(users_tagged, user_tagged_category)
    @user_tagged_name = []
    users_tagged&.each do |element|
      @user_not = User.find(id: element)
      index = user_tagged_category.include? element
      user_tagged_category.delete(user_tagged_category[index]) if index
      @user_tagged_name << @user_not
    end
    @user_tagged_name
  end

  def filter(document_id, filter, category_id, date_filter)
    @all_documents = Document.order(:name).all
    if document_id
      @all_documents = Document.where(id: document_id).all
      show_filter(@all_documents)
    else
      filter_advanced(@all_documents, filter, category_id, date_filter)
    end
  end

  def filter_advanced(_all_documents, filter, category_id, date_filter)
    if filter
      filter_order(@all_documents, filter, category_id, date_filter)
    elsif category_id
      filter_category(@all_documents, category_id, date_filter)
    elsif date_filter != ''
      filter_date(@all_documents, date_filter)
    else
      show_filter(@all_documents)
    end
  end

  def filter_order(documents, filter, category_id, date_filter)
    @all_documents_order = order_document(documents, filter)
    if category_id
      filter_category(@all_documents_order, category_id, date_filter)
    elsif date_filter != ''
      filter_date(@all_documents_order, date_filter)
    else
      show_filter(@all_documents_order)
    end
  end

  def order_document(documents, filter)
    if filter == 'date0'
      Document.reverse_order(:date)
    else
      documents
    end
  end

  def filter_category(oder_document, category_id, date_filter)
    @documents_category = Document.where(category_id: category_id).all
    @documents = []
    oder_document&.each do |element|
      @documents << element if @documents_category.include?(element)
    end
    if date_filter != ''
      filter_date(@documents, date_filter)
    else
      show_filter(@documents)
    end
  end

  def filter_date(_all_documents, date_filter)
    return unless date_filter != ''

    new_date = new_date_format(date_filter)
    @document_date = Document.where(date: new_date).all
    @documents = []
    oder_document&.each do |element|
      @documents << element if @document_date.include?(element)
    end
    show_filter(@documents)
  end

  def show_filter(all_document)
    @all_documents = all_document
    @all_categories = Category.order(:name).all
    if session[:type]
      @users_name = User.order(:name).all
      erb :all_document, layout: @current_layout
    else
      erb :documents, layout: @current_layout
    end
  end

  def new_date_format(date)
    new_date = [1..12]
    month = %w[Jan Feb Apr May Jun Jul Aug Sep Oct Nov Dec]
    new_date.each do |element|
      new_date = date[8, 12] + '-' + element + '-' + date[4, 6] if date[0, 3] == month[element]
    end
    new_date
  end
end
