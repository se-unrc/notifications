require 'sinatra/base'
require "sinatra/config_file"
require './models/init.rb'

class App < Sinatra::Base
  register Sinatra::ConfigFile

  config_file 'config/config.yml'

  configure :development, :production do
    enable :logging
    enable :session
    set :session_secret, "5fdh4h8f4jghne27w84ew4r882&(asd/&h$gfj&hdkjfjew48y49t4hgrd56g8u84gfmjhdmhh,xg544ncd"
    set :sessions, true
  end


  get "/" do
    logger.info "params"
    logger.info params
    logger.info "--------------"
    logger.info session["session_id"]
    logger.info session.inspect
    logger.info "Configurations"
    logger.info settings.db_adapter
    logger.info "--------------"
    erb :index
  end


  get "/login" do
    erb :login
  end
  post "/userLogin" do
    if @usuario = User.find(username: params["username"])
      if @usuario.password == params["password"]
        session[:isLogin] = true
        session[:user_id] = @usuario.id
        session[:int] = @usuario.admin
        if session[:int] == 0
          redirect "/profileAdmin"
        else
          redirect "/profile"
        end
      else
        @error ="Your password is incorrect"
      end
    else
      @error ="Your username is incorrect"
    end
  end

  get "/create_user" do
    erb :create_user
  end
  post "/newUser" do
    if user = User.find(username: params["username"])
      [400, {}, "ya existe el usuario"]
    else
      @user = User.new(name: params["name"],surnames: params["surnames"],dni: params["dni"],username: params["username"],password: params["password"],rol: params["rol"])
      @user.admin=5
      if @user.save
        redirect "/login"
      else
        [500, {}, "Internal Server Error"]
        redirect "/create_user"
      end
    end
  end


  get "/profile" do
    if session[:isLogin]
      @document = Document.all
      erb :profile
    else
      redirect "/"
    end
  end
  get "/profileAdmin" do
    if session[:isLogin] && session[:int]==0
      @document = Document.all
      erb :profileAdmin
    else
      redirect "/"
    end
  end


  get "/edit_user" do
    if  session[:isLogin]
      @userEdit= User.find(id: session[:user_id])
      erb :edit_user
    else
      redirect "/"
    end
  end
  post "/editNewUser" do
    userEdit= User.find(id: session[:user_id])
    userEdit.update(name: params["name"],surnames: params["surnames"],dni: params["dni"],password: params["password"],rol: params["rol"])
    if userEdit.save
      redirect "/profile"
    else
      redirect "/edit_user"
    end
  end


  get "/create_document" do
    if session[:isLogin] && session[:int]==0
      @userCreate = User.all
      @categories = Category.all
      erb:create_document
    else
      if session[:isLogin]
        redirect "/profile"
      else
        redirect "/"
      end
    end
  end
  post '/create_document' do
    @filename = params[:PDF][:filename]
    @src =  "/PDF/#{@filename}"
    file = params[:PDF][:tempfile]
    prob = "PDF/#{@filename}"
    File.open("./PDF/#{@filename}", 'wb') do |f|
      f.write(file.read)
    end
    chosenCategory = Category.find(id: params[:cat])
    document = Document.new(name: params['name'], description: params['description'], date: params['date'], category_id: chosenCategory.id, fileDocument:  prob)
    document.save
    redirect "/create_category"
  end


  get "/tag_document" do
    if session[:isLogin]
      @document=Document.all#modificar por documetnos taggeados
      erb :profile
    else
      redirect "/"
    end
  end


  get "/category" do
    if session[:isLogin] && session[:int]==0
      erb :category
    else
      redirect "/"
    end
  end
  get "/create_category" do
    if session[:isLogin] && session[:int]==0
      @userCreate = User.all
      @categories = Category.all
      erb :create_category
    else
      if session[:isLogin]
        redirect "/profile"
      else
        redirect "/"
      end
    end
  end
  post "/create_category" do
    if cat = Category.find(name: params["name"])
      [500, {}, "ya existe la categoria"]
      redirect "/profileAdmin"
    else
      cat = Category.new(name: params['name'],description: params['description'] )
      if cat.save
        redirect "/category"
      else
        [500, {}, "Internal Server Error"]
        redirect "/profile"
      end
    end
  end


  get "/delete_category" do
    if session[:isLogin] && session[:int]==0
      erb:delete_category
    else
      if session[:isLogin]
        redirect "/profile"
      else
        redirect "/"
      end
    end
  end
  post "/delete_category" do
    if cat = Category.find(name:params["name"])
      cat.delete
      redirect "/category"
    else
      [500, {}, "No existe la Categoria"]
      redirect "/profile"
    end
  end


  get "/search_category" do
    if session[:isLogin]
      erb:search_category
    else
      redirect "/"
    end
  end
  post "/search_category" do
    if cat = Category.find(name:params["name"])
      [500, {}, "existe la Categoria"]
    else
      [500, {}, "No existe la Categoria"]
    end
  end


  get "/modify_category" do
    if session[:isLogin] && session[:int]==0
      erb:modify_category
    else
      if session[:isLogin]
        redirect "/profileAdmin"
      else
        redirect "/"
      end
    end
  end
  post "/modify_category" do
    cat = Category.find(name:params["oldName"])
    cat.update(name: params["name"],description: params["description"])
    if cat.save
      redirect "/category"
    else
      [500, {}, "Internal Server Error"]
      redirect "/profileAdmin"
    end
  end

  get "/home" do
    if session[:isLogin]
      if session[:int]==0
        redirect "/profileAdmin"
      else
        redirect "/profile"
      end
    else
      redirect "/"
    end
  end
  get "/logout" do
    session[:isLogin] = false
    redirect "/"
  end

end
