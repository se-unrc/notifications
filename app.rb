require 'sinatra/base'
require "sinatra/config_file"
require './models/user.rb'
class App < Sinatra::Base
  register Sinatra::ConfigFile

  config_file 'config/config.yml'

  configure :development, :production do
    enable :logging
  end
  
  get "/" do
    erb :index, :layout => :layout
  end
  get "/register" do
    erb :register
  end
  post '/register' do
   request.body.rewind
    hash = Rack::Utils.parse_nested_query(request.body.read)
    params = JSON.parse hash.to_json 
    user = User.new(name: params["name"], email: params["email"], username: params["username"], password: params["psw"])
    if user.save
      redirect "/login"
    else
      [500, {}, "Internal Server Error"]
    end
  end
  post '/tag' do
    erb :tag
  end
  get '/registersuccess' do
    erb :registerlandingpage
  end
  post '/loginsuccess' do
    erb :loginlandingpage, :layout => :layoutlogin
  end
  get "/login" do
    erb :login
  end
  get '/login' do
    erb :login
  end
  get "/upload" do
  	erb :upload
  end
  get "/aboutus" do
    erb :aboutus
  end
  get "/contactus" do
    erb :contactus
  end
  get "/perfil" do
    erb :perfil, :layout => :layoutlogin
  end
  post '/perfil' do
    erb :perfil, :layout => :layoutlogin
  end
  post '/save_documents' do
    @filename = params[:file][:filename]
    file = params[:file][:tempfile]
    File.open("./public/#{@filename}", 'wb') do |f|
    f.write(file.read)
    end
    erb :tag
  end
  get "/tos" do
  	erb :ToS
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
