require 'json'
require './models/init.rb'
class App < Sinatra::Base
 
  get "/" do 
  	erb :docs
  end

  get "/aboutus" do
	 erb :aboutus
  end

  get "/login" do
    erb :login

  end	
	 
  get "/signup" do
    erb :signup 
  end	

  get "/forgotpass" do
    erb :forgotpass
  end

  get "/profile" do
    erb :profile
  end 

  post '/login' do
    if  params[:username] == "juanalanis" #funcion que busque si password corresponde a ese username
      "Succesful log in" #TODO: direct to docs homepage as registered user
    else 
        @error = 'Username or password was incorrect'
        erb :login
    end
  end


  post '/signup' do
    request.body.rewind

    hash = Rack::Utils.parse_nested_query(request.body.read)
    params = JSON.parse hash.to_json 

    user = User.new(name: params["fullname"], email: params["email"], username: params["username"], password: params["password"])
    if user.save
      redirect "/"
    else 
      [500, {}, "Internal server Error"]
    end 
  end

  post '/profile' do
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


  post '/profile' do
    if params[:categorie] == "presupuesto"
      @error ="You are already suscribed to #{params[:categorie]}"
      erb :profile
    else
      @success ="Now you are suscribed to #{params[:categorie]}!"
      erb :profile
    end
  end

end 
