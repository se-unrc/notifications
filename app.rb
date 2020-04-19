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
    if params[:username] == "juanalanis"  #funcion que busque si el nombre usuario o email ya fueron usados
        @error = 'The username is invalid'
        erb :signup
    elsif params[:email] == "juan@hola.com"
        @error = 'The email is invalid'
        erb :signup
    elsif params[:password] != params[:confPassword]
        @error = 'Passwords do not match'
        erb :signup
    else
      "Succesful sign up"
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
