require 'sinatra/base'
require "sinatra/config_file"
require './models/user.rb'
class App < Sinatra::Base
  register Sinatra::ConfigFile
  config_file 'config/config.yml'
  configure :development, :production do
    enable :logging
  end
  # Shows how to access to settings configurations
  get "/" do
    logger.info "params"
    logger.info params
    logger.info "--------------"
    logger.info "Configurations"
    logger.info settings.db_adapter
    logger.info "--------------"
    @prueba = "CHAU"
    erb :index
  end

  get "/create_user" do
    erb:create_user
  end
  post "/create_user" do
     user = User.new(name: params['name'],surnames: params['surnames'],dni: params['dni'],userName: params['userName'],password: params['password'])
     if user.save
       "USER CREATED"
       redirect "/profile"
     else
       [500, {}, "Internal Server Error"]
     end
  end
  get "/profile" do
    erb:profile
  end
end
