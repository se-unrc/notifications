class App < Sinatra::Base
  get "/" do
    erb :index
  end
  get "/register" do
    erb :register
  end
  get '/action_page.php' do
    erb :registerlandingpage
  end
  post '/action_page.php' do
    erb :loginlandingpage
  end
  get "/login" do
    erb :login
  end
  get "/tos" do
  	erb :ToS
  end
  get "/users" do
  	logger.info '/users'
  	logger.info params
  	logger.info '----'
  end
  get "/hello/:name" do
  	"Hi #{params['name']}"

  end
  post "/users/add" do
  	logger.info "----"
  	logger.info params
  	logger.info JSON.parse(request.body.read)
  	logger.info "------"
  	
  end
  get "/posts" do
  	# matches "GET /posts?title=foo&author=bar"
  	title = params["title"]
  	author = params["author"]
  	# uses title and author variables:query is optional to the /posts route
  end
 
end
