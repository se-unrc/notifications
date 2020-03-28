require 'sinatra/base'

class App < Sinatra::Base
  configure :development, :production do
    enable :logging
  end

  get "/" do
    "hello cruel world!!!"
  end
end
