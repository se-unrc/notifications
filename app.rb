require 'sinatra/base'
require "sinatra/config_file"
require './models/user.rb'

class App < Sinatra::Base
  register Sinatra::ConfigFile

  config_file 'config/config.yml'

  configure :development, :production do
    enable :logging
    enable :sessions
    set :session_secret, "So0perSeKr3t!"
    set :sessions, true
  end

  use Rack::Session::Pool, :expire_after => 2592000

  get "/" do
    logger.info "Session inicilized"
    logger.info session["session_id"]
    logger.info session.inspect
    logger.info session[:user_id]
    logger.info "--------------"
    logger.info ""
  	erb :index, :layout => :layout
  end

  # Add new user
  get "/register" do
    if !session[:user_id]
      erb :register
    else
      redirect "/profile"
    end
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

  # Login Endpoints
  get "/login" do
    if !session[:user_id]
      erb :login
    else
      redirect "/profile"
    end
  end

  post '/login' do
    users = User.find(username: params[:username])
    if users && users.password == params[:password]
      session[:user_id] = users.id
      redirect "/profile"
    else
      erb :login
    end
  end

  get '/logout' do
    session.clear
    # response.set_cookie("user_id", value: "", expires: Time.now - 100 )
    redirect '/'
  end

  #############################
  get '/registersuccess' do
    erb :registerlandingpage
  end

  post '/sign_in' do
    if User.last.id
      session[:user_id] = User.last.id
      [200, {"Content-Type" => "text/plain"}, ["You're logged in"]]
    else
      # halt 401, 'go away!'
      [400, {"Content-Type" => "text/plain"}, ["Unautorized"]]
    end
  end

  # Endpoints for handles profile
  get "/profile" do
    erb :perfil , :layout => :layoutlogin
  end

  post '/profile' do
    erb :perfil, :layout => :layoutlogin
  end

  # Endpoints for upload a document
  get '/documents' do
    if !session[:user_id]
      erb :login
    else
      erb :upload, :layout => :layoutlogin
    end
  end
  get '/showdocument' do
    erb :show_file
  end

  post '/save_documents' do
    @filename = params[:file][:filename]
    file = params[:file][:tempfile]
    File.open("./public/#{@filename}", 'wb') do |f|
      f.write(file.read)
    end
    erb :tag
  end

  ###
  get "/tos" do
  	erb :ToS
  end

  get "/aboutus" do
    erb :aboutus
  end

  get "/contactus" do
    erb :contactus
  end

  post '/tag' do
      erb :tag
  end

end
