require 'json'
require './models/init.rb'
require 'date'
require 'action_view'
require 'action_view/helpers'
require 'sinatra-websocket'
include ActionView::Helpers::DateHelper
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
    if user_not_logger_in? && restricted_path? 
      redirect 'login'
    elsif session[:user_id] 
      @current_user = User.find(id: session[:user_id])
      @unread = Notification.where(user_id: @current_user.id,read: false).to_a.length
      @visibility = @current_user.role == "user" ? "none" : "inline"
      if session_path?
        redirect '/documents'
      elsif not_authorized_user? && admin_path?
        redirect '/documents'     
      end
    end

  end

  def user_not_logger_in?
    !session[:user_id]
  end

  def restricted_path?
    request.path_info == '/subscribe' || request.path_info == '/mycategories' || request.path_info == '/mydocuments' || request.path_info == '/edityourprofile' ||  request.path_info == '/newadmin' ||  request.path_info == '/upload' ||  request.path_info == '/unsubscribe'
  end

  def session_path?
    request.path_info == '/login' || request.path_info == '/signup'
  end

  def admin_path?
    request.path_info == '/newadmin' || request.path_info == '/upload'
  end

  def not_authorized_user?
    @current_user.role == "user"
  end 

  get '/' do
    erb :index, :layout => :layoutIndex
  end

  get "/documents" do 
    logger.info ""
    logger.info session["session_id"]
    logger.info session.inspect
    logger.info "-------------"
    logger.info ""
    @view = params[:forma]  
    
    if params[:userfilter] || params[:datefilter] || params[:categoryfilter] 
      @userfilter = params[:userfilter]
      @datefilter = params[:datefilter]
      @categoryfilter = params[:categoryfilter]
      user = User.first(username: params[:userfilter]) 
      filter_docs = []
      if user
        filter_docs = user.documents_dataset.order(:date).reverse.where(motive: 'subscribed').invert.to_a
      else
        filter_docs = Document.order(:date).reverse.all
      end
      doc_date = params[:datefilter] == "" ? filter_docs : Document.first(date: params[:datefilter])
      filter_docs = params[:datefilter] == "" ? filter_docs : filter_docs.select {|d| d.date == doc_date.date }
      category = Category.first(name: params[:categoryfilter])
      filter_docs = params[:categoryfilter] == "" ? filter_docs : filter_docs.select {|d| d.category_id == category.id }
      @documents = filter_docs
    else
      @documents = Document.order(:date).reverse.all
    end
    @categories = Category.all
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

  get "/subscribe" do
    if Category.select(:id).except(Subscription.select(:category_id).where(user_id: @current_user.id)).to_a.length > 0
      @categories = Category.select(:id).except(Subscription.select(:category_id).where(user_id: @current_user.id))
      @categories = Category.where(id: @categories)
    end
    erb :suscat, :layout => :layout
  end

  get "/upload" do
    @categories = Category.all
    @users = User.all
    erb :upload, :layout => :layout
  end

  get "/newadmin" do
    erb :newadmin, :layout=> :layout
  end

  get '/notifications' do
    @notifications = Notification.where(user_id: @current_user.id).order(:datetime).reverse
    if params[:id] &&  Notification.first(document_id: params[:id],user_id: @current_user.id)
      Notification.first(document_id: params[:id],user_id: @current_user.id).update(read: true)  
    end
    erb :notifications
  end

  get "/mycategories" do
    if @current_user.categories_dataset.to_a.length > 0
      @categories =  @current_user.categories_dataset
    end
    erb :yourcats, :layout=> :layout
  end

  get '/mydocuments' do
    if @current_user.documents_dataset.where(motive: 'subscribed').to_a.length > 0
      mydocs = @current_user.documents_dataset.select(:document_id).where(motive: 'subscribed').invert
      @documents = Document.where(id: mydocs)
    end
    erb :yourdocs, :layout=> :layout
  end

  get "/unsubscribe" do
    if @current_user.categories_dataset.to_a.length > 0
      @categories =  @current_user.categories_dataset
    end
    erb :deletecats, :layout=> :layout
  end


  get '/logout' do 
    session.clear
    redirect '/login'
  end


  post '/login' do
    if params["password"] != "" && params["username"] != ""
      usuario = User.find(username: params[:username])
      if usuario && usuario.password == params[:password]
        session[:user_id] = usuario.id
        redirect "/documents"
      else
        @error ="Wrong username or password"
        erb :login, :layout => :layout
      end
      
    end
  end


  post '/signup' do
    if User.find(username: params[:username]) || /\A\w{3,15}\z/ !~ params[:username]
      @errorusername = "The username is already in use or its invalid"
    end
    if   User.find(email: params[:email]) ||  /\A.*@.*\..*\z/ !~ params[:email]                                                                                              
      @erroremail = "The email is invalid"
    end
    if params[:password] != params[:confPassword] 
      @errorpasswordconf = "Passwords are not equal"
    end
    if params[:password].length < 5 || params[:password].length > 20 
      @errorpasswordlength = "Password must be between 5 and 20 characters long"
    end
    if !@errorusername && !@erroremail && !@errorpasswordconf && !@errorpasswordlength
      request.body.rewind

      hash = Rack::Utils.parse_nested_query(request.body.read)
      params = JSON.parse hash.to_json 
      user = User.new(name: params["fullname"], email: params["email"], username: params["username"], password: params["password"])
      if user.save
          session[:user_id] = user.id
          redirect "/documents"
      else 
        [500, {}, "Internal server Error"]
      end 
    else
      erb :signup, :layout => :layout
    end
  end

# app.rb 
  post '/upload' do
    if params["date"] != "" && params["title"] != ""  && params["categories"] != "" && params["document"] != ""  
     
      file = params[:document][:tempfile]
      @filename = params[:document][:filename]
   
      @src =  "/file/#{@filename}"
      
      category = Category.first(name: params["categories"])
      doc = Document.new(date: params["date"], name: params["title"], userstaged: params["users"], categorytaged: params["categories"], document: @src,category_id: category.id)
      if doc.save
        doc = Document.first(date: params["date"], name: params["title"], userstaged: params["users"], categorytaged: params["categories"], document: @src)
        doc.update(document: doc.id)
        cp(file.path, "public/file/#{doc.id}.pdf")
        usuario = params["users"].split(',')
        usuario.each do |userr|
       
          user = User.first(username: userr)
          if user 
            user.add_document(doc)
            user.save
            Notification.where(user_id: user.id,document_id: doc.id).update(motive: "taged",datetime: Time.now)
          end
        end

        suscribeds = Subscription.where(category_id: doc.category_id)
        suscribeds.each do |suscribed|
          suscr = User.first(id: suscribed.user_id)
          if suscr && Notification.find(user_id: suscr.id,document_id: doc.id)
            Notification.where(user_id: suscr.id,document_id: doc.id).update(motive: "taged and subscribed")
          elsif suscr 
            suscr.add_document(doc)
            suscr.save
            Notification.where(user_id: suscr.id,document_id: doc.id).update(motive: "subscribed",datetime: Time.now)
          end 

        end

        @success = "The document has been uploaded"
        @categories = Category.all
        erb :upload, :layout => :layout
      else 
        @error = "An error has ocurred when trying to upload the document"
        @categories = Category.all
        erb :upload, :layout => :layout
      end
    end
  end

  post '/subscribe' do
    category = Category.first(name: params["categories"])
    if @current_user && category 
          category.add_user(@current_user)
          if category.save
            @success ="You are now subscribed to #{params[:categories]}!"
            if Category.select(:id).except(Subscription.select(:category_id).where(user_id: @current_user.id)).to_a.length > 0
              @categories = Category.select(:id).except(Subscription.select(:category_id).where(user_id: @current_user.id))
              @categories = Category.where(id: @categories)
            end
            erb :suscat, :layout => :layout
          else
            @error ="You are already subscribed to #{params[:categories]}!"
            if Category.select(:id).except(Subscription.select(:category_id).where(user_id: @current_user.id)).to_a.length > 0
              @categories = Category.select(:id).except(Subscription.select(:category_id).where(user_id: @current_user.id))
              @categories = Category.where(id: @categories)
            end
            erb :suscat, :layout => :layout
          end
    end      
  end

  post '/newadmin' do
    if User.find(username: params[:username]) 
      if User.find(username: params[:username]) && User.find(username: params[:username]).role == 'admin'
        @error = "#{params[:username]} is already an admin or does not exist"
        erb  :newadmin, :layout => :layout
      else
        User.where(username: params[:username]).update(role: 'admin')
        @success = "#{params[:username]} has been promoted to admin"
        erb  :newadmin, :layout => :layout
      end
    else 
      @error = "An error has ocurred when trying to promote #{params[:username]} to admin"
      erb  :newadmin, :layout => :layout
    end
  end

  post '/unsubscribe' do
    category = Category.first(name: params["category"])
    if @current_user && category && @current_user.remove_category(category)
      @success = "You have been unsubscribed from #{params[:category]}"
      if @current_user.categories_dataset.to_a.length > 0
        @categories =  @current_user.categories_dataset
      end
      erb  :deletecats, :layout => :layout
    else
      @error = "An error has ocurred when trying unsubscribe you from #{params[:category]}"
      @categories =  @current_user.categories_dataset
      erb  :deletecats, :layout => :layout
    end
  end

  post '/documents' do
    user = User.first(username: params[:users]) 
    filter_docs = []
    if user
      filter_docs = user.documents_dataset.order(:date).reverse.where(motive: 'subscribed').invert.to_a
    else
      filter_docs = Document.order(:date).reverse.all
    end
    doc_date = params[:date] == "" ? filter_docs : Document.first(date: params[:date])
    filter_docs = params[:date] == "" ? filter_docs : filter_docs.select {|d| d.date == doc_date.date }
    category = Category.first(name: params[:category])
    filter_docs = params[:category] == "" ? filter_docs : filter_docs.select {|d| d.category_id == category.id }
    @documents = filter_docs
    @view = params[:forma]

    @filtros = [params[:users],params[:date],params[:category]]

    @categories = Category.all
    erb :docs, :layout => :layout
  end

  get '/view/:doc_id' do
    @src = "/file/" + params[:doc_id] + ".pdf"
    if params[:read] == "true" && session[:user_id]
      Notification.first(document_id: params[:doc_id],user_id: session[:user_id]).update(read: true)
    end
    erb :preview, :layout=> :doclayout
  end

end 
