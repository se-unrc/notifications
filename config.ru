require "bundler"
require "sinatra"

Bundler.require

#Create connection anda leave it as a global objet in our project
DB = Sequel.connect(
   
    adapter: 'postgres',
    database: 'notificator-development',
    host: 'db',
    user: 'unicorn',
    password: 'magic'
)

#Requiere and run the main app
require "./app.rb"
run App

