class App < Sinatra::Base
  get "/" do
	erb :index
  end

  get "/docs" do 
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

end 
