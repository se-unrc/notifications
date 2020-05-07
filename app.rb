require 'json'
require './models/init.rb'
include FileUtils::Verbose
class App < Sinatra::Base
  
  configure :development, :production do
    enable :logging
    enable :session
    set :session_secret, "secret"
    set :sessions, true
  end

  get "/" do 
    @documents = Doc.all
    logger.info ""
    logger.info session["session_id"]
    logger.info session.inspect
    logger.info "-------------"
    logger.info ""

  if session[:user_id] 
      erb :docs, :layout => :layoutIn
    else
  	 erb :docs, :layout => :layout
    end
  end

  get "/aboutus" do
	 erb :aboutus, :layout => :layout
  end

  get "/login" do
    session.clear
    erb :login, :layout => :layout
  end	
	 
  get "/signup" do
    session.clear
    erb :signup, :layout => :layout
  end	

  get "/forgotpass" do
    erb :forgotpass, :layout => :layout
  end

  get "/suscribe" do
    if session[:user_id] 
      @categories = Categorie.all
      erb :suscat, :layout => :layoutIn
    else
      redirect '/login'
    end
  end

  get "/upload" do
    if session[:usertype] == 'superadmin' || session[:usertype] == 'admin'
      @categories = Categorie.all
      erb :upload, :layout => :layoutIn
    else
      redirect '/'
    end
  end

  get "/newadmin" do
    if session[:usertype] == 'superadmin'  || session[:usertype] == 'admin'  
      erb :newadmin, :layout=> :layoutIn
    else
      redirect '/'
    end
  end

  get "/categories" do
    if session[:user_id] 
      my_suscriptions = Subscription.select(:cat_id).where(user_id: session[:user_id])
      @categories = Categorie.where(id: my_suscriptions)
      erb :yourcats, :layout=> :layoutIn
    else
      redirect '/login'
    end
  end

  get "/deletecat" do
    if session[:user_id] 
      my_suscriptions = Subscription.select(:cat_id).where(user_id: session[:user_id])
      @categories = Categorie.where(id: my_suscriptions)
      erb :deletecats, :layout=> :layoutIn
    else
      redirect '/login'
    end

  end


  get '/logout' do 
    session.clear
    redirect '/login'
  end

  get "/profile" do
    set_user
    @categories = Categorie.all
    if session[:user_id] 
      erb :profile, :layout => :layoutIn
    else
      redirect '/login'
    end
  end

  post '/login' do
      usuario = User.find(username: params[:username])
      if usuario && usuario.password == params[:password]
        session[:user_id] = usuario.id
        session[:usertype]=usuario.type
        session[:user_name]=usuario.name
        set_user
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
          session[:usertype]=user.type
          session[:user_name]=user.name
          set_user
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

    doc = Doc.new(date: params["date"], name: params["title"], users: params["users"], categories: params["categories"], document: params["document"])
    if doc.save
      redirect "/profile"
    else 
      [500, {}, "Internal server Error"]
    end 

  end 


  post '/suscribe' do
      categorie = Categorie.select(:id).where(name: params[:categorie])
      if  Subscription.find(user_id: session[:user_id],cat_id: categorie)
          @success ="You are already subscribed to #{params[:categorie]}!"
          @categories = Categorie.all
          erb :suscat, :layout => :layoutIn
      else
        suscription = Subscription.new(user_id: session[:user_id],cat_id: categorie)  
        if suscription.save
          @success ="Now you are subscribed to #{params[:categorie]}!"
          @categories = Categorie.all
          erb :suscat, :layout => :layoutIn
        else
          [500, {}, "Internal server Error"]
        end
      end
  end

  post '/newadmin' do
    if User.find(username: params[:username])
      User.where(username: params[:username]).update(type: 'admin')
       @success = "The user has been promoted to admin"
       erb  :newadmin, :layout => :layoutIn
    else 
      @error = "An error has ocurred when trying to promote the user to admin"
      erb  :newadmin, :layout => :layoutIn
    end
  end

  post '/deletecat' do
    idcat = Categorie.select(:id).where(name: params[:categorie])
    susc = Subscription.where(user_id: session[:user_id],cat_id: idcat)
    if susc.delete
      @success = "The category has been removed"
      my_suscriptions = Subscription.select(:cat_id).where(user_id: session[:user_id])
      @categories = Categorie.where(id: my_suscriptions)
      erb  :deletecats, :layout => :layoutIn
    else
      @error = "An error has ocurred when trying remove the category"
      my_suscriptions = Subscription.select(:cat_id).where(user_id: session[:user_id])
      @categories = Categorie.where(id: my_suscriptions)
      erb  :deletecats, :layout => :layoutIn
    end
  end

  def set_user
    @visibility = "inline"
    if session[:usertype] == 'user'
        @visibility = "none"
    end
  end

end 
