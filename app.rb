class App < Sinatra::Base
  get "/" do
    "hello cruel world!!!"
  end
end

class App
  get '/index' do
    "Hello world"
  end
end
