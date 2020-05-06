class App < Sinatra::Base
  get "/" do
    "hello cruel world"
  end
  get "/pagina1" do
    erb:pagina1
  end
end
