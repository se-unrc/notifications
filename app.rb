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
    @urlUser = ["/profile","/subscriptions","/tag_document", "/edit_user","/all_document"]
    if !session[:isLogin]  &&  @urlUser.include?(request.path_info)
      redirect "/login"
   end
  end

  before do
    @urlAdmin = ["/category","/selected_document","/create_admin", "/migrate_documents", "create_document"]
    if !session[:type]  &&  @urlAdmin.include?(request.path_info)
       redirect "/profile"
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
    erb :index
  end

  get "/test" do
     if !request.websocket?
       erb:testing
     else
       request.websocket do |ws|
         ws.onopen do
           ws.send("connected!");
           settings.sockets << ws
         end
         ws.onmessage do |msg|
           EM.next_tick { settings.sockets.each {|s| s.send(msg) } }
         end
         ws.onclose do
           warn{"Disconnected"}
           settings.sockets.delete(ws)
         end
       end
     end
   end

  get "/create_user" do
    erb :create_user
  end

  post "/newUser" do
    if user = User.find(email: params["email"])
      [400, {}, "ya existe el usuario"]
    else
      @userName = User.new(name: params["name"],surname: params["surname"],dni: params["dni"],email: params["email"],password: params["password"],rol: params["rol"])
      @userName.admin=false
      if @userName.save
        redirect "/login"
      else
        [500, {}, "Internal Server Error"]
        redirect "/create_user"
      end
    end
  end

  get "/login" do
    erb :login
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
    @document = Document.all
    erb :profile, :layout =>@layoutEnUso
  end

  get "/create_admin" do
    erb :create_admin, :layout =>@layoutEnUso
  end

  post "/newUserAdmin" do
    if user = User.find(email: params["email"])
      [400, {}, "ya existe el usuario"]
    else
      @userName = User.new(name: params["name"],surname: params["surname"],dni: params["dni"],email: params["email"],password: params["password"],rol: params["rol"])
      @userName.admin=false
      if @userName.save
        redirect "/login"
      else
        [500, {}, "Internal Server Error"]
        redirect "/create_user"
      end
    end
  end

  get "/edit_user" do
    erb :edit_user, :layout =>@layoutEnUso
  end

  post "/editNewUser" do
    @userName.update(name: params["name"],surname: params["surname"],dni: params["dni"],password: params["password"],rol: params["rol"])
    if @userName.save
      redirect "/profile"
    else
      redirect "/edit_user"
    end
  end


  get "/create_document" do
      @userCreate = User.all
      @categories = Category.all
      erb:create_document, :layout =>@layoutEnUso
  end

  get "/tag_document" do
    if session[:type]==true
      @document=Document.all#modificar por documetnos taggeados
      erb :profile, :layout =>@layoutEnUso
    else
      redirect "/"
    end
  end


  get "/category" do
      @cat  = Category.all
      erb :category, :layout =>@layoutEnUso
  end

  post "/select_category" do
    @categor = Category.find(name: params['name'])
    @cat = Category.all
    @userName = User.find(id: session[:user_id])
    erb :category, :layout =>@layoutEnUso
  end

  post "/migrate_document" do
    @cat = Category.find(id: params['cat'])
    @aux = params[:name]
    @aux.each do |element|
        @doc = Document.find(name: element)
        @doc.update(category_id: @cat.id)
    end
    redirect "/category"
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
      redirect "/home"
    end
  end

  post "/modify_category" do
    if  @cat = Category.find(name:params["oldName"])
      @cat.update(name: params["name"],description: params["description"])
      if @cat.save
        redirect "/category"
      else
        [500, {}, "Internal Server Error"]
        redirect "/home"
      end
    else
      [500, {}, "Internal Server Error"]
    end
  end

  get "/migrate_documents" do
      erb :migrate_document_category, :layout =>@layoutEnUso
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



  get "/logout" do
    session[:isLogin] = false
    session[:user_id] = 0
    session[:type] = false
    redirect "/"
  end

  post '/create_document' do
    @filename = params[:PDF][:filename]
    @src =  "/public/PDF/#{@filename}"
    file = params[:PDF][:tempfile]
    direction = "PDF/#{@filename}"
    File.open("./public/PDF/#{@filename}", 'wb') do |f|
      f.write(file.read)
    end
    if (Document.find(name: params['name']))
      redirect "/create_document"
    end
    if (Document.find(description: params['description']))
      redirect "/create_document"
    end
    date = Time.now.strftime("%d/%m/%Y %H:%M:%S")
    chosenCategory = Category.find(id: params[:cat])
    @prob = User.all
    @doc = Document.new(name: params['name'], description: params['description'], fileDocument:  direction, category_id: chosenCategory.id, date: date)
    @doc.save
    @aux = params[:mult]
    @aux.each do |element|
      @doc.add_user(element)
    end
    redirect "/all_document"
  end

  post "/delete_document" do
    @pdfDelete = Document.find(id: params[:theId])
    @pdfDelete.remove_all_users
    @pdfDelete.delete
    redirect "/all_document"
  end

  get "/all_document" do
    if params[:filter]
      if Document.find(name: params[:filter])
        @allPdf = [Document.find(name: params[:filter])]
        erb:all_document, :layout =>@layoutEnUso
      end
    else
      @allPdf = Document.order(:name)
      erb:all_document, :layout =>@layoutEnUso
    end
  end

  post "/selected_document" do
    @userName = User.find(id: session[:user_id])
    @allCat = Category.all
    @userCreate = User.all
    @axu= params[:pdf]
    erb :selected_document, :layout => :layout_admin
  end

  post "/modify_document" do
    @userName = User.find(id: session[:user_id])
    if (params[:name])
      @new = Document.find(id: params[:theId])
      @new.update(name: params[:name])
    end
    if (params[:description])
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
end
