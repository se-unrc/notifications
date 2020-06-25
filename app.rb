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
    @urlUser = ["/profile","/subscriptions", "/edit_user","/all_documentUser"]
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

  # get "/test" do
  #    if !request.websocket?
  #      erb:testing
  #    else
  #      request.websocket do |ws|
  #        ws.onopen do
  #          ws.send("connected!");
  #          settings.sockets << ws
  #        end
  #        ws.onmessage do |msg|
  #          EM.next_tick { settings.sockets.each {|s| s.send(msg) } }
  #        end
  #        ws.onclose do
  #          warn{"Disconnected"}
  #          settings.sockets.delete(ws)
  #        end
  #      end
  #    end
  #  end


  get "/rutaSocket" do
    if !request.websocket?
      erb:index, :layout=> :layoutEnUso
    else
      websoquet
    end
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

      # @connection = {user: user, socket: ws}
      #     ws.onopen do
      #       settings.sockets << @connection
      #     end
      erb :index
    end


    get "/login" do
      erb :login
    end


    get "/logout" do
      session.clear
      redirect '/'
    end

    post "/userLogin" do
      if @userName = User.find(email: params["email"])
        if @userName.password == params["password"]
          session[:isLogin] = true
          session[:user_id] = @userName.id
          session[:type] = @userName.admin
          redirect "/profile"
        else
          @error ="Your password is incorrect"
        end
      else
        @error ="Your email is incorrect"
      end
    end

    get "/profile" do
      if !request.websocket?
        @aux = User.find(id: session[:user_id])
        @document = Document.where(users: @aux)
        erb :profile, :layout =>@layoutEnUso
      else
        request.websocket do |ws|
          ws.onopen do
            @connect = {id_user: session[:user_id], socket: ws}
            settings.sockets << @connect
          end
          ws.onmessage do |msg|
            EM.next_tick { settings.sockets.each {|s| s.send(msg)} }
          end
          ws.onclose do
            settings.sockets.delete(ws)
         end
      end
   end
 end

    get "/edit_user" do
      erb :edit_user, :layout =>@layoutEnUso
    end

    post "/editNewUser" do
      if (params["name"] != "")
        @userName.update(name: params["name"])
      end
      if (params["surname"] != "")
        @userName.update(surname: params["surname"])
      end
      if (params["dni"] != "")
        @userName.update(dni: params["dni"])
      end
      if (params["password"] != "")
        @userName.update(password: params["password"])
      end
      if (params["rol"] != "")
        @userName.update(rol: params["rol"])
      end
      redirect "/profile"
    end

    get "/create_user" do
      erb :create_user
    end

    post "/newUser" do
      if user = User.find(email: params["email"])
        [400, {}, "ya existe el usuario"]
      else
        @newUserName = User.new(name: params["name"],surname: params["surname"],dni: params["dni"],email: params["email"],password: params["password"],rol: params["rol"])
        @newUserName.admin=fale
        if @newUserName.save
          redirect "/login"
        else
          [500, {}, "Internal Server Error"]
          redirect "/create_user"
        end
      end
    end

    get "/create_admin" do
      erb :create_admin, :layout =>@layoutEnUso
    end

    post "/newUserAdmin" do
      if user = User.find(email: params["email"])
        [400, {}, "ya existe el usuario"]
      else
        @newUserName = User.new(name: params["name"],surname: params["surname"],dni: params["dni"],email: params["email"],password: params["password"],rol: params["rol"])
        if (params["type"]=="Administrador")
          @newUserName.admin=true
        else
          @newUserName.admin=false
        end
        if @newUserName.save
          redirect "/profile"
        else
          [500, {}, "Internal Server Error"]
          redirect "/create_admin"
        end
      end
    end

    get "/category" do
      @cat  = Category.all
      erb :category, :layout =>@layoutEnUso
    end



    post "/create_category" do
      if cat = Category.find(name: params["name"])
        [500, {}, "ya existe la categoria"]
        redirect "/category"
      else
        cat = Category.new(name: params['name'],description: params['description'] )
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

    post "/select_category" do
      @categor = Category.find(name: params['name'])
      @cat = Category.all
      erb :category, :layout =>@layoutEnUso
    end

    post "/option_category" do
      @cat_sel = Category.find(id: params['id'])
      if params['opcion'] == "modificar"
        @cats = Category.all
        @modificar = true
        erb :category, :layout => @layoutEnUso
      else
        @eliminar = true
        @cats = Category.exclude(id: @cat_sel.id).all
        @allDocs = Document.where(category_id: @cat_sel.id).all
        if @allDocs.empty?
          @cat_sel.remove_all_users
          @cat_sel.delete
          redirect "/category"
        else
          erb :category, :layout => @layoutEnUso
        end
      end
    end

    post "/modify_category" do
      if params['opcion'] == "cancelar"
        redirect"/category"
      else
        if  @catUp = Category.find(id:  params['id'])
          @catUp.update(name: params["name"],description: params["description"])
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
      if params['opcion'] == "cancelar"
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

    get "/subscriptions" do
      @collection = @userName.categories
      @cat = Category.exclude(users: @userName).all
      erb :subscriptions, :layout =>@layoutEnUso
    end

    post "/subscriptions" do
      @userName = User.find(id: session[:user_id])
      @cat = Category.find(name: params['name'])
      if params['option'] == "delete"
        @userName.remove_category(@cat)
        redirect "/subscriptions"
      else
        if @document = Document.where(category_id: @cat.id).all
          if session[:type] == true
            erb :category_documents,:layout =>:layout_admin
          else
            erb :category_documents,:layout =>:layout_users
          end
        else
          [500, {}, "Internal Server Error"]
        end
      end
    end

    post "/add_subscriptions" do
      if @cat = Category.find(name: params['name'])
        @userName = User.find(id: session[:user_id])
        @userName.add_category(@cat)
        redirect"/subscriptions"
      else
        redirect "/subscriptions"
      end
    end

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
      erb:all_documentUser, :layout =>@layoutEnUso
    end

    get "/all_document" do
      @allCat = Category.all
      @userName = User.find(id: session[:user_id])
      filter()
      erb:all_document, :layout =>@layoutEnUso
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
      if !(@docExi= Document.find(name: params['name']) || @docExi= Document.find(description: params['description']))
        @doc = Document.new(name: params['name'], description: params['description'], fileDocument:  direction, category_id: chosenCategory.id, date: date)
        @doc.save
        @notification = Notification.new(description: params['description'], date: dateNot, document_id: @doc.id)
        @notification.save
        @aux = params[:mult]
        @aux &&  @aux.each do |element|
          @doc.add_user(element)
          @notification.add_user(element)

          # @notifactionUsers = NotificationUser.where(notification_id: @notification.id, user_id: element).first;
          # @notifactionUsers.update(seen:true);
        end
        settings.sockets.each do |s|
          @notifactionUsers = NotificationUser.where(notification_id: @notification.id, user_id: s[:id_user])
          if @notifactionUsers
            s[:socket].send("Documento subido")
          end
        end
        redirect "/all_document"
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
    #
    # def webSoquet()
    #
    # end
  end
