require 'json'
require './models/init.rb'
require 'date'
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
    @logged2 = session[:user_id] ? "none" : "inline-block"
    @logged = session[:user_id] ? "inline-block" : "none"
    if !session[:user_id] && request.path_info != '/login' && request.path_info != '/' && request.path_info != '/signup' && request.path_info != '/aboutus' &&  request.path_info != '/preview'
      redirect 'login'
    elsif session[:user_id] 
      user = User.find(id: session[:user_id])
      @visibility = user.type == "user" ? "none" : "inline"
      if request.path_info == '/login' || request.path_info == '/signup'
        session.clear
        redirect request.path_info
      elsif user.type == "user" && (request.path_info == '/newadmin' || request.path_info == '/upload')
        user = User.find(id: session[:user_id])
        redirect '/'     
      end
    end
  end

  get "/" do 
    logger.info ""
    logger.info session["session_id"]
    logger.info session.inspect
    logger.info "-------------"
    logger.info ""
  	
    @categories = Category.all
    @documents = Document.all
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

  get '/documents' do
    user = User.find(id: session[:user_id])
    @documents = user.documents_dataset
    erb :yourdocs, :layout=> :layout
  end

  get "/deletecat" do
    user = User.find(id: session[:user_id])
    @categories =  user.categories_dataset
    erb :deletecats, :layout=> :layout
  end

  get '/preview' do

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
    if params["password"] != "" && params["username"] != ""
      usuario = User.find(username: params[:username])
      if usuario && usuario.password == params[:password]
        session[:user_id] = usuario.id
        redirect "/"
      else
        @error ="Your username o password is incorrect"
        erb :login, :layout => :layout
      end
    else 
        @error ="All fields are necessary"
        erb :login, :layout => :layout
    end
  end

      
  post '/signup' do
    if params["fullname"] != "" && params["username"] != "" &&  params["password"] != "" && params["confPassword"] != "" &&  params["email"] != ""    
      if User.find(username: params[:username]) || /\A\w{3,15}\z/ !~ params[:username]
        @error = "The username is already in use or its invalid"
        erb :signup, :layout => :layout
      elsif   User.find(email: params[:email]) ||  /\A.*@.*\..*\z/ !~ params[:email]                                                                                              
        @error = "The email is invalid"
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
    else 
      @error = "All fields are necessary"
      erb :signup, :layout => :layout
    end
  end

# app.rb 
  post '/upload' do
    
    if params["date"] != "" && params["title"] != ""  && params["categories"] != "" && params["document"] != ""  
     
      @filename = params[:document][:filename]
      file = params[:document][:tempfile]
      cp(file.path, "public/file/#{@filename}")
      @src =  "/file/#{@filename}"
      
      category = Category.first(name: params["categories"])
      doc = Document.new(date: params["date"], name: params["title"], userstaged: params["users"], categorytaged: params["categories"], document: @src,category_id: category.id)
      if doc.save
        doc = Document.first(date: params["date"], name: params["title"], userstaged: params["users"], categorytaged: params["categories"], document: @src)
        
        usuario = params["users"].split(',')
        usuario.each do |userr|
        user = User.first(username: userr)
          if user 
            user.add_document(doc)
            user.save
          end
        end
        @success = "The document has been uploaded"
        @categories = Category.all
        erb :upload, :layout => :layout
      else 
        @error = "An error has ocurred when trying to uload the document"
        @categories = Category.all
        erb :upload, :layout => :layout
      end 
    else
        @error = "All fields are necessary"
        @categories = Category.all
        erb :upload, :layout => :layout
    end 


  end

  post '/suscribe' do
    user = User.first(id: session[:user_id])
    category = Category.first(name: params["categories"])
    if user && category 
          category.add_user(user)
          if category.save
            @success ="Now you are subscribed to #{params[:categories]}!"
            @categories = Category.all
            erb :suscat, :layout => :layout
          else
            @error ="You are already subscribed to #{params[:categories]}!"
            @categories = Category.all
            erb :suscat, :layout => :layout
          end
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

  post '/' do
    user = User.first(username: params[:users])
    prueba = params[:users] == "" ? Document.all  : user.documents_dataset.to_a
    prueba = params[:date] == "" ? prueba : prueba.select {|d| d.date == params[:date] }
    category = Category.first(name: params[:category])
    prueba = params[:category] == "" ? prueba : prueba.select {|d| d.category_id == category.id }
    @documents = prueba
    @categories = Category.all
    erb :docs, :layout => :layout

  end

  post '/preview' do
    @src = params["route"]
    erb :preview, :layout=> false
  end

end 
