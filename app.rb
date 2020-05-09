require 'json'
require './models/init.rb'
include FileUtils::Verbose
class App < Sinatra::Base
  
  configure :development, :production do
    enable :logging
    enable :session
    set :session_secret, "otro secret pero dificil y abstracto"
    set :sessions, true
  end

  before do
    request.path_info
    @logged2 = session[:user_id] ? "none" : "inline"
    @logged = session[:user_id] ? "inline" : "none"
    if !session[:user_id] && request.path_info != '/login' && request.path_info != '/' && request.path_info != '/signup' && request.path_info != '/aboutus'
      redirect 'login'
    elsif session[:user_id] 
      user = User.find(id: session[:user_id])
      @visibility = user.type == "user" ? "none" : "inline"
      if request.path_info == '/login' || request.path_info == '/signup'
        session.clear
        redirect request.path_info
      elsif request.path_info == '/newadmin' || request.path_info == '/upload'
        user = User.find(id: session[:user_id])
        redirect '/'     
      end
    end
  end

  get "/" do 
    @documents = Document.all
    logger.info ""
    logger.info session["session_id"]
    logger.info session.inspect
    logger.info "-------------"
    logger.info ""
  	
    erb :docs, :layout => :layout
  end

  get "/aboutus" do
   erb :aboutus, :layout => :layout
  end

  get "/login" do
    erb :login, :layout => :layout
  end	
	 
  get "/signup" do
    erb :signup, :layout => :layout
  end	

  get "/forgotpass" do
    erb :forgotpass, :layout => :layout
  end

  get "/suscribe" do
      @categories = Category.all
      erb :suscat, :layout => :layout
  end

  get "/upload" do
    @categories = Category.all
    erb :upload, :layout => :layout
  end

  get "/newadmin" do
    erb :newadmin, :layout=> :layout
  end

  get "/categories" do
    user = User.find(id: session[:user_id])
    @categories =  user.categories_dataset
    erb :yourcats, :layout=> :layout
  end

  get "/deletecat" do
    user = User.find(id: session[:user_id])
    @categories =  user.categories_dataset
    erb :deletecats, :layout=> :layout

  end


  get '/logout' do 
    session.clear
    redirect '/login'
  end

  get "/profile" do
    @categories = Category.all
    erb :profile, :layout => :layout
  end

  post '/login' do
      usuario = User.find(username: params[:username])
      if usuario && usuario.password == params[:password]
        session[:user_id] = usuario.id
        redirect "/"
      else
        @error ="Your username o password is incorrect"
        erb :login, :layout => :layout
      end
  end


  post '/signup' do
    
    if User.find(username: params[:username])
      @error = "The username is already in use"
      erb :signup, :layout => :layout
    elsif   User.find(email: params[:email])                                                                                               
      @error = "The email is already in use"
      erb :signup, :layout => :layout
    elsif params[:password] != params[:confPassword]
      @error = "Passwords are not equal"
      erb :signup, :layout => :layout
    else
      request.body.rewind

      hash = Rack::Utils.parse_nested_query(request.body.read)
      params = JSON.parse hash.to_json 
      user = User.new(name: params["fullname"], email: params["email"], username: params["username"], password: params["password"])
      if user.save
          session[:user_id] = user.id
          redirect "/"
      else 
        [500, {}, "Internal server Error"]
      end 
    end
  end

  post '/upload' do
    request.body.rewind

    hash = Rack::Utils.parse_nested_query(request.body.read)
    params = JSON.parse hash.to_json 

    doc = Document.new(date: params["date"], name: params["title"], users: params["users"], categories: params["categories"], document: params["document"])
    if Document.save
      redirect "/profile"
    else 
      [500, {}, "Internal server Error"]
    end 

  end 


  post '/suscribe' do
    user = User.first(id: session[:user_id])
    category = Category.first(name: params["categories"])
    if user && category# && ver que no exista
          category.add_user(user)
          category.save
          @success ="Now you are subscribed to #{params[:categories]}!"
          @categories = Category.all
          erb :suscat, :layout => :layout
    else
          @error ="You are already subscribed to #{params[:categories]}!"
          @categories = Category.all
          erb :suscat, :layout => :layout
    end
  end

  post '/newadmin' do
    if User.find(username: params[:username])
      User.where(username: params[:username]).update(type: 'admin')
       @success = "The user has been promoted to admin"
       erb  :newadmin, :layout => :layout
    else 
      @error = "An error has ocurred when trying to promote the user to admin"
      erb  :newadmin, :layout => :layout
    end
  end

  post '/deletecat' do
    user = User.first(id: session[:user_id])
    category = Category.first(name: params["category"])
    if user && category && user.remove_category(category)
      @success = "The category has been removed"
      user = User.find(id: session[:user_id])
      @categories =  user.categories_dataset
      erb  :deletecats, :layout => :layout
    else
      @success = "An error has ocurred when trying remove the category"
      user = User.find(id: session[:user_id])
      @categories =  user.categories_dataset
      erb  :deletecats, :layout => :layout
    end
  end
end 
