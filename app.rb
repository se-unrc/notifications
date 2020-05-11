class App < Sinatra::Base
  get "/" do #listo
      erb:Login
    end
    get "/NewUser" do #listo
      erb:NewUser
    end
    get "/User" do #listo
      erb:User
    end
    get "/Admin" do #listo
      erb:Admin
    end
    get "/NewDocument" do
      erb:NewDocument
    end
