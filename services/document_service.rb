# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra-websocket'
require './models/init'

# Service para Document
class DocumentService
  def self.revisar_datos(nombre,  description)
    raise ArgumentError, 'Ya existe un documento con ese nombre' if Document.find(name: nombre)
    # raise ArgumentError, 'Nombre demasiado corto' if nombre.length < 3
    # raise ArgumentError, 'Nombre demasiado corto' if nombre.length > 50
    # raise ArgumentError, 'Descripción demasiado corta' if description.length < 3
    # raise ArgumentError, 'descripción demasiado corto' if description.length > 1000
  end
end
