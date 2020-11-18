# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra-websocket'
require './models/init'

require './controllers/before_controller'

require './services/create_document_service'
require './services/filter_service'
require './services/document_service'

# Controller para Document
class DocumentController < BeforeController
  get '/all_document' do

    @page_name = 'Documentos'
    @all_documents = Document.order(:name).all
    @all_categories = Category.order(:name).all
    @users_name = User.order(:name).all
    erb :all_document, layout: @current_layout
  end

  get '/documents' do
    @page_name = 'Documentos'
    @all_documents = Document.order(:name).all
    @all_categories = Category.order(:name).all
    erb :documents, layout: @current_layout
  end

  post '/documents_filter' do
    @page_name = 'Documentos'
    FilterService.filter(params[:document_id], params[:filter], params[:category_id], params[:dateDoc])
  end

  post '/create_document' do
    begin
      DocumentService.revisar_datos(params[:name], params[:description])
      @filename = params[:PDF][:filename]
      @src = "/public/PDF/#{@filename}"
      file = params[:PDF][:tempfile]
      direction = "PDF/#{@filename}"
      File.open("./public/PDF/#{@filename}", 'wb') do |f|
        f.write(file.read)
      end
      @doc_save = CreateDocumentService.save_document(
        params['name'],
        params[:description],
        direction,
        params[:category]
      )
      CreateDocumentService.select_user_tag(params[:users_tagged], params[:category], @doc_save.id)
    rescue ArgumentError
      erb :all_document, layout: @current_layout
    end
    
  end

  post '/select_document' do
    @page_before_name = 'Documentos'
    @page_before = '/all_document'
    @page_intern = 'Editar Documento'
    @document_modify = Document.find(id: params[:select_id])
    @categories_modify = Category.where(id: @document_modify.category_id)
    @all_categories = Category.except(@categories_modify).all
    @users_tagged = User.where(documents: @document_modify)
    @users = User.except(@users_tagged).all
    erb :modify_document, layout: @current_layout
  end

  post '/modify_document' do
    begin
      DocumentService.revisar_datos(params[:name], params[:description])
      @document_modify = Document.find(id: params[:the_id])
      @document_modify.update(name: params[:new_name]) if params[:new_name] != ''
      @document_modify.update(description: params[:description]) if params[:description] != ''
      @document_modify.update(category_id: params[:category]) if params[:category]
      @document_modify.remove_all_users
      @notification_delete = Notification.where(document_id: @document_modify.id).all
      @notification_delete&.each do |element|
        element.remove_all_users
        element.delete
      end
      CreateDocumentService.select_user_tag(params[:users_tagged], @document_modify.category_id, @document_modify.id)
    rescue ArgumentError
      erb :all_document, layout: @current_layout
    end
    redirect '/all_document'
  end

  post '/delete_document' do
    @pdf_delete = Document.find(id: params[:delete_document_id])
    @pdf_delete.remove_all_users
    @notification = Notification.where(document_id: @pdf_delete.id).all
    @notification.each do |element|
      element.remove_all_users
      element.delete
    end
    @pdf_delete.delete
    redirect '/all_document'
  end

  post '/see_document' do
    if params[:name] == 'Perfil'
      @page_name = 'Documento'
    else
      @page_before_name = params[:name]
      @page_before = params[:road]
      @page_intern = 'Documento'
    end
    @document = Document.find(id: params[:seen_document_id])
    erb :view_document, layout: @current_layout
  end
end
