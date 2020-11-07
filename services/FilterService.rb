# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra-websocket'
require './models/init'

# Service para los filtros de busqueda de lo documentos
class FilterService
  def self.filter(document_id, filter, category_id, date_filter)
    @all_documents = Document.order(:name).all
    if document_id
      @all_documents = Document.where(id: document_id).all
      show_filter(@all_documents)
    else
      filter_advanced(@all_documents, filter, category_id, date_filter)
    end
  end

  def self.filter_advanced(_all_documents, filter, category_id, date_filter)
    if filter
      filter_order(@all_documents, filter, category_id, date_filter)
    elsif category_id
      filter_category(@all_documents, category_id, date_filter)
    elsif date_filter != ''
      filter_date(@all_documents, date_filter)
    else
      show_filter(@all_documents)
    end
  end

  def self.filter_order(documents, filter, category_id, date_filter)
    @all_documents_order = order_document(documents, filter)
    if category_id
      filter_category(@all_documents_order, category_id, date_filter)
    elsif date_filter != ''
      filter_date(@all_documents_order, date_filter)
    else
      show_filter(@all_documents_order)
    end
  end

  def self.filter_category(oder_document, category_id, date_filter)
    @documents_category = Document.where(category_id: category_id).all
    @documents = []
    oder_document&.each do |element|
      @documents << element if @documents_category.include?(element)
    end
    if date_filter != ''
      filter_date(@documents, date_filter)
    else
      show_filter(@documents)
    end
  end

  def self.filter_date(_all_documents, date_filter)
    return unless date_filter != ''

    new_date = new_date_format(date_filter)
    @document_date = Document.where(date: new_date).all
    @documents = []
    oder_document&.each do |element|
      @documents << element if @document_date.include?(element)
    end
    show_filter(@documents)
  end

  def self.show_filter(all_document)
    @all_documents = all_document
    @all_categories = Category.order(:name).all
    if session[:type]
      @users_name = User.order(:name).all
      erb :all_document, layout: @current_layout
    else
      erb :documents, layout: @current_layout
    end
  end

  def self.new_date_format(date)
    month_num = [1..12]
    month = %w[Jan Feb Apr May Jun Jul Aug Sep Oct Nov Dec]
    month_num.each do |element|
      new_date = "#{date[8, 12]}-#{element}-#{date[4, 6]}" if date[0, 3] == month[element]
    end
    new_date
  end

  def self.order_document(documents, filter)
    if filter == 'date0'
      Document.reverse_order(:date)
    else
      documents
    end
  end
end
