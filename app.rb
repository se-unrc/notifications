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


  post '/login' do
    if  params[:username] == "juanalanis" #funcion que busque si password corresponde a ese username
      "My name is #{params[:username]}, and my password is #{params[:password]}"
    else 
      erb :login
    end
    
  
  end


  post '/signup' do
    if params[:username] == "juanalanis" || params[:username] == "jereparla" #funcion que busque si el nombre usuario o email ya fueron usados
      erb :signup 
    else
      "My name is Juan"
    end
  end

end 
