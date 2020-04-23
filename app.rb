class App < Sinatra::Base
  get "/" do
    "hello cruel world!!!"
  end

  get '/index' do
    erb :index
  end

  get '/users' do
    "Usuarios"
  end

  post '/users' do
    #Crear usuario
  end
end
