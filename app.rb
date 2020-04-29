require 'sinatra/base'
require "sinatra/config_file"
require './models/user.rb'

class App < Sinatra::Base
  register Sinatra::ConfigFile

  config_file 'config/config.yml'

  configure :development, :production do
    enable :logging
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
  get "/register" do
    erb :register
  end
  get '/registersuccess' do
    erb :registerlandingpage
  end
  post '/loginsuccess' do
    erb :loginlandingpage
  end
  get "/login" do
    erb :login
  end
  get "/upload" do
  	erb :upload
  end
  post '/upload' do
    erb :tag
  end
  get "/tos" do
  	erb :ToS
  end
  get "/forgotpw" do
    erb :recoverpw
  end
  get "/index" do
    erb :index
  end
  get "/users" do
  	logger.info '/users'
  	logger.info params
  	logger.info '----'
  end
  get "/hello/:name" do
  	"Hi #{params['name']}"

  end
  post "/users/add" do
  	logger.info "----"
  	logger.info params
  	logger.info JSON.parse(request.body.read)
  	logger.info "------"
  	
  end
  get "/posts" do
  	# matches "GET /posts?title=foo&author=bar"
  	title = params["title"]
  	author = params["author"]
  	# uses title and author variables:query is optional to the /posts route
  end
 
end
