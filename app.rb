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
      @user = User.new(name: params['name'],surnames: params['surnames'],dni: params['dni'],userName: params['userName'],password: params['password'],rol: params['rol'])
      if @user.save
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


  get "/profileAdmin" do
    erb:profileAdmin
  end
  post "/create users"do
    redirect "/create_users"
  end
  post "/create category" do
    redirect "/create_category"
  end

end
