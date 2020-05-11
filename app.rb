class App < Sinatra::Base
  get "/" do
    erb:Login
  end
  get "/Admin" do
    erb:Admin
  end
end
