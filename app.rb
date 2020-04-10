class App < Sinatra::Base

  redirectedSignup = 0
 
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


  post '/login' do
    if  params[:username] == "juanalanis" #funcion que busque si password corresponde a ese username
      "Succesful log in" #TODO: direct to docs homepage as registered user
    else 
        erb :failedLogin
    end
  end


  post '/signup' do
    if params[:username] == "juanalanis"  #funcion que busque si el nombre usuario o email ya fueron usados
      erb :failedSignupUser
    elsif params[:email] == "juan@hola.com"
      erb :failedSignupEmail
    elsif params[:password] != params[:confPassword]
      erb :failedSignupPass
    else
      "Succesful sign up"
    end
  end

end 
