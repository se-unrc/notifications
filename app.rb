require 'sinatra/base'
require "sinatra/config_file"
require './models/init.rb'
class App < Sinatra::Base
  register Sinatra::ConfigFile
  config_file 'config/config.yml'
  configure :development, :production do
    enable :logging
  end

  get "/" do # Shows how to access to settings configurations
    logger.info "params"
    logger.info params
    logger.info "--------------"
    logger.info "Configurations"
    logger.info settings.db_adapter
    logger.info "--------------"
    erb:index
  end


  get "/index" do
    erb:index
  end
  post "/newLogin" do
    redirect "/login"
  end
  post "/newUser" do
    redirect "/create_user"
  end



  get "/login" do
    erb :login
  end
  post "/userLogin" do
    @usuario = User.find(userName: params["userName"])
    if @usuario.password == params["password"]
      if @usuario.admin == 0
        redirect "/profileAdmin"
      else
        redirect "/profile"
      end
    else
      @error ="Your username o password is incorrect"
      redirect "/login"
    end
  end



  get "/create_user" do
    erb:create_user
  end
  post "/newCreateUser" do
    if user1 = User.find(userName: params["userName"])
      [500, {}, "ya existe el usuario"]
    else
      @user = User.new(name: params['name'],surnames: params['surnames'],dni: params['dni'],userName: params['userName'],password: params['password'],rol: params['rol'])
      @user.admin=5
      if @user.save
        redirect "/profile"
      else
        [500, {}, "Internal Server Error"]
        redirect "/create_user"
      end
    end
  end



  get "/create__users" do
    erb:create__users
  end
  post "/newCreatesUsers" do
    if user2 = User.find(userName: params["userName"])
      [500, {}, "ya existe el usuario"]
    else
      @users = User.new(name: params['name'],surnames: params['surnames'],dni: params['dni'],userName: params['userName'],password: params['password'],rol: params['rol'], admin: params['admin'])
      if @users.save
        redirect "/profileAdmin"
      else
        @error ="Ydsgfdsghgf"
        redirect "/create__users"
      end
    end
  end



  get "/profile" do
    erb:profile
  end



  get "/profileAdmin" do
    erb:profileAdmin
  end
  post "/create users" do
    redirect "/create__users"
  end
  post "/create document" do
    redirect "/create_document"
  end
  post "/create category" do
    redirect "/create_category"
  end



  get "/create_document" do
    @userCreate = User.all
    @categories = Category.all
    erb:create_document
  end

  post '/create_document' do
    logger.info "params"
    logger.info params
    logger.info "--------------"
    @filename = params[:PDF][:filename]
    @src =  "/PDF/#{@filename}"
    file = params[:PDF][:tempfile]
    prob = "PDF/#{@filename}"
    File.open("./PDF/#{@filename}", 'wb') do |f|
      f.write(file.read)
    end
    chosenCategory = Category.find(id: params[:cat])
    document = Document.new(name: params['name'], description: params['description'], date: params['date'], category_id: chosenCategory.id, fileDocument:  prob)
    document.save
    redirect "/category"
  end

  get "/create_category" do
    erb:create_category
  end
  post "/newCategory" do
    if cat = Category.find(name: params["name"])
      [500, {}, "ya existe la categoria"]
      redirect "/create_category"
    else
      cat = Category.new(name: params['name'],description: params['description'] )
      if cat.save
        redirect "/create_category"
      else
        [500, {}, "Internal Server Error"]
        redirect "/create_category"
      end
    end
  end
  post "/delete_category" do
    if cat = Category.find(name:params["name"])
      cat.delete
      redirect "/create_category"
    else
      @error ="No existe la Categoria"
      [500, {}, "No existe la Categoria"]
    end
  end
  post "/search_category" do
    if cat = Category.find(name:params["name"])
      #redirect "/modify_category"
    else
      @error ="No existe la Categoria"
      [500, {}, "No existe la Categoria"]
    end
  end
  get "/modify_category" do
    erb:modify_category
  end
  post "/modify_category" do
    @cat = Category.find(name:params["oldName"])
    @cat.update(name: params["name"],description: params["description"])
    if @cat.save
      redirect "/create_category"
    else
      @error ="No existe la Categoria"
      [500, {}, "Internal Server Error"]
      redirect "/profile"
    end
  end

end
