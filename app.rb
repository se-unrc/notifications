require 'sinatra/base'
require "sinatra/config_file"
require 'sinatra-websocket'
require './models/init.rb'

class App < Sinatra::Base

  register Sinatra::ConfigFile

  config_file 'config/config.yml'

  configure :development, :production do
    enable :logging
    enable :session
    set :session_secret, "5fdh4h8f4jghne27w84ew4r882&(asd/&h$gfj&hdkjfjew48y49t4hgrd56g8u84gfmjhdmhh,xg544ncd"
    set :sessions, true
    set :server, 'thin'
    set :sockets, []
  end

  get "/" do
    logger.info "params"
    logger.info params
    logger.info "--------------"
    logger.info session["session_id"]
    logger.info session.inspect
    logger.info "Configurations"
    logger.info settings.db_adapter
    logger.info "--------------"
    @document = Document.all
    erb :index
  end

  before do
    if session[:isLogin]
      @userName = User.find(id: session[:user_id])
      if session[:type]
        @layoutEnUso = :layout_admin
      else
        @layoutEnUso = :layout_users
      end
    end
  end

  before do
    @urlUser = ["/profile","/subscriptions", "/edit_user","/all_documentUser","/notificaciones"]
    if !session[:isLogin]  &&  @urlUser.include?(request.path_info)
      redirect "/login"
    end
  end

  before do
    @urlAdmin = ["/category","/create_admin","/all_document" ,"/selected_document","/create_document","/migrate_documents"]
    if !session[:type] &&  @urlAdmin.include?(request.path_info)
      redirect "/profile"
    end
  end

  get "/create_user" do
    erb :create_user
  end

  get "/create_admin" do
    erb :create_admin, :layout =>@layoutEnUso
  end

  get "/miwebsoket" do
    if !request.websocket?
      redirect "/"
    else
      request.websocket do |ws|
        @connect = {id_user: session[:user_id], socket: ws}
        ws.onopen do
          settings.sockets << @connect
        end
        ws.onmessage do |msg|
          EM.next_tick { settings.sockets.each {|s| s[:socket].send(msg)}}
        end
        ws.onclose do
          settings.sockets.delete(@connect)
        end
      end
    end
  end

  get "/login" do
    erb :login
  end

  get "/profile" do
    @aux = User.find(id: session[:user_id])
    @document = Document.where(users: @aux)
    erb :profile, :layout =>@layoutEnUso
  end

  get "/edit_user" do
    erb :edit_user, :layout =>@layoutEnUso
  end

  get "/notificaciones" do
    @allPdfCat = []
    @allPdfEt = []
    @not = NotificationUser.where(user_id: @userName.id, seen: 'f')
    @not != [] && @not.each do |element|
      @aux = Notification.find(id: element.notification_id)
      @doc = Document.find(id: @aux.document_id)
      if @aux.description == 'etiquetaron'
        @allPdfEt << (@doc)
      else
        @allPdfCat << (@doc)
      end
    end
    erb :notificaciones, :layout =>@layoutEnUso
  end

 #  post "/notificaciones" do
 #    @not.each do |element|
 #        element.update(seen: true)
 #   end
 # end




  get "/create_document" do
    @userCreate = User.all
    @categories = Category.all
    erb:create_document, :layout =>@layoutEnUso
  end

  get "/tag_document" do
    if session[:type]==true
      @document[] = documents_users
      erb :profile, :layout =>@layoutEnUso
    else
      redirect "/"
    end
  end

  get "/all_documentUser" do
    @allCat = Category.all
    @userName = User.find(id: session[:user_id])
    @allDoc = Document.all
    filter()
    erb :all_documentUser, :layout =>@layoutEnUso
  end

  get "/all_document" do
    @allCat = Category.all
    @userName = User.find(id: session[:user_id])
    filter()
    erb :all_document, :layout =>@layoutEnUso
  end

  get "/category" do
    @cat  = Category.all
    erb :category, :layout =>@layoutEnUso
  end

  get "/subscriptions" do
    @collection = @userName.categories
    @cat = Category.exclude(users: @userName).all
    erb :subscriptions, :layout =>@layoutEnUso
  end

  get "/logout" do
    session.clear
    redirect '/'
  end

  post "/newUser" do
    if user = User.find(email: params[:email])
      [400, {}, "ya existe el usuario"]
    else
      @newUserName = User.new(name: params[:name],surname: params[:surname],dni: params[:dni],email: params[:email],password: params[:password],rol: params[:rol])
      @newUserName.admin=false
      if @newUserName.save
        @errormsg ="La cuenta fue creada."
        erb :login
      else
        @errormsg ="La cuenta no fue creada."
        erb :create_user
      end
    end
  end

  post "/newUserAdmin" do
    if user = User.find(email: params[:email])
      [400, {}, "ya existe el usuario"]
    else
      @newUserName = User.new(name: params[:name],surname: params[:surname],dni: params[:dni],email: params[:email],password: params[:password],rol: params[:rol])
      if (params["type"]=="Administrador")
        @newUserName.admin=true
      else
        @newUserName.admin=false
      end
      if @newUserName.save
        @errormsg ="La cuenta fue creada."
        erb :profile, :layout =>@layoutEnUso
      else
        @errormsg ="La cuenta no fue creada."
        erb :create_admin, :layout =>@layoutEnUso
      end
    end
  end

  post "/userLogin" do
    if @userName = User.find(email: params[:email])
      if @userName.password == params[:password]
        session[:isLogin] = true
        session[:user_id] = @userName.id
        session[:type] = @userName.admin
        redirect "/profile"
      else
        @errormsg ="La contraeña es incorrecta."
        erb :login
      end
    else
      @errormsg ="El Email es incorrecta."
      erb :login
    end
  end

  post "/editNewUser" do
    if (params[:name] != "")
      @userName.update(name: params[:name])
    end
    if (params[:surname] != "")
      @userName.update(surname: params[:surname])
    end
    if (params[:dni] != "")
      @userName.update(dni: params[:dni])
    end
    if (params[:password] != "")
      @userName.update(password: params[:password])
    end
    if (params[:rol] != "")
      @userName.update(rol: params[:rol])
    end
    @errormsg ="Sus datos fueron actualizados."
    @aux = User.find(id: session[:user_id])
    @document = Document.where(users: @aux)
    erb :profile, :layout =>@layoutEnUso
  end

  post "/delete_user" do
    @userDelete = User.find(id: session[:user_id])
    @userDelete.remove_all_categories
    @notification = Notification.where(user_id: @userDelete.id)
    @notification.each do |element|
      element.remove_all_notifications
      element.delete
    end
    @userDelete.delete
    @errormsg ="Su cuenta fue eliminada."
    erb :index, :layout =>@layoutEnUso
  end

  post "/select_category" do
    @categor = Category.find(name: params[:name])
    @cat  = Category.all
    erb :category, :layout =>@layoutEnUso
  end

  post "/create_category" do
    if cat = Category.find(name: params[:name])
      [500, {}, "ya existe la categoria"]
      redirect "/category"
    else
      cat = Category.new(name: params[:name],description: params[:description] )
      if cat.save
        redirect "/category"
      else
        [500, {}, "Internal Server Error"]
        redirect "/home"
      end
    end
  end

  post "/search_category" do
    if @categor = Category.find(name:params["name"])
      @userName = User.find(id: session[:user_id])
      @cat = Category.all
      erb :category, :layout => :layout_admin
    else
      [500, {}, "No existe la Categoria"]
      redirect "/profile"
    end
  end

  post "/option_category" do
    @cat_sel = Category.find(id: params[:id])
    if params[:opcion] == "modificar"
      @cats = Category.all
      @modificar = true
      @cat  = Category.all
      erb :category, :layout =>@layoutEnUso
    else
      @eliminar = true
      @cats = Category.exclude(id: @cat_sel.id).all
      @allDocs = Document.where(category_id: @cat_sel.id).all
      if @allDocs.empty?
        @cat_sel.remove_all_users
        @cat_sel.delete
        redirect "/category"
      else
        @cat  = Category.all
        erb :category, :layout =>@layoutEnUso
      end
    end
  end

  post "/modify_category" do
    if params[:opcion] == "cancelar"
      redirect"/category"
    else
      if  @catUp = Category.find(id:  params['id'])
        @catUp.update(name: params[:name],description: params[:description])
        if @catUp.save
          redirect "/category"
        else
          [500, {}, "Internal Server Error"]
          redirect "/profile"
        end
      else
        [500, {}, "Internal Server Error"]
      end
    end
  end

  post "/migrate_document" do
    if params[:opcion] == "cancelar"
      redirect"/category"
    else
      @cat = Category.find(id: params['cat'])
      @aux = params[:name]
      @aux.each do |element|
        @doc = Document.find(name: element)
        @doc.update(category_id: @cat.id)
      end
      redirect "/category"
    end
  end

  post "/add_subscriptions" do
    @aux = params[:nameSub]
    if @aux
      @aux.each do |element|
        @cat = Category.find(id: element)
        @userName.add_category(@cat)
      end
    end
    redirect "/subscriptions"
  end

  post "/delete_subscriptions" do
    @aux = params[:nameDeleteSub]
    if @aux
      @aux.each do |element|
        @cat = Category.find(id: element)
        @userName.remove_category(@cat)
      end
    end
    @errormsg ="la suscripción fue eliminada."
    @collection = @userName.categories
    @cat = Category.exclude(users: @userName).all
    erb :subscriptions, :layout =>@layoutEnUso
  end

  post '/create_document' do
    @filename = params[:PDF][:filename]
    @src =  "/public/PDF/#{@filename}"
    file = params[:PDF][:tempfile]
    direction = "PDF/#{@filename}"
    File.open("./public/PDF/#{@filename}", 'wb') do |f|
      f.write(file.read)
    end
    date = Time.now.strftime("%Y-%m-%d")
    dateNot = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    chosenCategory = Category.find(id: params[:cat])
    @prob = User.all
    if !(@docExi= Document.find(name: params[:name]) || @docExi= Document.find(description: params[:description]))
      @doc = Document.new(name: params['name'], description: params[:description], fileDocument:  direction, category_id: chosenCategory.id, date: date)
      @doc.save
      @notification = Notification.new(description: "etiquetaron", date: dateNot, document_id: @doc.id)
      @notification.save
      @aux = params[:mult]
      @aux &&  @aux.each do |element|
        @doc.add_user(element)
        @notification.add_user(element)
        message = @notification.description
        notifyUser(element,message)
      end
      @notification_cat =  Notification.new(description: "categoria", date: dateNot, document_id: @doc.id)
      @notification_cat.save
      @cat_notification = Category.find(id: chosenCategory.id)
      @cat_notification.users.each do |element|
        @notification_cat.add_user(element)
      end
      @errormsg ="El documento fue cargado."
      @allCat = Category.all
      @userName = User.find(id: session[:user_id])
      filter()
      erb :all_document, :layout =>@layoutEnUso
    else
      @userCreate = User.all
      @categories = Category.all
      @errormsg = "El Documento/descripción ya existen"
      erb :create_document, :layout =>@layoutEnUso
    end
  end

  post "/delete_document" do
    @pdfDelete = Document.find(id: params[:theId])
    @pdfDelete.remove_all_users
    @notification = Notification.where(document_id: @pdfDelete.id).all
    @notification.each do |element|
      element.remove_all_users
      element.delete
    end
    @pdfDelete.delete
    redirect "/all_document"
  end

  post "/selected_document" do
    @allCat = Category.all
    @userCreate = User.all
    erb :selected_document, :layout =>@layoutEnUso
  end

  post "/modify_document" do
    if (params[:name]!= "")
      @new = Document.find(id: params[:theId])
      @new.update(name: params[:name])
    end
    if (params[:description] != "")
      @new = Document.find(id: params[:theId])
      @new.update(description: params[:description])
    end
    if (params[:cate])
      @new = Document.find(id: params[:theId])
      @new.update(category_id: params[:cate])
    end
    if (params[:mult])
      @new = Document.find(id: params[:theId])
      @new.remove_all_users
      @aux = params[:mult]
      @aux.each do |element|
        @new.add_user(element)
      end
    end
    redirect "/all_document"
  end

  post "/notificaciones" do
     @collection = params[:leidoEt]
     @collection2 = params[:leidoCat]
     @collection && @collection.each do |element|
        @notificado = Notification.find(document_id: element)
        @visto = NotificationUser.where(notification_id: @notificado.id, user_id: @userName.id)
        @visto.update(seen: true)
    end
    @collection2 && @collection2.each do |element|
       @notificado2 = Notification.find(document_id: element)
       @visto2 = NotificationUser.where(notification_id: @notificado2.id, user_id: @userName.id)
       @visto2.update(seen: true)
     end
    redirect "/notificaciones"
 end

  def notifyUser(user, message)
    settings.sockets.each do |s|
      if s[:id_user] == user
        s[:socket].send(message)
      end
    end
  end

  def filter()
    if params[:filterName] && params[:filterName]!=""
      if params[:dateDoc] && params[:dateDoc] != ""
        if params[:filter] && params[:filter] == "dateO"
          if params[:category] && params[:category] != ""
            @idCategory = Category.find(name: params[:category])
            @allPdf = Document.where(name: params[:filterName], date: params[:dateDoc], category_id: @idCategory.id).order(:date)
          else
            @allPdf = Document.where(name: params[:filterName], date: params[:dateDoc]).order(:date)
          end
        else
          if params[:category] && params[:category] != ""
            @idCategory = Category.find(name: params[:category])
            @allPdf = Document.where(name: params[:filterName], date: params[:dateDoc], category_id: @idCategory.id).order(:name)
          else
            @allPdf = Document.where(name: params[:filterName], date: params[:dateDoc]).order(:name)
          end
        end
      else
        if params[:filter] && params[:filter] == "dateO"
          if params[:category] && params[:category] != ""
            @idCategory = Category.find(name: params[:category])
            @allPdf = Document.where(name: params[:filterName], category_id: @idCategory.id).order(:date)
          else
            @allPdf = Document.where(name: params[:filterName]).order(:date)
          end
        else
          @allPdf = Document.where(name: params[:filterName]).order(:name)
        end
      end
    else
      if params[:dateDoc] && params[:dateDoc] != ""
        if params[:filter] && params[:filter] == "dateO"
          if params[:category] && params[:category] != ""
            @idCategory = Category.find(name: params[:category])
            @allPdf = Document.where(date: params[:dateDoc], category_id: @idCategory.id).order(:date)
          else
            @allPdf = Document.where(date: params[:dateDoc]).order(:date)
          end
        else
          if params[:category] && params[:category] != ""
            @idCategory = Category.find(name: params[:category])
            @allPdf = Document.where(date: params[:dateDoc], category_id: @idCategory.id).order(:name)
          else
            @allPdf = Document.where(date: params[:dateDoc]).order(:name)
          end
        end
      else
        if params[:filter] && params[:filter] == "dateO"
          if params[:category] && params[:category] != ""
            @idCategory = Category.find(name: params[:category])
            @allPdf = Document.where(category_id: @idCategory.id).order(:date)
          else
            @allPdf = Document.order(:date)
          end
        else
          if params[:category] && params[:category] != ""
            @idCategory = Category.find(name: params[:category])
            @allPdf = Document.where(category_id: @idCategory.id).order(:name)
          else
            @allPdf = Document.order(:name)
          end
        end
      end
    end
  end
end
