require 'sinatra/base'
require "sinatra/config_file"
require './models/user.rb'
require './models/document.rb'
require 'sinatra-websocket'

class App < Sinatra::Base
  register Sinatra::ConfigFile

  config_file 'config/config.yml'

  configure :development, :production do
    enable :logging
    enable :sessions
    set :session_secret, "So0perSeKr3t!"
    set :sessions, true
    set :server, :thin
    set :sockets, []
    
  end

 before do
    @path = request.path_info
    if !session[:user_id] && @path != '/login' && @path != '/register'
      redirect '/login'
    elsif session[:user_id]
      @user = User.find(id: session[:user_id])
    end
  end

  use Rack::Session::Pool, :expire_after => 2592000

  get "/" do
    logger.info "Session inicilized"
    logger.info session["session_id"]
    logger.info session.inspect
    logger.info session[:user_id]
    logger.info "--------------"
    logger.info ""
  	erb :index, :layout => :layoutlogin
  end

  get "/test" do
    if !request.websocket?
      erb:testing
    else
      request.websocket do |ws|
        ws.onopen do
          ws.send("connected!");
          settings.sockets << ws
        end
        ws.onmessage do |msg|
          EM.next_tick { settings.sockets.each {|s| s.send(msg) } }
        end
        ws.onclose do
          warn{"Disconnected"}
          settings.sockets.delete(ws)
        end
      end
    end
  end
 
  # Add new user
  get "/register" do
    erb :register
  end

  post '/register' do
   if User.find(username: params[:username])
    @error = "El Usuario ya existe"
    erb :register
    else
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
  end
  # Login Endpoints
  get "/login" do
    erb :login
  end

  post '/login' do
    users = User.find(username: params[:username])
    if users && users.password == params[:password]
      session[:user_id] = users.id
      redirect "/"
    else
      @error = "Usuario o contraseña incorrecta"
      erb :login
    end
  end

  get '/logout' do
    session.clear
    # response.set_cookie("user_id", value: "", expires: Time.now - 100 )
    redirect '/'
  end

  # Endpoints for handles profile
  get "/profile" do
    erb :perfil , :layout => :layoutlogin
  end

  # Endpoints for upload a document
  get '/documents' do
    user = User.find(id: session[:user_id]).type
    if user == 'admin'
      @documents = Document.all
      erb :upload, :layout => :layoutlogin
    else
      @error = "Para acceder a documentos debe ser administrador, si desea serlo complete los campos"
      erb :admin , :layout => :layoutlogin
    end
  end

  post '/documents' do
    user = User.first(username: params[:users])
    filter_docs = Document.all

    doc_date = params[:date] == "" ? filter_docs : Document.first(date: params[:date])
    filter_docs = params[:date] == "" ? filter_docs : filter_docs.select {|d| d.date == doc_date.date }
    @documents = filter_docs
    erb :upload, :layout => :layoutlogin
  end

  get '/showdocument' do
    erb :show_file, :layout => :layoutlogin
  end

  post '/save_documents' do
      @filename = params[:file][:filename]
      file = params[:file][:tempfile]
      File.open("./public/#{@filename}", 'wb') do |f|
        f.write(file.read)
      end
      user = User.find(id: session[:user_id]).username
      doc = Document.new(name: @filename, date: params["date"] , uploader: user, subject: params["subject"])
      if doc.save
        redirect "/documents"
      else
        [500, {}, "Internal Server Error"]
      end
  end

  get '/view/:doc_name' do
      @this_doc = "/" +params[:doc_name]
      erb :view_doc, :layout => :layoutlogin
  end

  get '/remove/:doc_name' do
      docu = Document.where(name: params[:doc_name])
      docu.delete
      if docu.delete
        redirect "/documents"
      else
        [500, {}, "Internal Server Error"]
      end
  end

  get "/admin" do
    erb :admin, :layout => :layoutlogin
  end

  post '/admin' do
    if User.find(username: params[:username])
      codigo = params[:text]
        if codigo == 'admin'
          User.where(username: params[:username]).update(type: 'admin')
          erb :perfil, :layout => :layoutlogin
        else
          @error = "código incorrecto"
          erb :admin , :layout => :layoutlogin
        end
    else
      @error = "Hay algo mal que no está bien"
    end
  end

  ###
  get "/tos" do
  	erb :ToS, :layout => :layoutlogin
  end

  get "/aboutus" do
    erb :aboutus, :layout => :layoutlogin
  end

  get "/contactus" do
    erb :contactus, :layout => :layoutlogin
  end

  # Terminar de implementar
  post "/contactus" do
    "GRACIAS"
  end

  get '/tag' do
    erb :tag, :layout => :layoutlogin
  end

  get "/document_upload" do
    erb :document_upload, :layout => :layoutlogin
  end

end
