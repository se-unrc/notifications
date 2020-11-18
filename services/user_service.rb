# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra-websocket'
require './models/init'

# Service para User
class UserService
  def self.revisar_datos(dni, email, nombre, apellido)
    raise ArgumentError, 'Ya existe un usuario con ese DNI' if User.find(dni: dni)
    raise ArgumentError, 'Nombre demasiado corto' if nombre.length < 3
    raise ArgumentError, 'Nombre demasiado largo' if nombre.length > 40
    raise ArgumentError, 'Apellido demasiado corto' if apellido.length < 3
    raise ArgumentError, 'Apellido demasiado largo' if apellido.length > 40
    raise ArgumentError, 'Ya existe un usuario con ese email' if User.find(email: email)
  end
end
