require './models/user.rb'

class AccountService
	
	def self.register_new_user(username, password, password2, email, fullName)
		
		if password != password2
			raise ArgumentError.new("Passwords are not equal")
		end

		if User.find(username: username) || /\A\w{3,15}\z/ !~ username
      		raise ArgumentError.new('The username is already in use or its invalid')
    	end

    	if User.find(email: email) || /\A.*@.*\..*\z/ !~ email
    		raise ArgumentError.new("The email is invalid")
    	end

    	if params[:password].length < 5 || params[:password].length > 20
	      raise ArgumentError.new('Password must be between 5 and 20 characters long')
	    end

      	request.body.rewind
	    hash = Rack::Utils.parse_nested_query(request.body.read)
      	params = JSON.parse hash.to_json
      	user = User.new(name: fullName, email: email, username: username,
                      password: password)
      	unless user.valid?
      		raise ArgumentError.new("Error at save the user")
      	end
    	user.save

    end

    def self.login_user(username, password)
    	usuario = User.find(username: username)
    	if usuario && usuario.password == params[:password]
	        session[:user_id] = usuario.id
	    else
	    	raise ArgumentError.new("Wrong username or password")
	    end
	end
	
end