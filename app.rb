require 'sinatra/base'
require "sinatra/config_file"

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

  # Shows how to grab a path params
  get "/hello/:name" do
    "Hello #{params['name']}"
  end

  # Returns information to user :id
  get "/users/:id" do
    logger.info "/users/:id"
    logger.info params
    logger.info "----"
  end

  # Lists all users (usually called user index)
  get "/users" do
    logger.info "/users"
    logger.info params
    logger.info "----"
    DB[:users]
  end

  # Create an user
  post "/users" do
    logger.info "--------"
    logger.info params
    logger.info JSON.parse(request.body.read)
    logger.info "--------"

    "USER CREATED"
  end
end
