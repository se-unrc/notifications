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




  get "/create_user" do
    erb :create_user
  end
  post "/newUser" do
    if user = User.find(email: params["email"])
      [400, {}, "ya existe el usuario"]
    else
      @userName = User.new(name: params["name"],surname: params["surname"],dni: params["dni"],email: params["email"],password: params["password"],rol: params["rol"])
      @userName.admin=false
      if @userName.save
        redirect "/login"
      else
        [500, {}, "Internal Server Error"]
        redirect "/create_user"
      end
    end
  end


  get "/login" do
    erb :login
  end
  post "/userLogin" do
    if @userName = User.find(email: params["email"])
      if @userName.password == params["password"]
        session[:isLogin] = true
        session[:user_id] = @userName.id
        session[:type] = @userName.admin
        if session[:type] == true
          redirect "/profileAdmin"
        else
          redirect "/profile"
        end
      else
        @error ="Your password is incorrect"
      end
    else
      @error ="Your email is incorrect"
    end
  end




  get "/profile" do
    if session[:isLogin]
      @userName= User.find(id: session[:user_id])
      @document = Document.all
      erb :profile, :layout => :layout_users
    else
      redirect "/"
    end
  end

  get "/profileAdmin" do
    if session[:isLogin] && session[:type]==true
      @userName = User.find(id: session[:user_id])
      @document = Document.all
      erb :profileAdmin, :layout => :layout_admin
    else
      redirect "/"
    end
  end
  get "/edit_user" do
    if session[:isLogin]
      @userName = User.find(id: session[:user_id])
      if  session[:type]==true
        erb :edit_user, :layout => :layout_admin
      else
        erb :edit_user, :layout => :layout_users
      end
    else
      redirect "/"
    end
  end
  post "/editNewUser" do
    @userName.update(name: params["name"],surname: params["surname"],dni: params["dni"],password: params["password"],rol: params["rol"])
    if @userName.save
      redirect "/profile"
    else
      redirect "/edit_user"
    end
  end


  get "/create_document" do
    if session[:isLogin] && session[:type]==true
      @userName = User.find(id: session[:user_id])
      @userCreate = User.all
      @categories = Category.all
      erb:create_document, :layout => :layout_admin
    else
      if session[:isLogin]
        redirect "/profile"
      else
        redirect "/"
      end
    end
  end

  get "/tag_document" do
    if session[:isLogin] && session[:type]==true
      @userName = User.find(id: session[:user_id])
      @document=Document.all#modificar por documetnos taggeados
      erb :profile, :layout => :layout_admin
    else
      redirect "/"
    end
  end

  get "/category" do
    if session[:isLogin] && session[:type]==true
      @userName = User.find(id: session[:user_id])
      @cat  = Category.all
      erb :category, :layout => :layout_admin
    else
      redirect "/"
    end
  end

  get "/create_category" do
    if session[:isLogin] && session[:type]==true
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
      redirect "/category"
    else
      cat = Category.new(name: params['name'],description: params['description'] )
      if cat.save
        redirect "/category"
      else
        [500, {}, "Internal Server Error"]
        redirect "/home"
      end
    end
  end


  get "/delete_category" do
    if session[:isLogin] && session[:type]==true
      @cat  = Category.all
      erb:delete_category, :layout => :layout_admin
    else
      if session[:isLogin]
        redirect "/home"
      else
        redirect "/"
      end
    end
  end
  post "/delete_category" do
    if @categor = Category.find(name: params["name"])
      @categor.remove_all_users
      @doc = Doc.find(category_id: @categor.id)
      @categor.delete
      redirect "/category"
    else
      [500, {}, "No existe la Categoria"]
      redirect "/category"
    end
  end

  get "/search_category" do
    if session[:isLogin] && session[:type]==true
      erb:search_category, :layout => :layout_admin
    else
      redirect "/"
    end
  end
  post "/search_category" do
    if @aux = Category.find(name:params["name"])
      @cat = Category.all
      erb:category
    else
      [500, {}, "No existe la Categoria"]
      redirect "/category"
    end
  end

  post "/modify_category" do
    if  @cat = Category.find(name:params["oldName"])
      @cat.update(name: params["name"],description: params["description"])
      if @cat.save
        redirect "/category"
      else
        [500, {}, "Internal Server Error"]
        redirect "/profileAdmin"
      end
    else
      [500, {}, "Internal Server Error"]
    end
  end
  post "/selected_category" do
    @cat = Category.all
    @categor = Category.find(name: params[:name])
    erb :category, :layout => :layout_admin
  end

  get "/subscriptions" do
    if session[:isLogin]
      @userName = User.find(id: session[:user_id])
      @collection = @userName.categories
      if session[:type] == true
        erb :subscriptions,:layout => :layout_admin
      else
        erb :subscriptions,:layout =>:layout_users
      end
    end
  end

  post "/subscriptions" do
    @userName = User.find(id: session[:user_id])
    @cat = Category.find(name: params['name'])
    if params['option'] == "delete"
      @userName.remove_category(@cat)
      redirect "/subscriptions"
    else
      if @cat = Category.find(name: params['name'])
        @doc = @cat.documents
        redirect"/show_documents"
      else
        redirect "/subscriptions"
      end
    end
  end

  get "/show_documents"do
    if session[:isLogin]
    @userName = User.find(id: session[:user_id])
      if session[:type] == true
        erb:show_documents,:layout => :layout_admin
      else
        erb:show_documents,:layout =>:layout_users
      end
    else
      redirect"/"
    end
  end

  get "/add_subscriptions" do
    if  session[:isLogin]
      @userName = User.find(id: session[:user_id])
      @collection = Category.exclude(users: @user).all
      if session[:type] == true
        erb:add_subscriptions,:layout => :layout_admin
      else
        erb:add_subscriptions,:layout =>:layout_users
      end
    end
  end

  post "/add_subscriptions" do
    if @cat = Category.find(name: params['name'])
      @userName = User.find(id: session[:user_id])
      @userName.add_category(@cat)
      redirect"/add_subscriptions"
    else
      redirect "/subscriptions"
    end
  end

  get "/home" do
    if session[:isLogin]
      if session[:type] == true
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

  post '/create_document' do
    @filename = params[:PDF][:filename]
    @src =  "/public/PDF/#{@filename}"
    file = params[:PDF][:tempfile]
    direction = "PDF/#{@filename}"
    File.open("./public/PDF/#{@filename}", 'wb') do |f|
      f.write(file.read)
    end
    if (Document.find(name: params['name']))
      redirect "/create_document"
    end
    if (Document.find(description: params['description']))
      redirect "/create_document"
    end
    date = Time.now.strftime("%d/%m/%Y %H:%M:%S")
    chosenCategory = Category.find(id: params[:cat])
    @prob = User.all
    @doc = Document.new(name: params['name'], description: params['description'], fileDocument:  direction, category_id: chosenCategory.id, date: date)
    @doc.save
    @aux = params[:mult]
    @aux.each do |element|
      @doc.add_user(element)
    end
    redirect "/all_document"
  end

  post "/delete_document" do
    @pdfDelete = Document.find(id: params[:theId])
    @pdfDelete.remove_all_users
    @pdfDelete.delete
    redirect "/all_document"
  end

  get "/all_document" do
    @userName = User.find(id: session[:user_id])
    if params[:filter]
      if Document.find(name: params[:filter])
        @allPdf = [Document.find(name: params[:filter])]
        erb:all_document, :layout => :layout_admin
      else
        erb:all_document, :layout => :layout_admin
      end
    else
      @allPdf = Document.order(:name)
      erb:all_document, :layout => :layout_admin
    end
  end

  post "/selected_document" do
    @userName = User.find(id: session[:user_id])
    @allCat = Category.all
    @userCreate = User.all
    @axu= params[:pdf]
    erb :selected_document, :layout => :layout_admin
  end

  post "/modify_document" do
    @userName = User.find(id: session[:user_id])
    if (params[:name])
      @new = Document.find(id: params[:theId])
      @new.update(name: params[:name])
    end
    if (params[:description])
      @new = Document.find(id: params[:theId])
      @new.update(description: params[:description])
    end
    if (params[:cate])
      @new = Document.find(id: params[:theId])
      @new.update(category_id: params[:cate])
    end
    if (params[:mult])
      @new = Document.find(id: params[:theId])
      @new.remove_all_users
      @aux = params[:mult]
      @aux.each do |element|
        @new.add_user(element)
      end
    end
    redirect "/all_document"
  end
end
