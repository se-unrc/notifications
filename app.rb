require 'sinatra/base'
require "sinatra/config_file"
require './models/user.rb'
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

  get "/login" do
    erb :login
  end
  post "/login" do
    usuario = User.find(userName: params["userName"])
    if usuario.password == params["password"]
      redirect "/profile"
    else
      @error ="Your username o password is incorrect"
      redirect "login"
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

  get "/profile" do
    erb:profile
  end

  get "/create_category" do
    erb:create_category
  end
end
