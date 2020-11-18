# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra-websocket'
require './models/init'

require './controllers/before_controller'

require './services/category_service'
# Controller para Category
class CategoryController < BeforeController
  get '/all_category' do
    @page_name = 'Categorias'
    @all_categories = Category.order(:name).all
    erb :all_category, layout: @current_layout
  end

  post '/create_category' do
    begin
      CategoryService.revisar_datos(params[:name], params[:description])
      category = Category.new(
        name: params[:name],
        description: params[:description]
      )
      [500, {}, 'Internal Server Error'] unless category.save
    rescue ArgumentError
      erb :all_category, layout: @current_layout
    end
    redirect '/all_category'
  end

  post '/modify_category' do
    begin
      CategoryService.revisar_datos(params[:name], params[:description])
      @category_update = Category.find(id: params[:modify_id])
      @category_update&.update(
        name: params[:name],
        description: params[:description]
      )
    rescue ArgumentError
      erb :all_category, layout: @current_layout
    end
    redirect '/all_category'
  end

  post '/delete_category' do
    @category_delete = Category.find(id: params['id_delete'])
    @category_selected = Category.find(id: params['id_select'])
    @document = Document.where(category_id: @category_delete.id)
    @document.each do |element|
      element.update(category_id: @category_selected.id)
    end
    @all_docs = Document.where(category_id: @category_delete.id)
    if @all_docs.empty?
      @category_delete.remove_all_users
      @category_delete.delete
    end
    redirect '/all_category'
  end
end
