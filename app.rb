require 'sinatra/base'

class App < Sinatra::Base
  configure :development, :production do
    enable :logging
  end

  get "/" do
    "hello cruel world!!!"
  end

  post "/users" do
    # Crear el usuario en DB posiblemente

    logger.info "--------"
    logger.info params
    logger.info JSON.parse(request.body.read)
    logger.info "--------"

    "USER CREATED"
  end
end
