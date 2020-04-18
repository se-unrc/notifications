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

    # DB[:users]
    User.all.to_json
  end

  # Create an user
  post "/users" do
    request.body.rewind

    params = JSON.parse request.body.read

    # User.create(name: name)
    user = User.new(name: params['name'])
    if user.save
      "USER CREATED"
    else
      [500, {}, "Internal Server Error"]
    end
  end
end
