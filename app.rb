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
  end



  get "/index" do
    erb:index
  end
  post "/log in" do
    redirect "/login"
  end
  post "/create user" do
    redirect "/create_user"
  end
  get "/login" do
    erb :login
  end

  post "/login" do
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
  post "/create_user" do
    if user2 = User.find(userName: params["userName"])
      [500, {}, "ya existe el usuario"]
    else
      user = User.new(name: params['name'],surnames: params['surnames'],dni: params['dni'],userName: params['userName'],password: params['password'])
      if user.save
           redirect "/profile"
       else
           [500, {}, "Internal Server Error"]
           redirect "/create_user"
      end
    end
  end
  get "/create_users" do
    erb:create_users
  end
  post "/create_users" do
    if user2 = User.find(userName: params["userName"])
      [500, {}, "ya existe el usuario"]
    else
      @user = User.new(name: params['name'],surnames: params['surnames'],dni: params['dni'],userName: params['userName'],password: params['password'],rol: params['rol'], admin: [admin])
      if @user.save
          redirect "/profile"
       else
           [500, {}, "Internal Server Error"]
           redirect "/create_user"
      end
    end
  end

  get "/profile" do
    erb:profile
  end
  #post....

  get "/profileAdmin" do
    erb:profileAdmin
  end
  post "/create users"do
    redirect "/create_users"
  end
  post "/create category" do
    redirect "/category"
  end
  post "/create document" do
   redirect "/create_document"
 end


  get "/create_document" do
    @userCreate = User.all
    @categories = Category.all
    erb:create_document
  end
  post "createdocument" do
    @filename = params[:PDF][:filename]
    file = params[:PDF][:tempfile]
    File.open("./PDF/#{@filename}", 'wb') do |f|
      f.write(file.read)
    end
    @filename
      #chosenTagged = params[:tagged]
      #chosenCategory = Category.find(name: params[:category])
      #document = Document.new(name: params[name], file: params[file], description: params[description], category_id: chosenCategory.id)
      #document.save
      #chosenTagged.each do |element|
      #  doc_us = Document_user.new(document_id: document.id, user_id: element.id)
      #  doc_us.save
      #end
      redirect "/create_document"
  end


  get "/category" do
    erb:category
  end
  post "/category" do
    if cat = Category.find(name: params["name"])
      [500, {}, "ya existe la categoria"]
      redirect "/category"
    else
      cat = Category.new(name: params['name'],description: params['description'] )
      if cat.save
           redirect "/category"
       else
           [500, {}, "Internal Server Error"]
           redirect "/category"
      end
    end
  end
  post "/delete_category" do
    if cat = Category.find(name:params["name"])
       cat.delete
       redirect "/category"
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
      cat = Category.find(name:params["oldName"])
      cat.update(name: params["name"],description: params["description"])
      if cat.save
        redirect "/category"
      else
        @error ="No existe la Categoria"
        [500, {}, "Internal Server Error"]
        redirect "/profile"
      end
    end

end
